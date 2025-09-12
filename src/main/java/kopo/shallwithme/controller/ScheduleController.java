package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.ScheduleDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.service.impl.ScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RequestMapping(value = "/schedule")
@RequiredArgsConstructor
@Controller
public class ScheduleController {

    private final ScheduleService scheduleService;

    @GetMapping("scheduleReg")
    public String scheduleReg() {
        log.info("{}.scheduleReg Start!", this.getClass().getName());

        return "schedule/scheduleReg";
    }

    // 2. FullCalendar가 사용할 일정 데이터를 조회하는 API
    @GetMapping("/api/events")
    @ResponseBody
    public List<ScheduleDTO> getEvents(HttpSession session) {
        log.info("{}.getEvents Start!", this.getClass().getName());

        String userId = (String) session.getAttribute("SS_USER_ID");
        log.info("userId : {}", userId);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        List<ScheduleDTO> rList = scheduleService.getScheduleList(pDTO);

        log.info("{}.getEvents End!", this.getClass().getName());

        return rList;
    }

    // 3. 새로운 일정을 저장하는 API
    @PostMapping("/api/events")
    @ResponseBody
    public String addEvent(@RequestBody ScheduleDTO pDTO, HttpSession session) {
        log.info("{}.addEvent Start!", this.getClass().getName());

        String res = "";

        String userId = (String) session.getAttribute("SS_USER_ID");
        log.info("userId : {}", userId);

        pDTO.setCreatorId(userId); // 일정 생성자는 현재 로그인한 사용자

        int result = scheduleService.insertSchedule(pDTO);

        if (result > 0) {
            res = "일정저장 완료";
        } else {
            res = "일정저장 실패";
        }

        log.info("{}.addEvent End!", this.getClass().getName());

        return res;
    }
}
