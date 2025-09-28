package kopo.shallwithme.scheduler;

import kopo.shallwithme.service.impl.YouthPolicyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class PolicyUpdateScheduler {

    private final YouthPolicyService youthPolicyService;

    /**
     * 매일 새벽 5시에 실행되어, 외부 API로부터 최신 청년 정책 데이터를 가져와 DB에 저장합니다.
     */
    @Scheduled(cron = "0 0 5 * * *") // 매일 새벽 5시 0분 0초
    public void updatePolicies() {
        log.info(this.getClass().getName() + ".updatePolicies Start!");
        try {
            youthPolicyService.fetchAndSavePolicies();
        } catch (Exception e) {
            log.error("Error during scheduled policy update", e);
        }
        log.info(this.getClass().getName() + ".updatePolicies End!");
    }
}
