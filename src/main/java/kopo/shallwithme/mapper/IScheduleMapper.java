package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.ScheduleDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface IScheduleMapper {

    // 특정 사용자가 포함된 모든 일정 조회
    List<ScheduleDTO> getScheduleList(UserInfoDTO pDTO);

    // 새로운 일정 등록
    int insertSchedule(ScheduleDTO pDTO);
}
