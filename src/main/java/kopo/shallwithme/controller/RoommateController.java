package kopo.shallwithme.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.service.impl.RoommateService;
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
@RequestMapping(value = "/roommate")
@RequiredArgsConstructor
@Controller
public class RoommateController {

    private final RoommateService roommateService;
    private final UserInfoService userInfoService;
    private final AwsS3Service awsS3Service; // ✅ AWS 서비스 주입 추가

    // ❌ [삭제됨] NCP 관련 @Value 설정들 모두 제거
    // @Value("${ncp.object-storage.endpoint}") ...
    // @Value("${ncp.object-storage.region}") ...
    // @Value("${ncp.object-storage.access-key}") ...
    // @Value("${ncp.object-storage.secret-key}") ...
    // @Value("${ncp.object-storage.bucket-name}") ...
    // @Value("${ncp.object-storage.folder}") ...

    @GetMapping("/roommateReg")
    public String roommateReg() {
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        var req = attrs.getRequest();
        HttpSession session = req.getSession(false);

        String userId = (session != null) ? (String) session.getAttribute("SS_USER_ID") : "";
        String userName = (session != null) ? (String) session.getAttribute("SS_USER_NAME") : "";

        // 태그 조회 (DTO에 tagName 포함)
        List<UserTagDTO> userTags = roommateService.getUserTagsByUserId(userId);
        if (userTags == null) userTags = List.of(); // NPE 방지

        // ✅ tag_name만 추출 (중복 제거 원하면 .distinct() 추가)
        List<String> userTagNames = userTags.stream()
                .map(UserTagDTO::getTagName)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        // JSP에서 사용할 값
        req.setAttribute("userTags", userTags);
        req.setAttribute("userTagNames", userTagNames);
        req.setAttribute("SS_USER_NAME", userName);

        return "roommate/roommateReg";
    }

    // ✅ 저장 처리
    @PostMapping("/register")
    @ResponseBody
    public ResponseEntity<?> registerProfile(@RequestParam(value = "profileImage", required = false) MultipartFile profileImage,
                                             @RequestParam(value = "introduction", required = false) String introduction,
                                             HttpSession session) {

        log.info("{}.registerProfile Start!", this.getClass().getName());

        String userId = (session != null) ? (String) session.getAttribute("SS_USER_ID") : null;
        if (userId == null || userId.isBlank()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("result", "fail", "msg", "로그인이 필요합니다."));
        }

        try {
            String imageUrl = null;
            if (profileImage != null && !profileImage.isEmpty()) {
                // ✅ [변경] AWS S3 서비스 사용
                imageUrl = awsS3Service.uploadFile(profileImage);
            }

            roommateService.saveUserProfile(userId, introduction, imageUrl);
            session.setAttribute("SS_USER_PROFILE_IMG_URL", imageUrl);

            return ResponseEntity.ok(Map.of("result", "success"));

        } catch (Exception e) {
            log.error("프로필 저장 실패", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("result", "fail", "msg", "서버 오류로 저장에 실패했습니다."));
        }
    }

    // ❌ [삭제됨] private String saveProfileImage(MultipartFile file) throws IOException { ... }
    // AWS S3 서비스가 이 역할을 대신합니다.

    @GetMapping("/roommateMain")
    public String roommateMain() {
        return "roommate/roommateMain";
    }

    // 룸메이트 메인 페이지 회원 리스트 불러오기
    @GetMapping(value = "/userList", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public List<Map<String, Object>> getUserList(@RequestParam(defaultValue = "1") int page) {
        log.info("{}.getUserList Start!", this.getClass().getName());

        List<Map<String, Object>> rList = roommateService.getRoommateList(page);

        log.info("{}.getUserList End!", this.getClass().getName());

        return rList; // tag1, tag2, gender 포함됨
    }


    // ☆ 무한 스크롤 목록 API (JSON)
    @GetMapping(value = "/list", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> list(@RequestParam(defaultValue = "1") int page) {

        int safePage = Math.max(page, 1);

        // ✅ Service에서 알아서 pageSize/offset 처리
        List<Map<String, Object>> items = roommateService.getRoommateList(safePage);

        // 다음 페이지가 없으면 lastPage = true
        boolean lastPage = items.isEmpty();

        return Map.of("items", items, "lastPage", lastPage);
    }


    // ✅ 특정 유저의 태그 2개 + 성별 조회 API
    @GetMapping("/{userId}/info")
    @ResponseBody
    public Map<String, Object> getRoommateInfo(@PathVariable String userId) {
        log.info("getRoommateInfo called for userId={}", userId);

        // Service 호출 → {tag1, tag2, gender} 반환
        return roommateService.getDisplayInfo(userId);
    }

    // ✅ 25-09-17 추가
    @GetMapping("/roommateDetail")
    public String roommateDetail(UserProfileDTO pDTO, org.springframework.ui.Model model) {
        String userId = pDTO.getUserId();  // ?userId=xxx 로 전달됨

        log.info("roommateDetail called with userId={}", userId);

        UserProfileDTO user = roommateService.getUserProfile(userId);
        model.addAttribute("user", user);

        return "roommate/roommateDetail";
    }

    @PostMapping("/searchByTags")
    @ResponseBody
    public TagDTO searchByTags(@RequestBody TagDTO tagDTO) {
        log.info("{}.searchByTags Start!", this.getClass().getName());

        log.info("searchByTags called with location={}, tagGroupMap={}, page={}, pageSize={}",
                tagDTO.getLocation(), tagDTO.getTagGroupMap(), tagDTO.getPage(), tagDTO.getPageSize());

        TagDTO result = roommateService.searchUsersByTags(tagDTO);

        log.info("최종 응답 유저 리스트 크기: {}", result.getUsers() == null ? "null" : result.getUsers().size());

        log.info("{}.searchByTags End!", this.getClass().getName());

        return result;
    }

    @GetMapping("/tagAll")
    @ResponseBody
    public List<TagDTO> tagAll() throws Exception{
        log.info("{}.tagAll Start!", this.getClass().getName());

        List<TagDTO> rList = roommateService.getAllTags();

        log.info("{}.tagAll End!", this.getClass().getName());

        return rList;
    }

}