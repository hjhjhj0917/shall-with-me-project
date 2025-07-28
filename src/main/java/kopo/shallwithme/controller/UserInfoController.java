package kopo.shallwithme.controller;


import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.servlet.http.HttpServletRequest;
import kopo.shallwithme.dto.MsgDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.service.IUserInfoService;
import kopo.shallwithme.util.CmmUtil;
import kopo.shallwithme.util.EncryptUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Optional;

import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.service.impl.UserInfoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;


@Slf4j
@RequestMapping(value = "/user")
@RequiredArgsConstructor
@Controller
public class UserInfoController {


    private final IUserInfoService userInfoService;

    @GetMapping(value = "userRegForm")
    public String userRegForm() {
        log.info(this.getClass().getName() + ".user/userRegForm");

        return "user/userRegForm";
    }

    @ResponseBody
    @PostMapping(value = "getUserIdExists")
    public UserInfoDTO getUserExists(HttpServletRequest request) throws Exception {

        log.info(this.getClass().getName() + ".getUserIdExists Start!");

        String userId = CmmUtil.nvl(request.getParameter("userId"));

        log.info("userId : " + userId);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        // 회원아이디를 통해 중복된 아이디인지 조회하는 코드
        UserInfoDTO rDTO = Optional.ofNullable(userInfoService.getUserIdExists(pDTO)).orElseGet(UserInfoDTO::new);

        log.info(this.getClass().getName() + ".getUserIdExists End!");

        return pDTO;
    }

    @ResponseBody
    @PostMapping(value = "getEmailExists")
    public UserInfoDTO getEmailExists(HttpServletRequest request) throws Exception {

        log.info(this.getClass().getName() + ".getEmailExists Start!");

        String email = CmmUtil.nvl(request.getParameter("email"));

        log.info("email : " + email);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setEmail(EncryptUtil.encAES128BCBC(email));

        UserInfoDTO rDTO = Optional.ofNullable(userInfoService.getEmailExists(pDTO)).orElseGet(UserInfoDTO::new);

        log.info(this.getClass().getName() + ".getUserIdExists End!");

        return rDTO;
    }

    @ResponseBody
    @PostMapping(value = "insertUserInfo")
    public MsgDTO insertUserInfo(HttpServletRequest request) throws Exception {

        log.info(this.getClass().getName() + ".insertUserInfo Start!");

        int res = 0;
        String msg = "";
        MsgDTO dto; // 결과 메시지 구조 이거 깃에는 dto = null; 이였음

        UserInfoDTO pDTO; // 이것도 깃에는 dto = null; 이였음!

        try {

            String userId = CmmUtil.nvl(request.getParameter("userId"));
            String userName = CmmUtil.nvl(request.getParameter("userName"));
            String password = CmmUtil.nvl(request.getParameter("password"));
            String email = CmmUtil.nvl(request.getParameter("email"));
            String addr1 = CmmUtil.nvl(request.getParameter("addr1"));
            String addr2 = CmmUtil.nvl(request.getParameter("addr2"));

            log.info("userId : " + userId);
            log.info("userName : " + userName);
            log.info("password : " + password);
            log.info("email : " + email);
            log.info("addr1 : " + addr1);
            log.info("addr2 : " + addr2);

            pDTO = new UserInfoDTO();

            pDTO.setUserId(userId);
            pDTO.setUserName(userName);

            // 비밀번호는 절대로 복호화??/ 되지 않도록 해서
            // 해시 알고리즘으로 암호화한다고 함
            pDTO.setPassword(EncryptUtil.encHashSHA256(password));

            //민감 정보인 이메일은 aes128-CBC로 암호화한다고함
            pDTO.setEmail(EncryptUtil.encAES128BCBC(email));
            pDTO.setAddr1(addr1);
            pDTO.setAddr2(addr2);

            res = userInfoService.insertUserInfo(pDTO);

            log.info("회원가입 결과(res) : " + res);

            if (res == 1 ) {
                msg = "회원가입되었습니다.";

            } else if (res == 2) {
                msg = "이미 가입된 아이디입니다.";

            } else {
                msg = "오류로 인해 회원가입이 실패하였습니다.";

            }

        } catch (Exception e) {

            msg = "실패하였습니다. : " + e;
            log.info(e.toString());
//            e.printStackTrace(); // 깃에만 있었음

        } finally {
            dto = new MsgDTO();
            dto.setResult(res);
            dto.setMsg(msg);

            log.info("{}.insertUserInfo End!", this.getClass().getName());
        }

        return dto;

    private final UserInfoService userInfoService;

    @GetMapping(value = "userTagSelect") // /WEB-INF/views/user/index.jsp 로 이동
    public String userTagSelect() {

        return "user/userTagSelect";
    }

    @GetMapping("/") // /WEB-INF/views/index.jsp 로 이동
    public String index() {

        return "index";
    }

    @PostMapping("saveTags")
    @ResponseBody
    public Map<String, Object> saveUserTags(@RequestBody Map<String, String> tags, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 예제: 세션에서 로그인된 사용자 ID 가져오기 (임시로 test 사용 중)
            String userId = (String) session.getAttribute("userId");
            if (userId == null) userId = "test"; // 테스트용

            userInfoService.saveUserTags(userId, tags);
            response.put("message", "태그가 성공적으로 저장되었습니다.");
        } catch (Exception e) {
            response.put("message", "저장 실패: " + e.getMessage());
        }
        return response;

    }
}

