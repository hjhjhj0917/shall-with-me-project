package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.service.impl.UserInfoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RequestMapping(value = "/user")
@RequiredArgsConstructor
@Controller
public class UserInfoController {

    private final UserInfoService userInfoService;

    @GetMapping(value = "userTagSelect") // /WEB-INF/views/user/index.jsp 로 이동
    public String userTagSelect() {

        return "user/userTagSelect";
    }

    @GetMapping("/") // /WEB-INF/views/index.jsp 로 이동
    public String index() {

        return "index";
    }

    @PostMapping("saveTags")
    @ResponseBody
    public Map<String, Object> saveUserTags(@RequestBody Map<String, String> tags, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 예제: 세션에서 로그인된 사용자 ID 가져오기 (임시로 test 사용 중)
            String userId = (String) session.getAttribute("userId");
            if (userId == null) userId = "test"; // 테스트용

            userInfoService.saveUserTags(userId, tags);
            response.put("message", "태그가 성공적으로 저장되었습니다.");
        } catch (Exception e) {
            response.put("message", "저장 실패: " + e.getMessage());
        }
        return response;
    }
}

