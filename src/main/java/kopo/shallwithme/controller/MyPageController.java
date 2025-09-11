package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.MsgDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.service.IMyPageService;
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

@Slf4j
@RequestMapping(value = "/mypage")
@RequiredArgsConstructor
@Controller
public class MyPageController {

    private final IMyPageService myPageService;

    @GetMapping("userModify")
    public String userModify() {

        log.info("{}.userModify Start!", this.getClass().getName());
        log.info("{}.userModify End!", this.getClass().getName());

        return "mypage/userModify";
    }

    @GetMapping("sharehouseModify")
    public String sharehouseModify() {

        log.info("{}.sharehouseModify Start!", this.getClass().getName());
        log.info("{}.sharehouseModify End!", this.getClass().getName());

        return "mypage/sharehouseModify";
    }

    @GetMapping("scheduleCheck")
    public String scheduleCheck() {

        log.info("{}.scheduleCheck Start!", this.getClass().getName());
        log.info("{}.scheduleCheck End!", this.getClass().getName());

        return "mypage/scheduleCheck";
    }

    @GetMapping("withdraw")
    public String withdraw() {

        log.info("{}.withdraw Start!", this.getClass().getName());
        log.info("{}.withdraw End!", this.getClass().getName());

        return "mypage/withdraw";
    }

    @GetMapping("myPagePwCheck")
    public String myPagePwCheck() {

        log.info("{}.myPagePwCheck Start!", this.getClass().getName());
        log.info("{}.myPagePwCheck End!", this.getClass().getName());

        return "mypage/myPagePwCheck";
    }

    @ResponseBody
    @PostMapping(value = "pwCheckProc")
    public MsgDTO pwCheckProc(HttpServletRequest request, HttpSession session) {
        log.info("{}.pwCheckProc Start!", this.getClass().getName());

        int res = 0;
        String msg = "";
        MsgDTO dto;

        UserInfoDTO pDTO;

        try {

            String userId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID"));
            String password = CmmUtil.nvl(request.getParameter("password"));

            log.info("userId : {} / password : {}", userId, password);

            pDTO = new UserInfoDTO();

            pDTO.setUserId(userId);
            pDTO.setPassword(EncryptUtil.encHashSHA256(password));

            UserInfoDTO rDTO = myPageService.pwCheck(pDTO);

            if (!CmmUtil.nvl(rDTO.getUserId()).isEmpty()) {

                msg = "비밀번호 확인이 완료되었습니다.";
                res = 1;

                session.setAttribute("SS_USER_ID", userId);
                session.setAttribute("SS_PASSWORD_CHK", true);

            } else {
                msg = "비밀번호가 올바르지 않습니다.";
            }

        } catch (Exception e) {
            //저장이 실패하면 사용자에세 보여줄 메세지
            msg = "시스템 문제로 비밀번호 확인 처리가 실패하였습니다.";
            log.info(e.toString());
        } finally {
            // 결과 메시지 전달하기
            dto = new MsgDTO();
            dto.setResult(res);
            dto.setMsg(msg);

            log.info("{}.pwCheckProc Eng!", this.getClass().getName());
        }
        return dto;

    }

    // 회원 탈퇴 이메일 확인
    @ResponseBody
    @PostMapping(value = "withdrawEmailChk")
    public UserInfoDTO withdrawEmailChk(HttpServletRequest request, HttpSession session) throws Exception {

        log.info("{}.withdrawEmailChk Start!", this.getClass().getName());

        String userId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID"));
        String email = CmmUtil.nvl(request.getParameter("email"));

        log.info("userId : {}", userId);
        log.info("email : {}", email);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);
        pDTO.setEmail(EncryptUtil.encAES128BCBC(email));

        log.info("암호화 email : {}", pDTO.getEmail());

        UserInfoDTO rDTO = Optional.ofNullable(myPageService.emailCheck(pDTO)).orElseGet(UserInfoDTO::new);

        if(CmmUtil.nvl(rDTO.getExistsYn()).equals("Y")) {

            session.setAttribute("SS_USER_EMAIL", pDTO.getEmail());
        }

        log.info("{}.withdrawEmailChk End!", this.getClass().getName());

        return rDTO;
    }

    @ResponseBody
    @PostMapping(value = "withdrawProc")
    public MsgDTO withdrawProc(HttpServletRequest request, HttpSession session) {

        log.info("{}.withdrawProc Start!", this.getClass().getName());

        int res = 0;
        String msg;

        try {
            String userId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID")); // 현재 로그인 유저
            String password = CmmUtil.nvl(request.getParameter("password"));

            if (userId.isEmpty() || password.isEmpty()) {
                msg = "잘못된 요청입니다.";
            } else {
                // 로그인과 동일한 방식으로 비번 검증
                UserInfoDTO pDTO = new UserInfoDTO();
                pDTO.setUserId(userId);

                // 로그인에서 해시쓰면 아래로 교체
                pDTO.setPassword(EncryptUtil.encHashSHA256(password));

                UserInfoDTO rDTO = myPageService.pwCheck(pDTO);

                if (rDTO != null && !CmmUtil.nvl(rDTO.getUserId()).isEmpty()) {
                    // 비밀번호 일치 → 삭제
                    UserInfoDTO dDTO = new UserInfoDTO();
                    dDTO.setUserId(userId);
                    int i = myPageService.deactivateUser(dDTO);

                    if (i > 0) {
                        res = 1;
                        msg = "회원 탈퇴가 완료되었습니다.";
                        // 세션 종료
                        session.invalidate();
                    } else {
                        msg = "회원 탈퇴에 실패했습니다.";
                    }
                } else {
                    msg = "비밀번호가 일치하지 않습니다.";
                }
            }
        } catch (Exception e) {
            log.error("withdrawProc ERROR: ", e);
            res = 2;
            msg = "시스템 문제로 탈퇴 처리에 실패했습니다.";
        }

        MsgDTO dto = new MsgDTO();
        dto.setResult(res);
        dto.setMsg(msg);

        log.info("{}.withdrawProc End!", this.getClass().getName());

        return dto;
    }

}
