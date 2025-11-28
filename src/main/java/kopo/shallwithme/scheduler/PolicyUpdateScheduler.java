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

    @Scheduled(cron = "0 0 5 * * *")
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
