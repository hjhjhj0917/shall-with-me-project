package kopo.shallwithme.controller;


import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.MsgDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.service.IUserInfoService;
import kopo.shallwithme.service.impl.RoommateService;
import kopo.shallwithme.util.CmmUtil;
import kopo.shallwithme.util.EncryptUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.Period;
import java.util.*;
import java.util.stream.Collectors;


@Slf4j
@RequestMapping(value = "/user")
@RequiredArgsConstructor
@Controller
public class UserInfoController {


    private final IUserInfoService userInfoService;
    private final RoommateService roommateService;


    private int calculateAge(String birthYear, String birthMonth, String birthDay) {
        int year = Integer.parseInt(birthYear);
        int month = Integer.parseInt(birthMonth);
        int day = Integer.parseInt(birthDay);

        LocalDate birth = LocalDate.of(year, month, day);
        LocalDate today = LocalDate.now();

        int age = Period.between(birth, today).getYears();

        LocalDate birthdayThisYear = birth.withYear(today.getYear());
        if (today.isBefore(birthdayThisYear)) {
            age--;
        }
        return age;
    }


    @GetMapping(value = "searchPassword")
    public String searchPassword(HttpSession session) {
        log.info("{}.searchPassword Start!", this.getClass().getName());

        session.setAttribute("NEW_PASSWORD", "");
        session.removeAttribute("NEW_PASSWORD");

        log.info("{}.searchPassword End!", this.getClass().getName());

        return "user/searchPassword";
    }


    @ResponseBody
    @PostMapping(value = "searchPasswordProc")
    public MsgDTO searchPasswordProc(HttpSession session, HttpServletRequest request) throws Exception {

        log.info("{}.searchPasswordProc Start!", this.getClass().getName());

        String userId = CmmUtil.nvl(request.getParameter("userId"));
        String email  = CmmUtil.nvl(request.getParameter("email"));

        session.setAttribute("NEW_PASSWORD", userId);

        log.info("userId : {} / email : {}", userId, email);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);
        pDTO.setEmail(EncryptUtil.encAES128BCBC(email));

        UserInfoDTO rDTO = Optional.ofNullable(
                userInfoService.searchUserIdOrPasswordProc(pDTO)
        ).orElseGet(UserInfoDTO::new);

        MsgDTO dto = new MsgDTO();

        if (rDTO.getUserId() != null) {
            dto.setResult(1);
            dto.setMsg("본인 확인 완료");
        } else {
            dto.setResult(0);
            dto.setMsg("입력하신 정보와 일치하는 사용자가 없습니다.");
        }

        log.info("{}.searchPasswordProc End!", this.getClass().getName());

