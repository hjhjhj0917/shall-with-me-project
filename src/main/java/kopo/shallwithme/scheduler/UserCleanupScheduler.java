package kopo.shallwithme.scheduler;

import kopo.shallwithme.service.IMyPageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserCleanupScheduler {

    private final IMyPageService myPageService;

    @Scheduled(cron = "0 0 4 * * *")
    public void cleanupDeactivatedUsers() {
        log.info(this.getClass().getName() + ".cleanupDeactivatedUsers Start!");

        try {
            int deletedCount = myPageService.hardDeleteDeactivatedUsers();

            if (deletedCount > 0) {
                log.info("Permanently deleted " + deletedCount + " deactivated user(s).");
            } else {
                log.info("No users to clean up.");
            }
        } catch (Exception e) {
            log.error("Error during scheduled user cleanup", e);
        }

        log.info(this.getClass().getName() + ".cleanupDeactivatedUsers End!");
    }
}

