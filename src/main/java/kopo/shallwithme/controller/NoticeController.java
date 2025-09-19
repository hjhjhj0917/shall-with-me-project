package kopo.shallwithme.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.shallwithme.dto.YouthPolicyDTO;
import kopo.shallwithme.service.impl.YouthPolicyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@RequiredArgsConstructor
@Controller
@RequestMapping("/notice")
@Slf4j
public class NoticeController {

    private final YouthPolicyService youthPolicyService;

    @GetMapping("/noticeList")
    public String noticeList(ModelMap model) throws Exception {
        log.info("{}.noticeList Start!", this.getClass().getName());

        // 전체 정책 데이터 DB에서 불러오기
        List<YouthPolicyDTO> policies = youthPolicyService.getPolicies();

        // JSON 형태로 변환하여 JSP에 넘김
        ObjectMapper objectMapper = new ObjectMapper();
        String policiesJson = objectMapper.writeValueAsString(policies);

        model.addAttribute("policiesJson", policiesJson);
        model.addAttribute("totalCount", policies.size()); // 전체 개수만 전달

        log.info("{}.noticeList End!", this.getClass().getName());

        return "notice/noticeList";
    }
}
