package kopo.shallwithme.service.impl;

import com.amazonaws.ClientConfiguration;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@Slf4j
public class NcloudStorageService {

    @Value("${ncp.object-storage.endpoint}")
    private String endpoint;               // https://kr.object.ncloudstorage.com

    @Value("${ncp.object-storage.region}")
    private String region;                 // kr-standard

    @Value("${ncp.object-storage.access-key}")
    private String accessKey;

    @Value("${ncp.object-storage.secret-key}")
    private String secretKey;

    @Value("${ncp.object-storage.bucket-name}")
    private String bucketName;             // contest-71

    @Value("${ncp.object-storage.folder}")
    private String profileFolder;          // profile (룸메이트용)

    @Value("${ncp.object-storage.sharehouse-folder}")
    private String sharehouseFolder;       // sharehouse (쉐어하우스용)

    private AmazonS3 s3;

    @PostConstruct
    public void init() {
        BasicAWSCredentials creds = new BasicAWSCredentials(accessKey, secretKey);

        // NCP는 S3 호환 + path-style 권장
        ClientConfiguration clientConfig = new ClientConfiguration();
        clientConfig.setSignerOverride("AWSS3V4SignerType");

        this.s3 = AmazonS3ClientBuilder
                .standard()
                .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(endpoint, region))
                .withClientConfiguration(clientConfig)
                .withCredentials(new AWSStaticCredentialsProvider(creds))
                .withPathStyleAccessEnabled(true) // v1에서도 지원(1.12.x)
                .build();

        log.info("NcloudStorageService initialized. endpoint={}, bucket={}", endpoint, bucketName);
    }

    /** (참고용) 프로필 1장 업로드 – 룸메이트 스타일 */
    public String uploadProfileImage(String userId, MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) return null;

        String original = Optional.ofNullable(file.getOriginalFilename()).orElse("image");
        String ext = "";
        int dot = original.lastIndexOf('.');
        if (dot > -1) ext = original.substring(dot);

        String key = String.format("%s/%s/%d%s", profileFolder, userId, System.currentTimeMillis(), ext);

        ObjectMetadata meta = new ObjectMetadata();
        meta.setContentLength(file.getSize());
        meta.setContentType(file.getContentType());

        PutObjectRequest req = new PutObjectRequest(bucketName, key, file.getInputStream(), meta)
                .withCannedAcl(CannedAccessControlList.PublicRead);
        s3.putObject(req);

        return buildPublicUrl(key);
    }

    // 2) 선업로드: houseId 없이 임시 경로에 저장 (모달 단계)
//    룸메이트 메인과 동일한 흐름: 모달에서 먼저 업로드 → URL 배열만 들고 있다가
//    /api/sharehouse/create 호출 시 sharehouseId가 나오면 이미지 URL을 DB에 매핑 저장.
    public List<String> uploadSharehouseImagesTemp(List<MultipartFile> files) throws IOException {
        List<String> urls = new ArrayList<>();
        if (files == null || files.isEmpty()) return urls;

        // 백엔드에서도 5장 제한을 한 번 더 보증 (프런트에서 막아도 서버 검증은 필수)
        if (files.size() > 5) {
            throw new IllegalArgumentException("이미지는 최대 5장까지 업로드 가능합니다.");
        }

        // 예: sharehouse/tmp/1728200000000/...
        final String tempPrefix = sharehouseFolder + "/tmp/" + System.currentTimeMillis();

        for (int i = 0; i < files.size(); i++) {
            MultipartFile f = files.get(i);
            if (f == null || f.isEmpty()) continue;

            String original = Optional.ofNullable(f.getOriginalFilename()).orElse("image");
            String ext = "";
            int dot = original.lastIndexOf('.');
            if (dot > -1) ext = original.substring(dot);

            // 키 예: sharehouse/tmp/1728200000000/4123412341234_0.jpg
            String key = String.format("%s/%d_%d%s", tempPrefix, System.nanoTime(), i, ext);

            ObjectMetadata meta = new ObjectMetadata();
            meta.setContentLength(f.getSize());
            meta.setContentType(f.getContentType() != null ? f.getContentType() : "application/octet-stream");

            try (var in = f.getInputStream()) { // 안전: 스트림 닫기
                PutObjectRequest req = new PutObjectRequest(bucketName, key, in, meta)
                        .withCannedAcl(CannedAccessControlList.PublicRead);
                s3.putObject(req);
            }

            urls.add(buildPublicUrl(key));
        }

        return urls;
    }

    /** ✅ 쉐어하우스: 여러 장 업로드(썸네일+상세 4장 = 최대 5장) */
    public List<String> uploadSharehouseImages(String houseId, List<MultipartFile> files) throws IOException {
        List<String> urls = new ArrayList<>();
        if (files == null || files.isEmpty()) return urls;

        for (int i = 0; i < files.size(); i++) {
            MultipartFile f = files.get(i);
            if (f == null || f.isEmpty()) continue;

            String original = Optional.ofNullable(f.getOriginalFilename()).orElse("image");
            String ext = "";
            int dot = original.lastIndexOf('.');
            if (dot > -1) ext = original.substring(dot);

            // key 예: sharehouse/{houseId}/1696499999999_0.jpg
            String key = String.format("%s/%s/%d_%d%s",
                    sharehouseFolder, houseId, System.currentTimeMillis(), i, ext);

            ObjectMetadata meta = new ObjectMetadata();
            meta.setContentLength(f.getSize());
            meta.setContentType(f.getContentType());

            PutObjectRequest req = new PutObjectRequest(bucketName, key, f.getInputStream(), meta)
                    .withCannedAcl(CannedAccessControlList.PublicRead);
            s3.putObject(req);

            urls.add(buildPublicUrl(key));
        }
        return urls;
    }

    private String buildPublicUrl(String key) {
        // https://kr.object.ncloudstorage.com/{bucket}/{key}
        String base = endpoint.replaceAll("/+$", "");
        return base + "/" + bucketName + "/" + key;
    }
}
