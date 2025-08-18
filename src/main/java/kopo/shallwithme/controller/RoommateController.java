package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.service.impl.RoommateService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
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
    public String registerProfile(@RequestParam(value = "profileImage", required = false) MultipartFile profileImage,
                                  @RequestParam(value = "introduction", required = false) String introduction,
                                  HttpSession session) throws Exception {

        String userId = (session != null) ? (String) session.getAttribute("SS_USER_ID") : null;
        if (userId == null || userId.isBlank()) {
            // 로그인 요구 페이지로 리다이렉트(필요시 변경)
            return "redirect:/user/login";
        }

        // 파일 저장 (옵션)
        String imageUrl = null;
        if (profileImage != null && !profileImage.isEmpty()) {
            imageUrl = saveProfileImage(profileImage);
        }

        roommateService.saveUserProfile(userId, introduction, imageUrl);

        // 저장 후 다시 화면으로
        return "redirect:/roommate/roommateReg";
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

        // 브라우저에서 접근 가능한 URL
        return "/uploads/profile/" + filename;
    }

    @GetMapping("/roommateMain")
    public String roommateMain() {
        // 템플릿/뷰 파일: templates/roommate/roommateMain.html (Thymeleaf)
        // 또는 /WEB-INF/views/roommate/roommateMain.jsp (JSP)
        return "roommate/roommateMain";
    }

    // ★ 무한 스크롤 목록 API (JSON)
    @GetMapping(value = "/list", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> list(@RequestParam(defaultValue = "1") int page) {

        int safePage = Math.max(page, 1); // 음수/0 방지

        List<Map<String, Object>> items = new ArrayList<>();
        for (int i = 0; i < 8; i++) {
            int id = safePage * 100 + (i + 1);
            Map<String, Object> it = new HashMap<>();
            it.put("id", id);
            it.put("imageUrl", "/images/noimg.png"); // 공용 이미지 경로
            it.put("location", "송파구");
            it.put("moveInText", "즉시");
            it.put("priceText", "월세 55");
            items.add(it);
        }

        boolean lastPage = (safePage >= 3); // 동일 로직
        return Map.of("items", items, "lastPage", lastPage);
    }

}
