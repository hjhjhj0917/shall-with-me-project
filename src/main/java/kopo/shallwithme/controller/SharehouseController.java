package kopo.shallwithme.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping(value = "/sharehouse")
@RequiredArgsConstructor
@Controller
public class SharehouseController {
    @GetMapping(value = "sharehouseReg")
    public String sharehouseReg() {

        return "sharehouse/sharehouseReg";
    }
    @GetMapping("/sharehouseMain") // 아무거나 가능 알아볼수있게 적을것 (만들때)
    public String sharehouseMain() {
        return "sharehouse/sharehouseMain"; // 실제경로
    }

    // ★ 무한 스크롤 목록 API (JSON)
    @GetMapping(value = "/list", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> list(@RequestParam(defaultValue = "1") int page) {
        // 페이지당 8개 더미 데이터
        List<Map<String, Object>> items = new ArrayList<>();
        for (int i = 0; i < 8; i++) {
            int id = page * 100 + (i + 1); // 예: page=2 -> 201~208
            Map<String, Object> it = new HashMap<>();
            it.put("id", id);
            it.put("imageUrl", "/images/noimg.png"); // 기본 이미지
            it.put("location", "송파구");
            it.put("moveInText", "즉시");
            it.put("priceText", "월세 55");
            items.add(it);
        }
        boolean lastPage = (page >= 3); // 3페이지에서 끝났다고 가정
        return Map.of("items", items, "lastPage", lastPage);
    }
}
