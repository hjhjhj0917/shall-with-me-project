package kopo.shallwithme.service;

import kopo.shallwithme.dto.ChatMessageDTO;
import kopo.shallwithme.dto.ScheduleDTO;
import kopo.shallwithme.dto.UserInfoDTO;

import java.util.List;

public interface IScheduleService {

    List<ScheduleDTO> getScheduleList(UserInfoDTO pDTO);

    int insertSchedule(ScheduleDTO pDTO);

    // 일정 상태 변경
    void updateScheduleStatus(String scheduleId, String status, String userId);

    // 일정 ID로 채팅 메시지 조회
    ChatMessageDTO getChatMessageByScheduleId(String scheduleId);
}
