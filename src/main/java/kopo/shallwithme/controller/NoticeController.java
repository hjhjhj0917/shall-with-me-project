package kopo.shallwithme.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.shallwithme.dto.YouthPolicyDTO;
import kopo.shallwithme.service.impl.NoticeService;
import kopo.shallwithme.service.impl.YouthPolicyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.text.StringEscapeUtils;
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
    private final NoticeService noticeService;


    @GetMapping("/noticeList")
    public String noticeList(ModelMap model) throws Exception {
        log.info("{}.noticeList Start!", this.getClass().getName());

        List<YouthPolicyDTO> policies = youthPolicyService.getPolicies();

        ObjectMapper objectMapper = new ObjectMapper();
        String policiesJson = objectMapper.writeValueAsString(policies);

        model.addAttribute("policiesJson", policiesJson);
        model.addAttribute("totalCount", policies.size());

        log.info("{}.noticeList End!", this.getClass().getName());

        return "notice/noticeList";
    }


    @GetMapping("/noticeDetail")
    public String noticeDetail(YouthPolicyDTO pDTO, ModelMap model) throws Exception {
        log.info("{}.noticeDetail Start!", this.getClass().getName());

        YouthPolicyDTO rDTO = noticeService.getPolicyById(pDTO);
        log.info("정책 상세정보 rDTO : {}", rDTO);

        String policyJson = new ObjectMapper().writeValueAsString(rDTO);

        String safeJson = StringEscapeUtils.escapeEcmaScript(policyJson);

        model.addAttribute("policyJson", safeJson);

        log.info("{}.noticeDetail End!", this.getClass().getName());
        return "notice/noticeDetail";
    }

}
