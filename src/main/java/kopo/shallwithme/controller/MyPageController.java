package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Slf4j
@RequestMapping(value = "/mypage")
@RequiredArgsConstructor
@Controller
public class MyPageController {

    @GetMapping("userModify")
    public String userModify() {

        log.info("{}.userModify Start!", this.getClass().getName());

        return "mypage/userModify";
    }

    @GetMapping("sharehouseModify")
    public String sharehouseModify() {

        log.info("{}.sharehouseModify Start!", this.getClass().getName());

        return "mypage/sharehouseModify";
    }

    @GetMapping("scheduleCheck")
    public String scheduleCheck() {

        log.info("{}.scheduleCheck Start!", this.getClass().getName());

        return "mypage/scheduleCheck";
    }

    @GetMapping("myPagePwCheck")
    public String myPagePwCheck() {

        log.info("{}.myPagePwCheck Start!", this.getClass().getName());

        return "mypage/myPagePwCheck";
    }
}
