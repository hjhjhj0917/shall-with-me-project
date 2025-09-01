package kopo.shallwithme.controller;


import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.MsgDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.service.IUserInfoService;
import kopo.shallwithme.service.impl.RoommateService;
import kopo.shallwithme.util.CmmUtil;
import kopo.shallwithme.util.EncryptUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.Period;
import java.util.*;
import java.util.stream.Collectors;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;


@Slf4j
@RequestMapping(value = "/user")
@RequiredArgsConstructor
@Controller
public class UserInfoController {

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

    private final IUserInfoService userInfoService;
    private final RoommateService roommateService;

    @GetMapping(value = "searchPassword")
    public String searchPassword(HttpSession session) {
        log.info("{}.searchPassword Start!", this.getClass().getName());

        //강제 URL 입력 등 오는 경우가 있어 세션 삭제
        //비밀번호 재생성하는 화면은 보안을 위해 생성한 NEW_PASSWORD 세션 삭제
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
                userInfoService.searchUserIdOrPasswordProc(pDTO) // 내부에서 userId+email 일치 확인
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
    @ResponseBody // JSON 객체 반환을 명시적으로 지정
    public MsgDTO newPasswordProc(HttpServletRequest request, HttpSession session) throws Exception {

        log.info("{}.user/newPasswordProc Start!", this.getClass().getName());

        //비밀번호 변경 결과 담을 변수
        MsgDTO dto = new MsgDTO();

        //정상적인 접근인지 체크
        String newPassword = CmmUtil.nvl((String) session.getAttribute("NEW_PASSWORD"));

        //정상접근
        if (!newPassword.isEmpty()) {

            log.info("정상접근 비밀번호 변경 실행!");

            //신규 비밀번호
            String userPw = CmmUtil.nvl(request.getParameter("userPw"));
            log.info("password : {}", userPw);

            UserInfoDTO pDTO = new UserInfoDTO();
            pDTO.setUserId(newPassword);
            pDTO.setPassword(EncryptUtil.encHashSHA256(userPw));

            userInfoService.newPasswordProc(pDTO);

            //비밀번호 재생성하는 화면은 보안을 위해 생성한 NEW_PASSWORD 세션 삭제
            session.setAttribute("NEW_PASSWORD", "");
            session.removeAttribute("NEW_PASSWORD");

            dto.setResult(1); // MsgDTO의 result 필드에 1을 설정
            dto.setMsg("비밀번호 변경이 완료되었습니다.");

        }else {
            //비정상접근
            log.info("비정상적인 접근입니다.");

            dto.setResult(0); // MsgDTO의 result 필드에 0을 설정
            dto.setMsg("비정상적인 접근입니다.");
        }

        log.info("{}.user/newPasswordProc End!", this.getClass().getName());

        return dto;
    }

    @GetMapping(value = "login")
    public String login() {
        log.info("{}.login Start!", this.getClass().getName());

        log.info("{}.login End!", this.getClass().getName());

        return "user/login";
    }

    @GetMapping(value = "myPage")
    public String myPage() {

        return "user/myPage";
    }

    @GetMapping(value = "searchUserId")
    public String searchUserId() {
        log.info("{}.user/searchUserId Start!", this.getClass().getName());

        log.info("{}.user/searchUserId End!", this.getClass().getName());

        return "user/searchUserId";
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

            //비밀번호는 절대!!!!!!!!!!!로 복호화되지 않도록 해시 알고리즘으로 암호화함!!!!!!!
            pDTO.setPassword(EncryptUtil.encHashSHA256(password));

            //로그인을 위해 아이디와 비밀번호가 일치하는지 확인하기 위한 userIngoService 호출하기
            UserInfoDTO rDTO = userInfoService.getLogin(pDTO);

            if (!CmmUtil.nvl(rDTO.getUserId()).isEmpty()) {// 로그인 성공

                UserTagDTO tagDTO = new UserTagDTO();
                tagDTO.setUserId(userId);

                msg = "로그인을 성공했습니다.";

                session.setAttribute("SS_USER_ID", userId);

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
                //저장이 실패하면 사용자에세 보여줄 메세지
                msg = "시스템 문제로 로그인이 실패했습니다.";
                res = 2;
                log.info(e.toString());
            } finally {
                // 결과 메시지 전달하기
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


    @GetMapping("/roommateMain")
    public String roommateMain() {
        return "user/roommateMain"; // 세션 체크는 인터셉터에서 이미 처리
    }

    @GetMapping(value = "userRegForm")
    public String userRegForm() {
        log.info(this.getClass().getName() + ".user/userRegForm");

        return "user/userRegForm";
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

        // 태그 조회 (DTO에 tagName 포함)
        List<UserTagDTO> userTags = roommateService.getUserTagsByUserId(userId);
        if (userTags == null) userTags = List.of(); // NPE 방지

        // ✅ tag_name만 추출 (중복 제거 원하면 .distinct() 추가)
        List<String> userTagNames = userTags.stream()
                .map(UserTagDTO::getTagName)   // <-- 여기 수정!
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        // JSP에서 사용할 값
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

        // 회원아이디를 통해 중복된 아이디인지 조회하는 코드
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
        MsgDTO dto; // 결과 메시지 구조 이거 깃에는 dto = null; 이였음

        UserInfoDTO pDTO; // 이것도 깃에는 dto = null; 이였음!

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

            // 비밀번호는 절대로 복호화??/ 되지 않도록 해서
            // 해시 알고리즘으로 암호화한다고 함
            pDTO.setPassword(EncryptUtil.encHashSHA256(password));

            //민감 정보인 이메일은 aes128-CBC로 암호화한다고함
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
//            e.printStackTrace(); // 깃에만 있었음

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

    @GetMapping(value = "userTagSelect") // /WEB-INF/views/user/index.jsp 로 이동
    public String userTagSelect() {

        return "user/userTagSelect";
    }

    @GetMapping(value = "main") //
    public String mainPage() {

        return "user/main";
    }

    @GetMapping(value = "sample") //
    public String sample() {

        return "includes/sample";
    }

    @GetMapping("/") // /WEB-INF/views/index.jsp 로 이동
    public String index() {

        return "index";
    }

    // POST /saveUserTags 핸들러 예시 (Spring MVC)
    @PostMapping("/saveUserTags")
    @ResponseBody
    public Map<String, Object> saveUserTags(@RequestBody UserTagDTO dto, HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 여기 추가! 세션에서 userId 꺼내서 dto에 넣기
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
        int res = 1; // 기본 성공
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

    // 회원 프로필 이미지 불러오기
    @GetMapping("/profile-image/{userId}")
    public ResponseEntity<Map<String, String>> getProfileImage(@PathVariable String userId) {

        log.info("getProfileImage start!");

        String imageUrl = userInfoService.getImageUrlByUserId(userId);
        Map<String, String> result = new HashMap<>();
        result.put("imageUrl", imageUrl != null ? imageUrl : "/images/noimg.png");

        log.info("getProfileImage end!");

        return ResponseEntity.ok(result);
    }

    @GetMapping(value = "userInfo")
    public String userInfo() {

        return "user/userInfo";
    }

}

