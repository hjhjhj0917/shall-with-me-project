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
    public int insertSchedule(ScheduleDTO pDTO) {
        log.info("{}.insertSchedule Start!", this.getClass().getName());

        int res = scheduleMapper.insertSchedule(pDTO);

        log.info("{}.insertSchedule End!", this.getClass().getName());

        return res;
    }
}
