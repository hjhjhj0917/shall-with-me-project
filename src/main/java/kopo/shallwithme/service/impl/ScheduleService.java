package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.ChatMessageDTO;
import kopo.shallwithme.dto.ScheduleDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.mapper.IScheduleMapper;
import kopo.shallwithme.service.IScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class ScheduleService implements IScheduleService {

    private final IScheduleMapper scheduleMapper;

    @Override
    public List<ScheduleDTO> getScheduleList(UserInfoDTO pDTO) {
        log.info("{}.getScheduleList Start!", this.getClass().getName());

        List<ScheduleDTO> rList = scheduleMapper.getScheduleList(pDTO);

        log.info("{}.getScheduleList End!", this.getClass().getName());

        return rList;
    }

    @Override
    public int insertSchedule(ScheduleDTO pDTO) {
        log.info("{}.insertSchedule Start!", this.getClass().getName());

        int res = scheduleMapper.insertSchedule(pDTO);

        log.info("{}.insertSchedule End!", this.getClass().getName());

        return res;
    }


    @Override
    public void updateScheduleStatus(String scheduleId, String status, String userId) {
        log.info("{}.updateScheduleStatus Start! scheduleId={}, status={}, userId={}",
                this.getClass().getName(), scheduleId, status, userId);

        try {
            // 일정 상태 변경 쿼리 실행
            scheduleMapper.updateScheduleStatus(scheduleId, status, userId);
        } catch (Exception e) {
            log.error("일정 상태 변경 실패! scheduleId={}, status={}, userId={}",
                    scheduleId, status, userId, e);
        }

        log.info("{}.updateScheduleStatus End!", this.getClass().getName());
    }

    // 일정 ID로 일정 메시지 조회 (상태가 변경된 메시지 최신 정보를 다시 가져오기 위함)
    @Override
    public ChatMessageDTO getChatMessageByScheduleId(String scheduleId) {
        log.info("{}.getChatMessageByScheduleId Start! scheduleId={}",
                this.getClass().getName(), scheduleId);

        ChatMessageDTO message = null;
        try {
            message = scheduleMapper.selectMessageByScheduleId(scheduleId);
        } catch (Exception e) {
            log.error("일정 메시지 조회 실패! scheduleId={}", scheduleId, e);
        }

        log.info("{}.getChatMessageByScheduleId End!", this.getClass().getName());

        return message;
    }
}
