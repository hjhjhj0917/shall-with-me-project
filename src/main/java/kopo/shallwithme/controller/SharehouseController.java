package kopo.shallwithme.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.service.ISharehouseService;
import kopo.shallwithme.service.impl.UserInfoService;
import kopo.shallwithme.service.impl.AwsS3Service; // ✅ AWS 서비스 import 추가
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@RequestMapping("/sharehouse")
@RequiredArgsConstructor
@Controller
public class SharehouseController {

    private final ISharehouseService sharehouseService;
    private final UserInfoService userInfoService;
    private final AwsS3Service awsS3Service; // ✅ AWS 서비스 주입 추가

    // ❌ [삭제됨] NCP 관련 @Value 설정들 모두 제거
    // @Value("${ncp.object-storage.endpoint}") private String endpoint;
    // @Value("${ncp.object-storage.region}") private String region;
    // @Value("${ncp.object-storage.access-key}") private String accessKey;
    // @Value("${ncp.object-storage.secret-key}") private String secretKey;
    // @Value("${ncp.object-storage.bucket-name}") private String bucketName;
    // @Value("${ncp.object-storage.folder}") private String folder;

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
            @RequestParam(value = "floorNumber", required = false) String floorNumber,
            @RequestParam(value = "addr1", required = false) String addr1,
            @RequestParam(value = "addr2", required = false) String addr2,
            HttpSession session
    ){
        // ========================================
        // ✅ 요청 받음 로그
        // ========================================
        log.info("========================================");
        log.info("POST /sharehouse/register 요청 받음!");
        log.info("========================================");

        String userId = (session != null) ? (String) session.getAttribute("SS_USER_ID") : null;

        log.info("세션 userId: {}", userId);
        log.info("houseName: {}", houseName);
        log.info("introduction: {}", introduction);
        log.info("tagListJson: {}", tagListJson);
        log.info("floorNumber: {}", floorNumber);
        log.info("addr1: {}", addr1);
        log.info("addr2: {}", addr2);
        log.info("thumbnail: {}", thumbnail != null ? thumbnail.getOriginalFilename() : "null");
        log.info("추가 이미지 개수: {}", images != null ? images.size() : 0);

        if (userId == null || userId.isBlank()) {
            log.error("❌ 로그인 필요 - userId가 null 또는 비어있음");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("result", 0, "msg", "로그인이 필요합니다."));
        }

        try {
            log.info("=== 쉐어하우스 등록 처리 시작 ===");

            // ========================================
            // ✅ 1. 파일 개수 검증 (최대 5개: 썸네일 1개 + 추가이미지 4개)
            // ========================================
            int totalFiles = 0;

            // 썸네일 카운트
            if (thumbnail != null && !thumbnail.isEmpty()) {
                totalFiles++;
            }

            // 추가 이미지 카운트 (빈 파일 제외)
            if (images != null && !images.isEmpty()) {
                totalFiles += (int) images.stream()
                        .filter(file -> file != null && !file.isEmpty())
                        .count();
            }

            log.info("✅ 파일 개수 검증: 총 {}개", totalFiles);

            if (totalFiles > 5) {
                log.error("❌ 파일 개수 초과: {}개 (최대 5개)", totalFiles);
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("result", 0, "msg", "최대 5개 파일만 업로드 가능합니다."));
            }

            if (totalFiles == 0) {
                log.error("❌ 업로드된 파일이 없음");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("result", 0, "msg", "최소 1개 이상의 이미지를 업로드해주세요."));
            }

            // ========================================
            // ✅ 2. 개별 파일 크기 검증 (최대 10MB)
            // ========================================
            long maxSize = 10 * 1024 * 1024; // 10MB

            // 썸네일 크기 체크
            if (thumbnail != null && !thumbnail.isEmpty() && thumbnail.getSize() > maxSize) {
                long sizeMB = thumbnail.getSize() / 1024 / 1024;
                log.error("❌ 썸네일 크기 초과: {}MB (최대 10MB)", sizeMB);
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("result", 0, "msg", "썸네일은 10MB 이하여야 합니다. (현재: " + sizeMB + "MB)"));
            }

            // 추가 이미지 크기 체크
            if (images != null) {
                for (int i = 0; i < images.size(); i++) {
                    MultipartFile image = images.get(i);
                    if (image != null && !image.isEmpty() && image.getSize() > maxSize) {
                        long sizeMB = image.getSize() / 1024 / 1024;
                        log.error("❌ 이미지 {}번 크기 초과: {}MB (최대 10MB)", i + 1, sizeMB);
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("result", 0, "msg", (i + 1) + "번 이미지는 10MB 이하여야 합니다. (현재: " + sizeMB + "MB)"));
                    }
                }
            }

            log.info("✅ 파일 크기 검증 통과");

            // ========================================
            // ✅ 3. 이미지 업로드 시작 (AWS S3 사용)
            // ========================================
            log.info("=== 이미지 업로드 시작 ===");
            List<String> imageUrls = new ArrayList<>();

            // 썸네일 업로드
            if (thumbnail != null && !thumbnail.isEmpty()) {
                log.info("썸네일 업로드 중...");
                String thumbnailUrl = awsS3Service.uploadFile(thumbnail); // ✅ 변경
                imageUrls.add(thumbnailUrl);
                log.info("✅ 썸네일 업로드 완료: {}", thumbnailUrl);
            }

            // 추가 이미지 업로드
            if (images != null) {
                for (int i = 0; i < images.size(); i++) {
                    MultipartFile image = images.get(i);
                    if (image != null && !image.isEmpty()) {
                        log.info("이미지 {}번 업로드 중...", i + 1);
                        String imageUrl = awsS3Service.uploadFile(image); // ✅ 변경
                        imageUrls.add(imageUrl);
                        log.info("✅ 이미지 {}번 업로드 완료: {}", i + 1, imageUrl);
                    }
                }
            }

            log.info("✅ 이미지 업로드 완료! 총 {}개", imageUrls.size());

            // ========================================
            // ✅ 4. DB 저장
            // ========================================
            log.info("=== DB 저장 시작 ===");
            Long houseId = sharehouseService.registerHouseWithImages(
                    userId,
                    (houseName != null && !houseName.isBlank()) ? houseName : "제목 없음",
                    (introduction != null && !introduction.isBlank()) ? introduction : "",
                    (addr1 != null && !addr1.isBlank()) ? addr1 : "",
                    (addr2 != null && !addr2.isBlank()) ? addr2 : "",
                    imageUrls,
                    floorNumber
            );

            log.info("✅ DB 저장 완료! houseId={}", houseId);

            // ========================================
            // ✅ 5. 태그 저장
            // ========================================
            if (tagListJson != null && !tagListJson.isBlank()) {
                log.info("=== 태그 저장 시작 ===");
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
                    log.error("❌ 태그 저장 중 오류", e);
                }
            }

            log.info("========================================");
            log.info("✅ 쉐어하우스 등록 완전 완료! houseId={}", houseId);
            log.info("========================================");

            return ResponseEntity.ok(Map.of(
                    "result", 1,
                    "data", Map.of("shId", houseId)
            ));

        } catch (Exception e) {
            log.error("========================================");
            log.error("❌ 쉐어하우스 등록 중 오류 발생!");
            log.error("에러 타입: {}", e.getClass().getName());
            log.error("에러 메시지: {}", e.getMessage());

            Throwable root = e;
            while (root.getCause() != null && root.getCause() != root) {
                root = root.getCause();
            }
            log.error("Root cause: {} - {}",
                    root.getClass().getSimpleName(),
                    root.getMessage() != null ? root.getMessage() : "메시지 없음");
            log.error("전체 스택 트레이스:", e);
            log.error("========================================");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of(
                            "result", 0,
                            "msg", "DB오류: " +
                                    root.getClass().getSimpleName() + " - " +
                                    (root.getMessage() != null ? root.getMessage() : "")
                    ));
        }
    }

    // ❌ [삭제됨] private String saveProfileImage(MultipartFile file) throws IOException { ... }
    // AWS S3 서비스가 이 역할을 대신합니다.

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
            m.put("houseId", c.getHouseId());
            m.put("name", c.getTitle());
            m.put("profileImgUrl", c.getCoverUrl());

            List<UserTagDTO> tags = c.getTags();
            if (tags != null && !tags.isEmpty()) {
                m.put("tag1", tags.size() > 0 ? tags.get(0).getTagName() : null);
                m.put("tag2", tags.size() > 1 ? tags.get(1).getTagName() : null);
            } else {
                m.put("tag1", null);
                m.put("tag2", null);
            }
            m.put("gender", "");

            return m;
        }).collect(Collectors.toList());

        log.info("{}.getUserList End!", this.getClass().getName());

        return rList;
    }

    @GetMapping(value = "/list", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> list(@RequestParam(defaultValue = "1") int page) {
        int safePage = Math.max(page, 1);
        int pageSize = 12;
        int offset = (safePage - 1) * pageSize;

        List<SharehouseCardDTO> cards = sharehouseService.listCards(offset, pageSize, null, null, null);

        List<Map<String, Object>> items = cards.stream().map(c -> {
            Map<String, Object> m = new HashMap<>();
            m.put("userId", c.getHouseId());
            m.put("houseId", c.getHouseId());
            m.put("name", c.getTitle());
            m.put("profileImgUrl", c.getCoverUrl());

            List<UserTagDTO> tags = c.getTags();
            if (tags != null && !tags.isEmpty()) {
                m.put("tag1", tags.size() > 0 ? tags.get(0).getTagName() : null);
                m.put("tag2", tags.size() > 1 ? tags.get(1).getTagName() : null);
            }
            m.put("gender", "");
            return m;
        }).collect(Collectors.toList());

        boolean lastPage = items.isEmpty();
        return Map.of("items", items, "lastPage", lastPage);
    }

    @GetMapping(value = "/search", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> search(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "pageSize", defaultValue = "12") int pageSize,
            @RequestParam(value = "location", required = false) String location,
            @RequestParam(value = "tagIds", required = false) List<Integer> tagIds,
            @RequestParam(value = "maxRent", required = false) Integer maxRent
    ) {
        log.info("Sharehouse search - page={}, pageSize={}, location={}, tagIds={}, maxRent={}",
                page, pageSize, location, tagIds, maxRent);

        int safePage = Math.max(page, 1);
        int safePageSize = (pageSize <= 0) ? 12 : pageSize;
        int offset = (safePage - 1) * safePageSize;

        List<SharehouseCardDTO> cards = sharehouseService.listCards(offset, safePageSize, location, tagIds, maxRent);

        List<Map<String, Object>> items = cards.stream().map(c -> {
            Map<String, Object> m = new HashMap<>();
            m.put("userId", c.getHouseId());
            m.put("houseId", c.getHouseId());
            m.put("name", c.getTitle());
            m.put("profileImgUrl", c.getCoverUrl());
            m.put("address", c.getAddress());
            m.put("detailAddress", c.getDetailAddress());
            m.put("floorNumber", c.getFloorNumber());

            List<UserTagDTO> tags = c.getTags();
            if (tags != null && !tags.isEmpty()) {
                m.put("tag1", tags.size() > 0 ? tags.get(0).getTagName() : null);
                m.put("tag2", tags.size() > 1 ? tags.get(1).getTagName() : null);
            }
            return m;
        }).collect(Collectors.toList());

        boolean lastPage = items.size() < safePageSize;
        return Map.of(
                "items", items,
                "lastPage", lastPage,
                "page", safePage,
                "pageSize", safePageSize
        );
    }

    @GetMapping("/{houseId}/info")
    @ResponseBody
    public Map<String, Object> getSharehouseInfo(@PathVariable("houseId") Long houseId) {
        log.info("getSharehouseInfo called for houseId={}", houseId);

        SharehouseCardDTO card = sharehouseService.getCardById(houseId);
        if (card == null) {
            return Collections.emptyMap();
        }

        Map<String, Object> result = new HashMap<>();
        result.put("houseId", card.getHouseId());
        result.put("title", card.getTitle());
        result.put("subText", card.getSubText());
        result.put("coverUrl", card.getCoverUrl());
        result.put("address", card.getAddress());
        result.put("detailAddress", card.getDetailAddress());
        result.put("floorNumber", card.getFloorNumber());

        List<UserTagDTO> tags = card.getTags();
        if (tags != null && !tags.isEmpty()) {
            result.put("tag1", tags.size() > 0 ? tags.get(0).getTagName() : null);
            result.put("tag2", tags.size() > 1 ? tags.get(1).getTagName() : null);
        }

        return result;
    }

    @GetMapping("/sharehouseDetail")
    public String sharehouseDetail(UserProfileDTO pDTO, org.springframework.ui.Model model) {
        String userId = pDTO.getUserId();
        log.info("=== sharehouseDetail 시작 ===");
        log.info("요청 userId: {}", userId);

        Long houseId;
        try {
            houseId = Long.valueOf(userId);
        } catch (Exception e) {
            log.error("userId 파싱 실패: {}", userId);
            return "error/notFound";
        }

        // 1단계: 기본 정보 조회
        Map<String, Object> detail = sharehouseService.getDetail(houseId);
        log.info("=== DB 조회 결과 ===");
        log.info("detail 전체: {}", detail);

        List<Map<String, Object>> images = sharehouseService.selectSharehouseImages(houseId);
        List<UserTagDTO> tags = sharehouseService.selectSharehouseTags(houseId);

        detail.put("images", images);
        detail.put("tags", tags);

        // 2단계: regId 처리
        Object regIdObj = detail.get("regId");
        log.info("=== regId 처리 ===");
        log.info("DB에서 가져온 regIdObj: {}", regIdObj);

        String regId = null;
        if (regIdObj != null) {
            regId = String.valueOf(regIdObj).trim();
            log.info("String 변환 후 regId: '{}'", regId);

            if (regId.equals("null") || regId.isBlank()) {
                log.warn("regId가 'null' 문자열이거나 비어있음");
                regId = null;
            }
        }

        detail.put("regId", regId);
        log.info("detail에 설정된 최종 regId: '{}'", regId);

        // 3단계: 작성자 프로필 조회
        if (regId != null && !regId.isEmpty()) {
            log.info("=== 작성자 프로필 조회 시작 ===");
            log.info("조회할 regId: '{}'", regId);

            try {
                UserProfileDTO profileParam = new UserProfileDTO();
                profileParam.setUserId(regId);

                log.info("UserInfoService 호출 전");
                UserProfileDTO hostProfile = userInfoService.findUserProfileByUserId(profileParam);
                log.info("UserInfoService 호출 후");

                if (hostProfile != null) {
                    log.info("조회된 프로필: userName={}", hostProfile.getUserName());

                    String profileUrl = hostProfile.getProfileImageUrl();
                    if (profileUrl != null && !profileUrl.isBlank()) {
                        detail.put("hostProfileUrl", profileUrl);
                        log.info("✅ 프로필 URL 설정 성공: {}", profileUrl);
                    } else {
                        log.warn("⚠️ 프로필 URL이 비어있음");
                        detail.put("hostProfileUrl", null);
                    }

                    detail.put("hostName", hostProfile.getUserName());
                } else {
                    log.warn("❌ hostProfile이 null입니다");
                    detail.put("hostName", "작성자");
                }
            } catch (Exception e) {
                log.error("❌ 작성자 정보 조회 중 오류", e);
                detail.put("hostName", "작성자");
            }
        } else {
            log.warn("❌ regId가 null이거나 비어있어서 프로필 조회 불가");
            detail.put("hostName", "작성자");
        }

        log.info("=== 최종 detail 내용 ===");
        log.info("regId: '{}'", detail.get("regId"));
        log.info("hostName: '{}'", detail.get("hostName"));
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

    @GetMapping("/test")
    @ResponseBody
    public String test() {
        return "SharehouseController is working!";
    }

    /**
     * ✅ 쉐어하우스 정보 수정 페이지 이동
     */
    @GetMapping("/mypage/sharehouseModify")
    public String sharehouseModifyPage(HttpSession session, org.springframework.ui.Model model) {
        String userId = (String) session.getAttribute("SS_USER_ID");

        if (userId == null || userId.isBlank()) {
            log.warn("로그인되지 않은 사용자");
            return "redirect:/user/login";
        }

        log.info("쉐어하우스 수정 페이지 접근: userId={}", userId);
        return "mypage/sharehouseModify";
    }

    /**
     * ✅ 본인의 쉐어하우스 정보 조회 API - 여러 개 조회
     */
    @GetMapping("/getMySharehouse")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getMySharehouse(HttpSession session) {
        String userId = (String) session.getAttribute("SS_USER_ID");

        if (userId == null || userId.isBlank()) {
            log.warn("로그인되지 않은 사용자");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "로그인이 필요합니다."));
        }

        try {
            log.info("본인 쉐어하우스 조회: userId={}", userId);
            List<SharehouseCardDTO> houses = sharehouseService.getSharehouseByUserId(userId);

            if (houses != null && !houses.isEmpty()) {
                List<Map<String, Object>> result = new ArrayList<>();

                for (SharehouseCardDTO house : houses) {
                    Map<String, Object> houseMap = new HashMap<>();
                    houseMap.put("houseId", house.getHouseId());
                    houseMap.put("userId", house.getRegId());
                    houseMap.put("name", house.getTitle());
                    houseMap.put("profileImgUrl", house.getCoverUrl());
                    houseMap.put("floorNumber", house.getFloorNumber());

                    // 태그 정보 추가 (최대 3개)
                    List<UserTagDTO> tags = house.getTags();
                    if (tags != null && !tags.isEmpty()) {
                        houseMap.put("tag1", tags.size() > 0 ? tags.get(0).getTagName() : null);
                        houseMap.put("tag2", tags.size() > 1 ? tags.get(1).getTagName() : null);
                        houseMap.put("tag3", tags.size() > 2 ? tags.get(2).getTagName() : null);
                    }

                    result.add(houseMap);
                }

                log.info("쉐어하우스 {}개 조회 성공", houses.size());
                return ResponseEntity.ok(Map.of("houses", result));
            } else {
                log.info("등록된 쉐어하우스가 없음");
                return ResponseEntity.ok(Map.of("message", "등록된 쉐어하우스가 없습니다."));
            }

        } catch (Exception e) {
            log.error("쉐어하우스 조회 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "조회 실패"));
        }
    }

    /**
     * ✅ 쉐어하우스 삭제 API
     */
    @PostMapping("/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteSharehouse(
            @RequestParam("houseId") Long houseId,
            HttpSession session) {

        Map<String, Object> result = new HashMap<>();
        String userId = (String) session.getAttribute("SS_USER_ID");

        if (userId == null || userId.isBlank()) {
            log.warn("로그인되지 않은 사용자");
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
        }

        try {
            log.info("쉐어하우스 삭제 요청: houseId={}, userId={}", houseId, userId);

            // 본인의 쉐어하우스인지 확인
            SharehouseCardDTO house = sharehouseService.getCardById(houseId);

            if (house == null) {
                log.warn("존재하지 않는 쉐어하우스: houseId={}", houseId);
                result.put("success", false);
                result.put("message", "존재하지 않는 쉐어하우스입니다.");
                return ResponseEntity.ok(result);
            }

            if (!house.getRegId().equals(userId)) {
                log.warn("권한 없음: houseId={}, regId={}, userId={}", houseId, house.getRegId(), userId);
                result.put("success", false);
                result.put("message", "본인의 쉐어하우스만 삭제할 수 있습니다.");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(result);
            }

            // 삭제 실행
            boolean deleted = sharehouseService.deleteSharehouse(houseId);

            if (deleted) {
                log.info("✅ 쉐어하우스 삭제 성공: houseId={}", houseId);
                result.put("success", true);
                result.put("message", "삭제되었습니다.");
            } else {
                log.warn("⚠️ 쉐어하우스 삭제 실패: houseId={}", houseId);
                result.put("success", false);
                result.put("message", "삭제에 실패했습니다.");
            }

        } catch (Exception e) {
            log.error("❌ 쉐어하우스 삭제 중 오류 발생", e);
            result.put("success", false);
            result.put("message", "삭제 중 오류가 발생했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }

        return ResponseEntity.ok(result);
    }
}