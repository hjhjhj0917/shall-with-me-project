package kopo.shallwithme.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Slf4j
@RequestMapping(value = "/schedule")
@RequiredArgsConstructor
@Controller
public class ScheduleController {

    @GetMapping("scheduleReg")
    public String scheduleReg() {

        log.info("{}.scheduleReg Start!", this.getClass().getName());

        return "schedule/scheduleReg";
    }
}
