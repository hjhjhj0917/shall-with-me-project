package kopo.shallwithme.controller;

import kopo.shallwithme.dto.SpamDTO;
import kopo.shallwithme.service.ITestService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@Slf4j
public class TestController {

    private final ITestService testService;

    @GetMapping(value = "/test/analyze")
    public SpamDTO analyze() {

        log.info("{}.analyze Start!", this.getClass().getName());

        SpamDTO dto = new SpamDTO();
        dto.setText("완전 감동이에요 다시 봐도 좋네요");

        log.info("{}.analyze End!", this.getClass().getName());

        return testService.test(dto);
    }
}
