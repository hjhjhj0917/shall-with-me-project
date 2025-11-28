package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.ChatMessageDTO;
import kopo.shallwithme.dto.ScheduleDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface IScheduleMapper {

    List<ScheduleDTO> getScheduleList(UserInfoDTO pDTO);

    int insertSchedule(ScheduleDTO pDTO);

    int updateSchedule(ScheduleDTO pDTO) throws Exception;

    int deleteSchedule(ScheduleDTO pDTO) throws Exception;

    void updateShareScheduleStatus(ScheduleDTO pDTO);

    ChatMessageDTO selectMessageByScheduleId(String scheduleId);

    ScheduleDTO getScheduleById(int scheduleId);

    void insertShareSchedule(ScheduleDTO pDTO);
}
