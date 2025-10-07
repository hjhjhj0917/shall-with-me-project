package kopo.shallwithme.controller;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.service.ISharehouseService;
import kopo.shallwithme.service.impl.UserInfoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@RequestMapping(value = "/sharehouse")
@RequiredArgsConstructor
@Controller
public class SharehouseController {

    private final ISharehouseService sharehouseService;
    private final UserInfoService userInfoService;

    @Value("${ncp.object-storage.endpoint}")
    private String endpoint;

    @Value("${ncp.object-storage.region}")
    private String region;

    @Value("${ncp.object-storage.access-key}")
    private String accessKey;

    @Value("${ncp.object-storage.secret-key}")
    private String secretKey;

    @Value("${ncp.object-storage.bucket-name}")
    private String bucketName;

    @Value("${ncp.object-storage.folder}")
    private String folder;

    // 등록 페이지
    @GetMapping("/sharehouseReg")
    public String sharehouseReg() {
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        var req = attrs.getRequest();
        HttpSession session = req.getSession(false);

        String userId   = (session != null) ? (String) session.getAttribute("SS_USER_ID")   : "";
        String userName = (session != null) ? (String) session.getAttribute("SS_USER_NAME") : "";

        // 룸메이트와 동일 구조: JSP에서 사용할 값 셋업
        req.setAttribute("userTags", List.of());      // 필요시 서비스에서 태그 가져와 채우면 됨
        req.setAttribute("userTagNames", List.of());  // 화면 구조 맞추기용
        req.setAttribute("SS_USER_NAME", userName);

        return "sharehouse/sharehouseReg";
    }

