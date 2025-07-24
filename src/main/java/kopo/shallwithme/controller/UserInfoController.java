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

    @GetMapping(value = "userTagSelect")
    public String userTagSelect() {
        return "user/userTagSelect";
    }

    @PostMapping("saveTags")
    @ResponseBody
    public Map<String, Object> saveUserTags(@RequestBody Map<String, String> tags, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        try {

            String userId = "test";

            userInfoService.saveUserTags(userId, tags); // Service에 위임
            response.put("message", "태그가 성공적으로 저장되었습니다.");
        } catch (Exception e) {
            response.put("message", "저장 실패: " + e.getMessage());
        }
        return response;
    }
}
