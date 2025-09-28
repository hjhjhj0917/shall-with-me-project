package kopo.shallwithme.scheduler;

import kopo.shallwithme.service.IMyPageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component // Spring이 이 클래스를 관리하는 Bean으로 등록합니다.
@RequiredArgsConstructor
public class UserCleanupScheduler {

    private final IMyPageService myPageService;

    /**
     * 매일 새벽 4시에 실행됩니다.
     * 탈퇴 요청 후 30일이 지난 회원 정보를 영구적으로 삭제합니다.
     */
    @Scheduled(cron = "0 0 4 * * *") // 초 분 시 일 월 요일 (매일 새벽 4시 0분 0초)
    public void cleanupDeactivatedUsers() {
        log.info(this.getClass().getName() + ".cleanupDeactivatedUsers Start!");

        try {
            // Service를 통해 영구 삭제 로직을 호출합니다.
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

