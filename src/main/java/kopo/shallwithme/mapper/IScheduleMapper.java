package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.ChatMessageDTO;
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

    // 일정 수정
    int updateSchedule(ScheduleDTO pDTO) throws Exception;

    // 일정 삭제
    int deleteSchedule(ScheduleDTO pDTO) throws Exception;

    // 일정 상태 업데이트 쿼리
    void updateScheduleStatus(String scheduleId, String status, String userId);

    // 일정 ID로 메시지 조회 쿼리
    ChatMessageDTO selectMessageByScheduleId(String scheduleId);
}
