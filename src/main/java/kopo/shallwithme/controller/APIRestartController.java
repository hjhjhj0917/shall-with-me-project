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

    // 정책 정보 수동으로 캐싱하는 controller
    @GetMapping("/fetch-policies")
    public String fetchPoliciesGet() {

        log.info("{}.fetchPoliciesGet Start!", this.getClass().getName());

        try {
            youthPolicyService.fetchAndSavePolicies();

            log.info("{}.fetchPoliciesGet End!", this.getClass().getName());

            return "정책 데이터를 성공적으로 갱신했습니다.";
        } catch (Exception e) {
            log.error("정책 갱신 중 오류 발생", e);
            log.info("{}.fetchPoliciesGet End!", this.getClass().getName());

            return "정책 갱신 중 오류: " + e.getMessage();
        }
    }
}
