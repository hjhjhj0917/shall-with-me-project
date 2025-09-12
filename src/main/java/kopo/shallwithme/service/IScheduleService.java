package kopo.shallwithme.service;

import kopo.shallwithme.dto.ScheduleDTO;
import kopo.shallwithme.dto.UserInfoDTO;

import java.util.List;

public interface IScheduleService {

    List<ScheduleDTO> getScheduleList(UserInfoDTO pDTO);

    int insertSchedule(ScheduleDTO pDTO);

}
