package kopo.shallwithme.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@Slf4j
@RequestMapping("/roommate")
@RequiredArgsConstructor
@Controller
public class RoommateController {

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
