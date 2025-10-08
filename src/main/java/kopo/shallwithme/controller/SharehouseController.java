package kopo.shallwithme.controller;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
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
        req.setAttribute("userTags", List.of());
        req.setAttribute("userTagNames", List.of());
        req.setAttribute("SS_USER_NAME", userName);

        return "sharehouse/sharehouseReg";
    }

    // SharehouseController.java의 register 메서드만 수정하면 됩니다.
// 다음과 같이 수정하세요:

    @PostMapping(
            value = "/register",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    @ResponseBody
    public ResponseEntity<?> register(
            @RequestParam("thumbnail") MultipartFile thumbnail,
            @RequestParam(value = "images", required = false) List<MultipartFile> images,
            @RequestParam(value = "houseName", required = false) String houseName,
            @RequestParam(value = "introduction", required = false) String introduction,
            @RequestParam(value = "profileImage", required = false) MultipartFile profileImage,
            @RequestParam(value = "tagListJson", required = false) String tagListJson,
            @RequestParam(value = "floorNumber", required = false) String floorNumber,  // ✅ 층수 파라미터 추가
            HttpSession session
    ){
        String userId = (session != null) ? (String) session.getAttribute("SS_USER_ID") : null;
        if (userId == null || userId.isBlank()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("result", 0, "msg", "로그인이 필요합니다."));
        }

        try {
            log.info("=== 쉐어하우스 등록 요청 시작 ===");
            log.info("userId: {}", userId);
            log.info("houseName: {}", houseName);
            log.info("introduction: {}", introduction);
            log.info("tagListJson: {}", tagListJson);
            log.info("floorNumber: {}", floorNumber);  // ✅ 로그 추가
            log.info("thumbnail: {}", thumbnail != null ? thumbnail.getOriginalFilename() : "null");
            log.info("추가 이미지 개수: {}", images != null ? images.size() : 0);

            // 이미지 URL 배열 생성
            List<String> imageUrls = new ArrayList<>();

            // 1) 썸네일 (대표 이미지)
            if (thumbnail != null && !thumbnail.isEmpty()) {
                String thumbnailUrl = saveProfileImage(thumbnail);
                imageUrls.add(thumbnailUrl);
                log.info("썸네일 업로드: {}", thumbnailUrl);
            }

            // 2) 추가 이미지들
            if (images != null) {
                for (MultipartFile f : images) {
                    if (f != null && !f.isEmpty()) {
                        String url = saveProfileImage(f);
                        imageUrls.add(url);
                        log.info("추가 이미지 업로드: {}", url);
                    }
                }
            }

            log.info("총 업로드된 이미지: {}개", imageUrls.size());

            // ✅ houseName을 title로, introduction을 subText로, floorNumber 전달
            Long houseId = sharehouseService.registerHouseWithImages(
                    userId,
                    (houseName != null && !houseName.isBlank()) ? houseName : "제목 없음",
                    (introduction != null && !introduction.isBlank()) ? introduction : "",
                    "",
                    imageUrls,
                    floorNumber  // ✅ 층수 전달
            );

            log.info("✅ 등록 완료! houseId={}", houseId);

            // ✅ 태그 저장 (룸메이트와 동일한 방식)
            if (tagListJson != null && !tagListJson.isBlank()) {
                try {
                    ObjectMapper mapper = new ObjectMapper();
                    List<Integer> tagList = mapper.readValue(
                            tagListJson,
                            mapper.getTypeFactory().constructCollectionType(List.class, Integer.class)
                    );
                    if (!tagList.isEmpty()) {
                        sharehouseService.saveSharehouseTags(houseId, tagList);
                        log.info("✅ 태그 {}개 저장 완료", tagList.size());
                    }
                } catch (Exception e) {
                    log.error("태그 저장 중 오류", e);
                }
            }

            return ResponseEntity.ok(Map.of(
                    "result", 1,
                    "data", Map.of("shId", houseId)
            ));

        } catch (Exception e) {
            Throwable root = e;
            while (root.getCause() != null) root = root.getCause();

            log.error("sharehouse/register 실패", e);

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

        List<Map<String, Object>> rList = cards.stream().map(c -> {
            Map<String, Object> m = new HashMap<>();
            m.put("userId", c.getHouseId());
            m.put("houseId", c.getHouseId());  // ✅ houseId도 추가
            m.put("profileImgUrl", c.getCoverUrl());
            m.put("name", c.getTitle());
            m.put("age", null);
            m.put("gender", null);
            m.put("floorNumber", c.getFloorNumber());  // ✅ 층수 추가!

            // ✅ 태그 3개 표시
            List<UserTagDTO> tags = sharehouseService.selectSharehouseTags(c.getHouseId());
            m.put("tag1", (tags != null && tags.size() > 0) ? tags.get(0).getTagName() : null);
            m.put("tag2", (tags != null && tags.size() > 1) ? tags.get(1).getTagName() : null);
            m.put("tag3", (tags != null && tags.size() > 2) ? tags.get(2).getTagName() : null);

            return m;
        }).collect(Collectors.toList());

        log.info("{}.getUserList End!", this.getClass().getName());
        return rList;
    }

    @GetMapping(value = "/list", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> list(
            @RequestParam(defaultValue = "0") int offset,
            @RequestParam(defaultValue = "15") int pageSize) {

        log.info("=== 쉐어하우스 목록 조회 ===");
        log.info("offset: {}, pageSize: {}", offset, pageSize);

        List<SharehouseCardDTO> cards = sharehouseService.listCards(offset, pageSize, null, null, null);

        List<Map<String, Object>> items = cards.stream().map(c -> {
            Map<String, Object> m = new HashMap<>();
            m.put("userId", c.getHouseId());
            m.put("houseId", c.getHouseId());  // ✅ houseId도 추가
            m.put("profileImgUrl", c.getCoverUrl());
            m.put("name", c.getTitle());
            m.put("floorNumber", c.getFloorNumber());  // ✅ 층수 추가!

            // ✅ 태그 3개 표시
            List<UserTagDTO> tags = sharehouseService.selectSharehouseTags(c.getHouseId());
            m.put("tag1", (tags != null && tags.size() > 0) ? tags.get(0).getTagName() : null);
            m.put("tag2", (tags != null && tags.size() > 1) ? tags.get(1).getTagName() : null);
            m.put("tag3", (tags != null && tags.size() > 2) ? tags.get(2).getTagName() : null);

            // ✅ 로깅 추가
            log.info("카드 ID: {}, 층수: {}, 태그: {}, {}, {}",
                    c.getHouseId(),
                    c.getFloorNumber(),
                    m.get("tag1"), m.get("tag2"), m.get("tag3"));

            return m;
        }).collect(Collectors.toList());

        boolean lastPage = items.size() < pageSize;

        log.info("총 {}개 카드 반환", items.size());

        return Map.of("items", items, "lastPage", lastPage);
    }

    // ✅ 특정 항목의 태그 3개 + 기타정보 조회 API – 룸메이트 /{userId}/info와 동일
    @GetMapping("/{userId}/info")
    @ResponseBody
    public Map<String, Object> getRoommateInfo(@PathVariable String userId) {
        log.info("getRoommateInfo called for userId={}", userId);

        Long houseId;
        try { houseId = Long.valueOf(userId); }
        catch (Exception e) { return Map.of("tag1", null, "tag2", null, "tag3", null, "gender", null); }

        List<UserTagDTO> tags = sharehouseService.selectSharehouseTags(houseId);
        String tag1 = (tags != null && tags.size() > 0) ? tags.get(0).getTagName() : null;
        String tag2 = (tags != null && tags.size() > 1) ? tags.get(1).getTagName() : null;
        String tag3 = (tags != null && tags.size() > 2) ? tags.get(2).getTagName() : null;

        return Map.of("tag1", tag1, "tag2", tag2, "tag3", tag3, "gender", null);
    }

    @GetMapping("/sharehouseDetail")
    public String sharehouseDetail(UserProfileDTO pDTO, org.springframework.ui.Model model) {
        String userId = pDTO.getUserId();
        log.info("sharehouseDetail called with userId={}", userId);

        Long houseId;
        try {
            houseId = Long.valueOf(userId);
        } catch (Exception e) {
            houseId = 1L;
        }

        // ✅ 모두 Service를 통해 조회
        Map<String, Object> detail = sharehouseService.getDetail(houseId);
        List<Map<String, Object>> images = sharehouseService.selectSharehouseImages(houseId);
        List<UserTagDTO> tags = sharehouseService.selectSharehouseTags(houseId);

        detail.put("images", images);
        detail.put("tags", tags);

        log.info("이미지 개수: {}", images != null ? images.size() : 0);
        log.info("태그 개수: {}", tags != null ? tags.size() : 0);

        model.addAttribute("user", detail);

        return "sharehouse/sharehouseDetail";
    }

    // ✅ 전체 태그 목록 조회 (룸메이트와 완전 동일)
    @GetMapping("/tagAll")
    @ResponseBody
    public List<TagDTO> tagAll() throws Exception {
        log.info("{}.tagAll Start!", this.getClass().getName());

        List<TagDTO> rList = sharehouseService.getAllTags();

        log.info("{}.tagAll End!", this.getClass().getName());

        return rList;
    }

    // ✅ 태그 저장 API (룸메이트와 완전 동일)
    @PostMapping("/saveSharehouseTags")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveSharehouseTags(
            @RequestBody Map<String, Object> requestBody,
            HttpSession session) {

        log.info("{}.saveSharehouseTags Start!", this.getClass().getName());

        String userId = (String) session.getAttribute("SS_USER_ID");
        if (userId == null || userId.isBlank()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("success", false, "message", "로그인이 필요합니다."));
        }

        try {
            Long houseId = Long.valueOf(requestBody.get("houseId").toString());
            List<Integer> tagList = (List<Integer>) requestBody.get("tagList");

            if (tagList == null || tagList.isEmpty()) {
                return ResponseEntity.ok(Map.of("success", false, "message", "태그를 선택해주세요."));
            }

            int result = sharehouseService.saveSharehouseTags(houseId, tagList);

            log.info("{}.saveSharehouseTags End!", this.getClass().getName());

            if (result > 0) {
                return ResponseEntity.ok(Map.of("success", true));
            } else {
                return ResponseEntity.ok(Map.of("success", false, "message", "태그 저장 실패"));
            }

        } catch (Exception e) {
            log.error("태그 저장 중 오류", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "message", "서버 오류가 발생했습니다."));
        }
    }

    @GetMapping("/tagSelect")
    public String tagSelect() {
        return "sharehouse/sharehouseTagSelect";
    }

}