package kopo.shallwithme.controller;

import kopo.shallwithme.service.impl.YouthPolicyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/admin")
public class APIRestartController {

    private final YouthPolicyService youthPolicyService;

    // 수동 실행용 정책 저장 API
    @GetMapping("/fetch-policies")
    public String fetchPoliciesGet() {
        try {
            youthPolicyService.fetchAndSavePolicies();
            return "정책 데이터를 성공적으로 갱신했습니다.";
        } catch (Exception e) {
            log.error("정책 갱신 중 오류 발생", e);
            return "정책 갱신 중 오류: " + e.getMessage();
        }
    }
}
