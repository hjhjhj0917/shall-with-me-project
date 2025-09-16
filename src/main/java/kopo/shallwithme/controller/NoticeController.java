package kopo.shallwithme.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.shallwithme.dto.YouthPolicyDTO;
import kopo.shallwithme.service.IYouthPolicyService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@RequiredArgsConstructor
@Controller
@RequestMapping("/notice")
public class NoticeController {

    private final IYouthPolicyService youthPolicyService;

    @GetMapping("/noticeList")
    public String noticeList(@ModelAttribute YouthPolicyDTO dto, ModelMap model) throws Exception {
        int page = Math.max(dto.getPage(), 1);
        int size = Math.max(dto.getSize(), 1);

        List<YouthPolicyDTO> policies = youthPolicyService.getPolicies(page, size);
        int totalCount = youthPolicyService.getTotalPolicyCount();
        int totalPages = (int) Math.ceil((double) totalCount / size);

        ObjectMapper objectMapper = new ObjectMapper();
        String policiesJson = objectMapper.writeValueAsString(policies);

        model.addAttribute("policiesJson", policiesJson);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);

        return "notice/noticeList";
    }
}
