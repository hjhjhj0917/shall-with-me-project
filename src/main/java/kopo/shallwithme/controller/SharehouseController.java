package kopo.shallwithme.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Slf4j
@RequestMapping(value = "/sharehouse")
@RequiredArgsConstructor
@Controller
public class SharehouseController {
    @GetMapping(value = "sharehouseReg")
    public String sharehouseReg() {

        return "sharehouse/sharehouseReg";
    }
}