    // ✅ 저장 처리 (쉐어하우스 등록: 썸네일 + 추가 이미지들 수신)
    @PostMapping(
            value = "/register",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    @ResponseBody
    public ResponseEntity<?> register(
            @RequestParam("thumbnail") MultipartFile thumbnail,
            @RequestParam(value = "images", required = false) List<MultipartFile> images,
            @RequestParam(value = "introduction", required = false) String introduction,
            @RequestParam(value = "profileImage", required = false) MultipartFile profileImage, // 프론트 호환(있으면 사용)
            HttpSession session
    ){
        String userId = (session != null) ? (String) session.getAttribute("SS_USER_ID") : null;
        if (userId == null || userId.isBlank()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("result", 0, "msg", "로그인이 필요합니다."));
        }

        try {
            // 1) 대표 이미지 업로드 (profileImage가 오면 우선 사용, 없으면 thumbnail 사용)
            MultipartFile cover = (profileImage != null && !profileImage.isEmpty()) ? profileImage : thumbnail;
            String coverUrl = (cover != null && !cover.isEmpty()) ? saveProfileImage(cover) : null;

            // 2) 추가 이미지 업로드 (선택)
            List<String> imageUrls = new ArrayList<>();
            if (images != null) {
                for (MultipartFile f : images) {
                    if (f != null && !f.isEmpty()) {
                        imageUrls.add(saveProfileImage(f));
                    }
                }
            }

            sharehouseService.registerHouse(
                    userId,
                    (introduction != null && !introduction.isBlank()) ? introduction : "제목 없음", // title
                    "",     // subText (NOT NULL 대비: 빈 문자열)
                    0,      // price   (NOT NULL 대비: 기본값 0)
                    coverUrl
            );

            return ResponseEntity.ok(Map.of("result", 1));
        } catch (Exception e) {
            // 루트 원인 추출
            Throwable root = e;
            while (root.getCause() != null) root = root.getCause();

            log.error("sharehouse/register failed", e);

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of(
                            "result", 0,
                            "msg", "DB오류: " +
                                    root.getClass().getSimpleName() + " - " +
                                    (root.getMessage() != null ? root.getMessage() : "")
                    ));
        }

    }

    // S3(NCP) 업로드 – 룸메이트와 동일한 방식/이름 유지
    private String saveProfileImage(MultipartFile file) throws IOException {
        String originalFilename = file.getOriginalFilename();
        String ext = StringUtils.getFilenameExtension(originalFilename);
        String uuidFileName = UUID.randomUUID().toString().replace("-", "") + (ext != null ? "." + ext : "");

        BasicAWSCredentials credentials = new BasicAWSCredentials(accessKey, secretKey);
        AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
                .withEndpointConfiguration(new AmazonS3ClientBuilder.EndpointConfiguration(endpoint, region))
                .withCredentials(new AWSStaticCredentialsProvider(credentials))
                .withPathStyleAccessEnabled(true)
                .build();

        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        metadata.setContentType(file.getContentType());

        String key = folder + "/" + uuidFileName;

        s3Client.putObject(new PutObjectRequest(bucketName, key, file.getInputStream(), metadata)
                .withCannedAcl(CannedAccessControlList.PublicRead));

        return endpoint + "/" + bucketName + "/" + key;
    }

    @GetMapping("/sharehouseMain")
    public String sharehouseMain() {
        return "sharehouse/sharehouseMain";
    }

    // 메인 페이지 리스트(룸메이트의 /userList 동일 구조)
    @GetMapping(value = "/userList", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public List<Map<String, Object>> getUserList(@RequestParam(defaultValue = "1") int page) {
        log.info("{}.getUserList Start!", this.getClass().getName());

        int safePage = Math.max(page, 1);
        int pageSize = 12;
        int offset = (safePage - 1) * pageSize;

        List<SharehouseCardDTO> cards = sharehouseService.listCards(offset, pageSize, null, null, null);

        // 룸메이트와 동일하게 Map으로 변환(tag1, tag2 포함)
        List<Map<String, Object>> rList = cards.stream().map(c -> {
            Map<String, Object> m = new HashMap<>();
            m.put("userId",  c.getHouseId()); // 키 이름만 맞추기용(프론트 구조 동일)
            m.put("profileImgUrl", c.getCoverUrl());
            m.put("name", c.getTitle());
            m.put("age", null);
            m.put("tag1", (c.getTags()!=null && c.getTags().size()>0) ? c.getTags().get(0) : null);
            m.put("tag2", (c.getTags()!=null && c.getTags().size()>1) ? c.getTags().get(1) : null);
            m.put("gender", null);
            return m;
        }).collect(Collectors.toList());

        log.info("{}.getUserList End!", this.getClass().getName());
        return rList;
    }

    // ★ 무한 스크롤 목록 API (JSON) – 응답 포맷 { items, lastPage } 동일
    @GetMapping(value = "/list", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> list(@RequestParam(defaultValue = "1") int page) {
        int safePage = Math.max(page, 1);
        int pageSize = 12;
        int offset = (safePage - 1) * pageSize;

        List<SharehouseCardDTO> cards = sharehouseService.listCards(offset, pageSize, null, null, null);

        List<Map<String, Object>> items = cards.stream().map(c -> {
            Map<String, Object> m = new HashMap<>();
            m.put("userId", c.getHouseId());   // 프론트 구조 재사용을 위해 키 이름 맞춤
            m.put("profileImgUrl", c.getCoverUrl());
            m.put("name", c.getTitle());
            m.put("age", null);
            m.put("tag1", (c.getTags()!=null && c.getTags().size()>0) ? c.getTags().get(0) : null);
            m.put("tag2", (c.getTags()!=null && c.getTags().size()>1) ? c.getTags().get(1) : null);
            m.put("gender", null);
            return m;
        }).collect(Collectors.toList());

        boolean lastPage = items.isEmpty();
        return Map.of("items", items, "lastPage", lastPage);
    }

    // ✅ 특정 항목의 태그 2개 + 기타정보 조회 API – 룸메이트 /{userId}/info와 동일
    @GetMapping("/{userId}/info")
    @ResponseBody
    public Map<String, Object> getRoommateInfo(@PathVariable String userId) {
        log.info("getRoommateInfo called for userId={}", userId);

        // houseId로 변환
        Long houseId;
        try { houseId = Long.valueOf(userId); }
        catch (Exception e) { return Map.of("tag1", null, "tag2", null, "gender", null); }

        SharehouseCardDTO c = sharehouseService.getCardById(houseId);
        String tag1 = (c!=null && c.getTags()!=null && c.getTags().size()>0) ? c.getTags().get(0) : null;
        String tag2 = (c!=null && c.getTags()!=null && c.getTags().size()>1) ? c.getTags().get(1) : null;

        // gender 키도 그대로 내려 프론트 구조를 유지
        return Map.of("tag1", tag1, "tag2", tag2, "gender", null);
    }

    // 상세 페이지 – 룸메이트의 roommateDetail과 동일한 흐름/경로 이름만 변경
    @GetMapping("/sharehouseDetail")
    public String roommateDetail(UserProfileDTO pDTO, org.springframework.ui.Model model) {
        String userId = pDTO.getUserId();  // ?userId=xxx

        log.info("sharehouseDetail called with userId={}", userId);

        Long houseId;
        try { houseId = Long.valueOf(userId); }
        catch (Exception e) { houseId = 1L; }

        var detail = sharehouseService.getDetail(houseId);
        model.addAttribute("user", detail); // 키 이름도 user 그대로(뷰 재사용을 위해)

        return "sharehouse/sharehouseDetail";
    }
}
