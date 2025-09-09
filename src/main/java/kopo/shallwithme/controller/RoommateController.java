package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.service.impl.RoommateService;
import kopo.shallwithme.service.impl.UserInfoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@RequestMapping(value = "/roommate")
@RequiredArgsConstructor
@Controller
public class RoommateController {

    private final RoommateService roommateService;
    private final UserInfoService userInfoService;

    @GetMapping("/roommateReg")
    public String roommateReg() {
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        var req = attrs.getRequest();
        HttpSession session = req.getSession(false);

        String userId   = (session != null) ? (String) session.getAttribute("SS_USER_ID")   : "";
        String userName = (session != null) ? (String) session.getAttribute("SS_USER_NAME") : "";

        // 태그 조회 (DTO에 tagName 포함)
        List<UserTagDTO> userTags = roommateService.getUserTagsByUserId(userId);
        if (userTags == null) userTags = List.of(); // NPE 방지

        // ✅ tag_name만 추출 (중복 제거 원하면 .distinct() 추가)
        List<String> userTagNames = userTags.stream()
                .map(UserTagDTO::getTagName)   // <-- 여기 수정!
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
    @ResponseBody // JSON 데이터를 반환하기 위해 이 어노테이션을 추가합니다.
    public ResponseEntity<?> registerProfile(@RequestParam(value = "profileImage", required = false) MultipartFile profileImage,
                                             @RequestParam(value = "introduction", required = false) String introduction,
                                             HttpSession session) {

        log.info("{}.registerProfile Start!", this.getClass().getName());

        String userId = (session != null) ? (String) session.getAttribute("SS_USER_ID") : null;
        if (userId == null || userId.isBlank()) {
            // 로그인되지 않은 경우 401 Unauthorized 에러와 함께 JSON 응답
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("result", "fail", "msg", "로그인이 필요합니다."));
        }

        try {
            String imageUrl = null;
            if (profileImage != null && !profileImage.isEmpty()) {
                imageUrl = saveProfileImage(profileImage); // 이미지 저장 로직
            }

            roommateService.saveUserProfile(userId, introduction, imageUrl); // 프로필 저장 로직

            // 성공 시 "result":"success" 라는 JSON 응답을 보냅니다.
            return ResponseEntity.ok(Map.of("result", "success"));

        } catch (Exception e) {
            // log.error("프로필 저장 실패", e);
            // 서버 처리 중 에러 발생 시 500 Internal Server Error와 함께 JSON 응답
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("result", "fail", "msg", "서버 오류로 저장에 실패했습니다."));
        }
    }

    // 로컬 폴더에 저장하고 /uploads/profile/.. URL 반환
    private String saveProfileImage(MultipartFile file) throws IOException {
        String original = file.getOriginalFilename();
        String ext = "";
        if (original != null) {
            String cleaned = StringUtils.getFilenameExtension(original);
            ext = (cleaned != null && !cleaned.isBlank()) ? "." + cleaned : "";
        }
        String filename = UUID.randomUUID().toString().replace("-", "") + ext;

        Path uploadDir = Paths.get("uploads", "profile");
        Files.createDirectories(uploadDir);

        Path target = uploadDir.resolve(filename);
        Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);

        // 브라우저에서 접근 가능한 URLCHAT_ROOM
        return "/uploads/profile/" + filename;
    }

    @GetMapping("/roommateMain")
    public String roommateMain() {
        // 템플릿/뷰 파일: templates/roommate/roommateMain.html (Thymeleaf)
        // 또는 /WEB-INF/views/roommate/roommateMain.jsp (JSP)
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


    // ★ 무한 스크롤 목록 API (JSON)
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



}