        return dto;
    }


    @PostMapping(value = "newPasswordProc")
    @ResponseBody
    public MsgDTO newPasswordProc(HttpServletRequest request, HttpSession session) throws Exception {

        log.info("{}.user/newPasswordProc Start!", this.getClass().getName());

        MsgDTO dto = new MsgDTO();

        String newPassword = CmmUtil.nvl((String) session.getAttribute("NEW_PASSWORD"));

        if (!newPassword.isEmpty()) {

            log.info("정상접근 비밀번호 변경 실행!");

            String userPw = CmmUtil.nvl(request.getParameter("userPw"));
            log.info("password : {}", userPw);

            UserInfoDTO pDTO = new UserInfoDTO();
            pDTO.setUserId(newPassword);
            pDTO.setPassword(EncryptUtil.encHashSHA256(userPw));

            userInfoService.newPasswordProc(pDTO);

            session.setAttribute("NEW_PASSWORD", "");
            session.removeAttribute("NEW_PASSWORD");

            dto.setResult(1);
            dto.setMsg("비밀번호 변경이 완료되었습니다.");

        }else {
            log.info("비정상적인 접근입니다.");

            dto.setResult(0);
            dto.setMsg("비정상적인 접근입니다.");
        }

        log.info("{}.user/newPasswordProc End!", this.getClass().getName());

        return dto;
    }


    @ResponseBody
    @PostMapping(value = "searchUserIdProc")
    public MsgDTO searchUserIdProc(HttpServletRequest request) throws Exception {

        log.info("{}.searchUserIdProc Start!", this.getClass().getName());

        String userName = CmmUtil.nvl(request.getParameter("userName"));
        String email = CmmUtil.nvl(request.getParameter("email"));

        log.info("userName : {} / email : {}", userName, email);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserName(userName);
        pDTO.setEmail(EncryptUtil.encAES128BCBC(email));

        UserInfoDTO rDTO = Optional.ofNullable(
                userInfoService.searchUserIdOrPasswordProc(pDTO)
        ).orElseGet(UserInfoDTO::new);

        MsgDTO dto = new MsgDTO();

        if (rDTO.getUserId() != null) {
            dto.setResult(1);
            dto.setMsg(rDTO.getUserId());
            dto.setName(rDTO.getUserName());
        } else {
            dto.setResult(0);
            dto.setMsg("존재하지 않는 사용자입니다.");
        }

        log.info("{}.searchUserIdProc End!", this.getClass().getName());

        return dto;
    }


    @ResponseBody
    @PostMapping(value = "loginProc")
    public MsgDTO loginProc(HttpServletRequest request, HttpSession session) {
        log.info("{}.loginProc Start!", this.getClass().getName());

        int res = 0;
        String msg = "";
        MsgDTO dto;

        UserInfoDTO pDTO;

        try {

            String userId = CmmUtil.nvl(request.getParameter("userId"));
            String password = CmmUtil.nvl(request.getParameter("password"));

            log.info("userId : {} / password : {}", userId, password);

            pDTO = new UserInfoDTO();

            pDTO.setUserId(userId);

            pDTO.setPassword(EncryptUtil.encHashSHA256(password));

            UserInfoDTO rDTO = userInfoService.getLogin(pDTO);

            if (!CmmUtil.nvl(rDTO.getUserId()).isEmpty()) {

                UserTagDTO tagDTO = new UserTagDTO();
                tagDTO.setUserId(userId);

                msg = "로그인을 성공했습니다.";

                String imageUrl = userInfoService.getImageUrlByUserId(userId);

                session.setAttribute("SS_USER_ID", userId);
                session.setAttribute("SS_USER_PROFILE_IMG_URL", imageUrl);

                if (CmmUtil.nvl(rDTO.getUserName()).length() == 2) {
                    session.setAttribute("SS_USER_NAME", "ㅤ" + CmmUtil.nvl(rDTO.getUserName()));
                } else {
                    session.setAttribute("SS_USER_NAME", CmmUtil.nvl(rDTO.getUserName()));
                }
                int existingCount = userInfoService.countUserTags(tagDTO);
                log.info("User tag count: {}", existingCount);

                if (existingCount < 18) {
                    res = 3;
                } else {
                    res = 1;
                }

            } else {
                msg = "아이디와 비밀번호가 올바르지 않습니다.";
            }

            } catch (Exception e) {
                msg = "시스템 문제로 로그인이 실패했습니다.";
                res = 2;
                log.info(e.toString());
            } finally {
                dto = new MsgDTO();
                dto.setResult(res);
                dto.setMsg(msg);

                log.info("{}.loginProc Eng!", this.getClass().getName());
            }

            return dto;
    }


    @GetMapping(value = "loginCheck")
    @ResponseBody
    public int loginCheck(HttpSession session) {
        log.info("{}.loginCheck Start!", this.getClass().getName());

        int res = 0;
        if (!CmmUtil.nvl((String) session.getAttribute("SS_USER_ID")).isEmpty()) {
            res = 1;
        }

        return res;
    }


    @GetMapping("/userProfile")
    public String userProfile() {

        log.info("{}.userProfile Start!", this.getClass().getName());

        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        var req = attrs.getRequest();
        HttpSession session = req.getSession(false);

        String userId   = (session != null) ? (String) session.getAttribute("SS_USER_ID")   : "";
        String userName = (session != null) ? (String) session.getAttribute("SS_USER_NAME") : "";

        List<UserTagDTO> userTags = roommateService.getUserTagsByUserId(userId);
        if (userTags == null) userTags = List.of();

        List<String> userTagNames = userTags.stream()
                .map(UserTagDTO::getTagName)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        req.setAttribute("userTags", userTags);
        req.setAttribute("userTagNames", userTagNames);
        req.setAttribute("SS_USER_NAME", userName);

        log.info("{}.userProfile End!", this.getClass().getName());

        return "user/userProfile";
    }

    @ResponseBody
    @PostMapping(value = "getUserIdExists")
    public UserInfoDTO getUserExists(HttpServletRequest request) throws Exception {

        log.info(this.getClass().getName() + ".getUserIdExists Start!");

        String userId = CmmUtil.nvl(request.getParameter("userId"));

        log.info("userId : " + userId);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        UserInfoDTO rDTO = Optional.ofNullable(userInfoService.getUserIdExists(pDTO)).orElseGet(UserInfoDTO::new);

        log.info(this.getClass().getName() + ".getUserIdExists End!");

        return rDTO;
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
    public MsgDTO insertUserInfo(HttpServletRequest request, HttpSession session) throws Exception {

        log.info(this.getClass().getName() + ".insertUserInfo Start!");

        int res = 0;
        String msg = "";
        MsgDTO dto;

        UserInfoDTO pDTO;

        try {

            String userId = CmmUtil.nvl(request.getParameter("userId"));
            String userName = CmmUtil.nvl(request.getParameter("userName"));
            String password = CmmUtil.nvl(request.getParameter("password"));
            String email = CmmUtil.nvl(request.getParameter("email"));
            String addr1 = CmmUtil.nvl(request.getParameter("addr1"));
            String addr2 = CmmUtil.nvl(request.getParameter("addr2"));
            String birthYear = CmmUtil.nvl(request.getParameter("birthYear"));
            String birthMonth = CmmUtil.nvl(request.getParameter("birthMonth"));
            String birthDay = CmmUtil.nvl(request.getParameter("birthDay"));
            String gender = CmmUtil.nvl(request.getParameter("gender"));

            log.info("userId : " + userId);
            log.info("userName : " + userName);
            log.info("password : " + password);
            log.info("email : " + email);
            log.info("addr1 : " + addr1);
            log.info("addr2 : " + addr2);
            log.info("birth : " + birthYear, birthMonth, birthDay);
            log.info("gender : " + gender);

            String birthDateStr = birthYear + "-" + birthMonth + "-" + birthDay;
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date birthDate = sdf.parse(birthDateStr);

            int age = calculateAge(birthYear, birthMonth, birthDay);

            pDTO = new UserInfoDTO();

            pDTO.setUserId(userId);
            pDTO.setUserName(userName);
            pDTO.setPassword(EncryptUtil.encHashSHA256(password));
            pDTO.setEmail(EncryptUtil.encAES128BCBC(email));
            pDTO.setAddr1(addr1);
            pDTO.setAddr2(addr2);
            pDTO.setAge(age);
            pDTO.setBirthDate(birthDate);
            pDTO.setGender(gender);

            res = userInfoService.insertUserInfo(pDTO);

            log.info("회원가입 결과(res) : " + res);

            if (res == 1) {
                if (pDTO.getUserName().length() == 2) {
                    session.setAttribute("SS_USER_NAME", "ㅤ" + userName);
                } else {
                    session.setAttribute("SS_USER_NAME", userName);
                }
                session.setAttribute("SS_USER_NAME", userName);
                session.setAttribute("SS_USER_ID", userId);
                msg = "회원가입되었습니다.";

            } else if (res == 2) {
                msg = "이미 가입된 아이디입니다.";

            } else {
                msg = "오류로 인해 회원가입이 실패하였습니다.";

            }

        } catch (Exception e) {

            msg = "실패하였습니다. : " + e;
            log.info(e.toString());

        } finally {
            dto = new MsgDTO();
            dto.setResult(res);
            dto.setMsg(msg);

            log.info("{}.insertUserInfo End!", this.getClass().getName());
        }

        return dto;
    }


    // 아이디 찾기 인증번호 전송
    @ResponseBody
    @PostMapping(value = "emailAuthNumber")
    public UserInfoDTO emailAuthNumber(HttpServletRequest request) throws Exception {

        log.info("{}.emailAuthNumber Start!", this.getClass().getName());

        String userName = CmmUtil.nvl(request.getParameter("userName"));
        String email = CmmUtil.nvl(request.getParameter("email"));

        log.info("userName : {}", userName);
        log.info("email : {}", email);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserName(userName);
        pDTO.setEmail(EncryptUtil.encAES128BCBC(email));

        log.info("암호화 email : {}", pDTO.getEmail());

        UserInfoDTO rDTO = Optional.ofNullable(userInfoService.emailAuthNumber(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("{}.emailAuthNumber End!", this.getClass().getName());

        return rDTO;
    }


    // 비밀번호 찾기 인증번호 전송
    @ResponseBody
    @PostMapping(value = "emailAuthNumberPw")
    public UserInfoDTO emailAuthNumberPw(HttpServletRequest request) throws Exception {

        log.info("{}.emailAuthNumberPw Start!", this.getClass().getName());

        String userId = CmmUtil.nvl(request.getParameter("userId"));
        String email = CmmUtil.nvl(request.getParameter("email"));

        log.info("userId : {}", userId);
        log.info("email : {}", email);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);
        pDTO.setEmail(EncryptUtil.encAES128BCBC(email));

        log.info("암호화 email : {}", pDTO.getEmail());

        UserInfoDTO rDTO = Optional.ofNullable(userInfoService.emailAuthNumberPw(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("{}.emailAuthNumberPw End!", this.getClass().getName());

        return rDTO;
    }


    @PostMapping("/saveUserTags")
    @ResponseBody
    public Map<String, Object> saveUserTags(@RequestBody UserTagDTO dto, HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            String userId = (String) session.getAttribute("SS_USER_ID");

            if (userId == null || userId.isEmpty()) {
                response.put("success", false);
                response.put("message", "로그인 정보가 없습니다.");
                return response;
            }

            dto.setUserId(userId);

            int existingCount = userInfoService.countUserTags(dto);

            if (existingCount == 18) {
                response.put("success", false);
                response.put("message", "이미 태그 선택이 완료된 상태입니다.");
                return response;
            }

            userInfoService.saveUserTags(dto);
            response.put("success", true);

        } catch (Exception e) {
            log.error("태그 저장 실패", e);
            response.put("success", false);
            response.put("message", "서버 오류 발생");
        }

        return response;
    }


    // 로그아웃
    @PostMapping("/logout")
    @ResponseBody
    public MsgDTO logout(HttpSession session) {
        int res = 1;
        String msg = "";

        MsgDTO dto = new MsgDTO();

        try {
            session.invalidate();
            msg = "성공적으로 로그아웃되었습니다.";
        } catch (Exception e) {
            res = 0;
            msg = "로그아웃 중 오류가 발생했습니다.";
        }

        dto.setResult(res);
        dto.setMsg(msg);

        return dto;
    }


    @GetMapping(value = "userInfo")
    public String userInfo() {
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        HttpServletRequest request = attrs.getRequest();
        HttpSession session = request.getSession(false);

        String userId = (session != null) ? (String) session.getAttribute("SS_USER_ID") : null;
        log.info("session userId={}", userId);

        if (userId == null || userId.isBlank()) {
            log.info("not logged in → redirect:/user/login");
            return "redirect:/user/login";
        }

        UserProfileDTO pDTO = new UserProfileDTO();
        pDTO.setUserId(userId);

        UserProfileDTO userProfile = userInfoService.findUserProfileByUserId(pDTO);
        request.setAttribute("userProfile", userProfile);
        log.info("userProfile set: {}", userProfile);

        log.info("{}.userInfo End!", this.getClass().getName());

        List<UserTagDTO> userTags = roommateService.getUserTagsByUserId(userId);
        if (userTags == null) userTags = List.of();
        request.setAttribute("userTags", userTags);
        log.info("userTags size={}", userTags.size());

        return "user/userInfo";
    }


    @GetMapping("/roommateMain")
    public String roommateMain() {

        log.info("{}.roommateMain Start!", this.getClass().getName());

        log.info("{}.roommateMain End!", this.getClass().getName());

        return "user/roommateMain";
    }


    @GetMapping(value = "userRegForm")
    public String userRegForm() {
        log.info(this.getClass().getName() + ".user/userRegForm");

        return "user/userRegForm";
    }


    @GetMapping(value = "userTagSelect")
    public String userTagSelect() {

        log.info("{}.userTagSelect Start!", this.getClass().getName());

        log.info("{}.userTagSelect End!", this.getClass().getName());

        return "user/userTagSelect";
    }


    @GetMapping(value = "main") //
    public String mainPage() {

        log.info("{}.mainPage Start!", this.getClass().getName());

        log.info("{}.mainPage End!", this.getClass().getName());

        return "user/main";
    }


    @GetMapping(value = "sample") //
    public String sample() {

        log.info("{}.sample Start!", this.getClass().getName());

        log.info("{}.sample End!", this.getClass().getName());

        return "includes/sample";
    }


    @GetMapping("/")
    public String index() {

        log.info("{}.index Start!", this.getClass().getName());

        log.info("{}.index End!", this.getClass().getName());

        return "index";
    }


    @GetMapping(value = "login")
    public String login() {
        log.info("{}.login Start!", this.getClass().getName());

        log.info("{}.login End!", this.getClass().getName());

        return "user/login";
    }


    @GetMapping(value = "searchUserId")
    public String searchUserId() {
        log.info("{}.user/searchUserId Start!", this.getClass().getName());

        log.info("{}.user/searchUserId End!", this.getClass().getName());

        return "user/searchUserId";
    }

}

