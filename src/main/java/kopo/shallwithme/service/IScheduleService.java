package kopo.shallwithme.service;

import kopo.shallwithme.dto.ScheduleDTO;
import kopo.shallwithme.dto.UserInfoDTO;

import java.util.List;

public interface IScheduleService {

    List<ScheduleDTO> getScheduleList(UserInfoDTO pDTO);

    int insertSchedule(ScheduleDTO pDTO);

    int updateSchedule(ScheduleDTO pDTO) throws Exception;

    int deleteSchedule(ScheduleDTO pDTO) throws Exception;

    ScheduleDTO insertScheduleRequest(ScheduleDTO pDTO);

    void updateScheduleStatus(int scheduleId, String status);

    ScheduleDTO getScheduleById(int scheduleId);

}
