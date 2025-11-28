package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.service.impl.AwsS3Service;
import kopo.shallwithme.service.impl.RoommateService;
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

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Slf4j
@RequestMapping(value = "/roommate")
@RequiredArgsConstructor
@Controller
public class RoommateController {


    private final RoommateService roommateService;
    private final AwsS3Service awsS3Service;


    @GetMapping("/roommateReg")
    public String roommateReg() {
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        var req = attrs.getRequest();
        HttpSession session = req.getSession(false);

        String userId = (session != null) ? (String) session.getAttribute("SS_USER_ID") : "";
        String userName = (session != null) ? (String) session.getAttribute("SS_USER_NAME") : "";

        List<UserTagDTO> userTags = roommateService.getUserTagsByUserId(userId);
        if (userTags == null) userTags = List.of();

        List<String> userTagNames = userTags.stream()
                .map(UserTagDTO::getTagName)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        req.setAttribute("userTags", userTags);
        req.setAttribute("userTagNames", userTagNames);
        req.setAttribute("SS_USER_NAME", userName);

        return "roommate/roommateReg";
    }


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


    // 룸메이트 메인 페이지 회원 리스트 불러오기
    @GetMapping(value = "/userList", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public List<Map<String, Object>> getUserList(@RequestParam(defaultValue = "1") int page) {
        log.info("{}.getUserList Start!", this.getClass().getName());

        List<Map<String, Object>> rList = roommateService.getRoommateList(page);

        log.info("{}.getUserList End!", this.getClass().getName());

        return rList;
    }


    @GetMapping(value = "/list", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> list(@RequestParam(defaultValue = "1") int page) {

        int safePage = Math.max(page, 1);

        List<Map<String, Object>> items = roommateService.getRoommateList(safePage);

        boolean lastPage = items.isEmpty();

        return Map.of("items", items, "lastPage", lastPage);
    }


    @GetMapping("/{userId}/info")
    @ResponseBody
    public Map<String, Object> getRoommateInfo(@PathVariable String userId) {
        log.info("getRoommateInfo called for userId={}", userId);

        return roommateService.getDisplayInfo(userId);
    }


    @GetMapping("/roommateDetail")
    public String roommateDetail(UserProfileDTO pDTO, org.springframework.ui.Model model) {
        String userId = pDTO.getUserId();

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


    @GetMapping("/roommateMain")
    public String roommateMain() {

        return "roommate/roommateMain";
    }
}