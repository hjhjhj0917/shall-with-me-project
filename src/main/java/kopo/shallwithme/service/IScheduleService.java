package kopo.shallwithme.service;

import kopo.shallwithme.dto.ChatMessageDTO;
import kopo.shallwithme.dto.ScheduleDTO;
import kopo.shallwithme.dto.UserInfoDTO;

import java.util.List;

public interface IScheduleService {

    // 특정 사용자가 포함된 모든 일정 조회
    List<ScheduleDTO> getScheduleList(UserInfoDTO pDTO);

    // 새로운 일정 등록
    int insertSchedule(ScheduleDTO pDTO);

    // 일정 수정
    int updateSchedule(ScheduleDTO pDTO) throws Exception;

    // 일정 삭제
    int deleteSchedule(ScheduleDTO pDTO) throws Exception;

    ScheduleDTO insertScheduleRequest(ScheduleDTO pDTO);

    void updateScheduleStatus(int scheduleId, String status);

    ScheduleDTO getScheduleById(int scheduleId);

}
