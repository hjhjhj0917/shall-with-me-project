package kopo.shallwithme.service.impl;

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
    public int updateSchedule(ScheduleDTO pDTO) throws Exception {
        log.info("{}.updateSchedule Start!", this.getClass().getName());

        int res = scheduleMapper.updateSchedule(pDTO);

        log.info("{}.updateSchedule End!", this.getClass().getName());

        return res;
    }

    @Override
    public int deleteSchedule(ScheduleDTO pDTO) throws Exception {
        log.info("{}.deleteSchedule Start!", this.getClass().getName());

        int res = scheduleMapper.deleteSchedule(pDTO);

        log.info("{}.deleteSchedule End!", this.getClass().getName());

        return res;
    }

    @Override
    public int insertSchedule(ScheduleDTO pDTO) {
        log.info("{}.insertSchedule Start!", this.getClass().getName());

        int res = scheduleMapper.insertSchedule(pDTO);

        log.info("{}.insertSchedule End!", this.getClass().getName());

        return res;
    }

    public ScheduleDTO insertScheduleRequest(ScheduleDTO pDTO) {
        log.info("{}.insertScheduleRequest Start!", this.getClass().getName());

        pDTO.setStatus("PENDING");

        scheduleMapper.insertShareSchedule(pDTO);

        log.info("Saved Pending Schedule with ID: {}", pDTO.getScheduleId());
        log.info("{}.insertScheduleRequest End!", this.getClass().getName());

        return pDTO;
    }

    @Override
    public void updateScheduleStatus(int scheduleId, String status) {
        log.info("Updating scheduleId: {} to status: {}", scheduleId, status);

        ScheduleDTO pDTO = new ScheduleDTO();
        pDTO.setScheduleId(scheduleId);
        pDTO.setStatus(status);

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
