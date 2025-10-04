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

    // 일정 목록 불러오기
    @Override
    public List<ScheduleDTO> getScheduleList(UserInfoDTO pDTO) {
        log.info("{}.getScheduleList Start!", this.getClass().getName());

        List<ScheduleDTO> rList = scheduleMapper.getScheduleList(pDTO);

        log.info("{}.getScheduleList End!", this.getClass().getName());

        return rList;
    }

    // 일정 수정
    @Override
    public int updateSchedule(ScheduleDTO pDTO) throws Exception {
        log.info("{}.updateSchedule Start!", this.getClass().getName());

        int res = scheduleMapper.updateSchedule(pDTO);

        log.info("{}.updateSchedule End!", this.getClass().getName());

        return res;
    }

    // 일정 삭제
    @Override
    public int deleteSchedule(ScheduleDTO pDTO) throws Exception {
        log.info("{}.deleteSchedule Start!", this.getClass().getName());

        int res = scheduleMapper.deleteSchedule(pDTO);

        log.info("{}.deleteSchedule End!", this.getClass().getName());

        return res;
    }

    // 일정 등록
    @Override
    public int insertSchedule(ScheduleDTO pDTO) {
        log.info("{}.insertSchedule Start!", this.getClass().getName());

        int res = scheduleMapper.insertSchedule(pDTO);

        log.info("{}.insertSchedule End!", this.getClass().getName());

        return res;
    }

    public ScheduleDTO insertScheduleRequest(ScheduleDTO pDTO) {
        log.info("{}.insertScheduleRequest Start!", this.getClass().getName());

        // 1. DTO에 상태 값을 'PENDING'으로 설정
        pDTO.setStatus("PENDING");

        // 2. DB에 삽입합니다.
        // (주의) Mapper의 insert 쿼리가 실행된 후, 생성된 schedule_id를 pDTO에 다시 담아주는 기능이 필요합니다.
        // MyBatis의 <selectKey> 또는 @Options(useGeneratedKeys=true, keyProperty="scheduleId") 어노테이션을 사용하세요.
        scheduleMapper.insertShareSchedule(pDTO);

        log.info("Saved Pending Schedule with ID: {}", pDTO.getScheduleId());
        log.info("{}.insertScheduleRequest End!", this.getClass().getName());

        // ID가 포함된 DTO를 컨트롤러로 반환
        return pDTO;
    }

    // 일정 상태 업데이트
    @Override
    public void updateScheduleStatus(int scheduleId, String status) {
        log.info("Updating scheduleId: {} to status: {}", scheduleId, status);

        ScheduleDTO pDTO = new ScheduleDTO();
        pDTO.setScheduleId(scheduleId);
        pDTO.setStatus(status);

        // 상태만 업데이트하는 Mapper 메서드를 호출합니다.
        scheduleMapper.updateShareScheduleStatus(pDTO);

        log.info("Update complete.");
    }

    public ScheduleDTO getScheduleById(int scheduleId) {
        log.info("{}.getScheduleById Start! scheduleId={}", this.getClass().getName(), scheduleId);

        ScheduleDTO rDTO = scheduleMapper.getScheduleById(scheduleId);

        log.info("{}.getScheduleById End!", this.getClass().getName());
        return rDTO;
    }

}
