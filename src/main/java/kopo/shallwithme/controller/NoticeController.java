package kopo.shallwithme.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import kopo.shallwithme.dto.YouthPolicyDTO;
import kopo.shallwithme.service.IYouthPolicyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Controller
@RequestMapping("/notice")
@Slf4j
public class NoticeController {

    private final IYouthPolicyService youthPolicyService;

    @GetMapping("/noticeList")
    public String noticeList(@ModelAttribute YouthPolicyDTO dto, ModelMap model) throws Exception {
        log.info("{}.noticeList Start!", this.getClass().getName());

        int page = Math.max(dto.getPage(), 1);
        int size = Math.max(dto.getSize(), 1);

        log.info("page: {}, size: {}", page, size);

        List<YouthPolicyDTO> policies = youthPolicyService.getPolicies(page, size);
        int totalCount = youthPolicyService.getTotalPolicyCount();
        int totalPages = (int) Math.ceil((double) totalCount / size);

        log.info("totalCount: {}, totalPages: {}", totalCount, totalPages);

        ObjectMapper objectMapper = new ObjectMapper();
        String policiesJson = objectMapper.writeValueAsString(policies);

        model.addAttribute("policiesJson", policiesJson);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);

        log.info("{}.noticeList End!", this.getClass().getName());

        return "notice/noticeList";
    }

    @GetMapping("/api")
    @ResponseBody
    public Map<String, Object> getPoliciesApi(HttpServletRequest request) throws Exception {
        int page = 1;
        int size = 10;

        String pageStr = request.getParameter("page");
        String sizeStr = request.getParameter("size");

        log.info("pageStr: " + pageStr);
        log.info("sizeStr: " + sizeStr);

        if (pageStr != null) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {}
        }
        if (sizeStr != null) {
            try {
                size = Integer.parseInt(sizeStr);
                if (size < 1) size = 10;
            } catch (NumberFormatException ignored) {}
        }

        List<YouthPolicyDTO> policies = youthPolicyService.getPolicies(page, size);
        int totalCount = youthPolicyService.getTotalPolicyCount();

        Map<String, Object> result = new HashMap<>();
        result.put("policies", policies);
        result.put("totalCount", totalCount);

        return result;
    }

}
