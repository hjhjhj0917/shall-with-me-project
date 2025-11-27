package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.*;
import kopo.shallwithme.service.IMyPageService;
import kopo.shallwithme.service.impl.AwsS3Service; // ✅ AWS 서비스 import 추가
import kopo.shallwithme.util.CmmUtil;
import kopo.shallwithme.util.EncryptUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;

@Slf4j
@RequestMapping(value = "/mypage")
@RequiredArgsConstructor
@Controller
public class MyPageController {

    private final IMyPageService myPageService;
    private final AwsS3Service awsS3Service; // ✅ AWS 서비스 주입 추가

    // ❌ [삭제됨] NCP 관련 @Value 설정들 모두 제거
    // @Value("${ncp.object-storage.endpoint}") private String endpoint;
    // @Value("${ncp.object-storage.region}") private String region;
    // @Value("${ncp.object-storage.access-key}") private String accessKey;
    // @Value("${ncp.object-storage.secret-key}") private String secretKey;
    // @Value("${ncp.object-storage.bucket-name}") private String bucketName;
    // @Value("${ncp.object-storage.folder}") private String folder;

    // content-type 화이트리스트 (보안 검증용)
    private static final Set<String> ALLOWED_IMAGE_TYPES = Set.of(
            "image/jpeg", "image/jpg", "image/png", "image/webp", "image/gif"
    );

    // ❌ [삭제됨] private String uploadToNcpObjectStorage(MultipartFile file) throws IOException { ... }
    // AWS S3 서비스가 이 역할을 대신합니다.

    @GetMapping("userModify")
    public String userModify(HttpSession session, ModelMap model) throws Exception {

        log.info("{}.userModify Start!", this.getClass().getName());

        String userId = (String) session.getAttribute("SS_USER_ID");

        log.info("userId={}", userId);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        UserInfoDTO rDTO = myPageService.myPageUserInfo(pDTO);
        List<UserTagDTO> rList = myPageService.myPageUserTag(pDTO);

        String mail = rDTO.getEmail();
        rDTO.setEmail(EncryptUtil.decAES128BCBC(mail));

        log.info("rDTO: {}", rDTO);

        model.addAttribute("rDTO", rDTO);
        model.addAttribute("tList", rList);

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

        log.info("userId={}", userId);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        UserInfoDTO rDTO = myPageService.myPageUserInfo(pDTO);

        String mail = rDTO.getEmail();
        rDTO.setEmail(EncryptUtil.decAES128BCBC(mail));

        log.info("rDTO: {}", rDTO);
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
                    UserProfileDTO fDTO = new UserProfileDTO();

                    dDTO.setUserId(userId);
                    dDTO.setUserName(session.getAttribute("SS_USER_NAME").toString());
                    dDTO.setEmail(session.getAttribute("SS_USER_EMAIL").toString());

                    fDTO.setUserId(userId);

                    log.info(dDTO.getEmail());

                    int j = myPageService.deactivateProfile(fDTO);
                    int i = myPageService.deactivateUser(dDTO);

                    if (i > 0 && j > 0) {
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

    @PostMapping("/introductionUpdate")
    @ResponseBody
    public String introductionUpdate(HttpServletRequest request, HttpSession session) throws Exception {
        log.info("{}.introductionUpdate Start!", this.getClass().getName());

        String introduction = request.getParameter("introduction");
        String userId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID"));

        log.info("userId : {}, introduction : {}", userId, introduction);

        UserProfileDTO pDTO = new UserProfileDTO();

        pDTO.setUserId(userId);
        pDTO.setIntroduction(introduction);

        int res = myPageService.updateIntroduction(pDTO);
        String msg;

        if (res > 0) {
            msg = "자기소개가 수정되었습니다.";
        } else {
            msg = "자기소개 수정을 실패했습니다.";
        }

        log.info("{}.introductionUpdate End!", this.getClass().getName());
        return msg;
    }

    // ✅ [변경] 프로필 이미지 업로드: AWS S3 사용
    @PostMapping("/profileImageUpdate")
    @ResponseBody
    public ResponseEntity<?> profileImageUpdate(MultipartFile file, HttpSession session) throws IOException {
        String userId = (String) session.getAttribute("SS_USER_ID");
        if (userId == null || userId.isBlank()) {
            return ResponseEntity.badRequest().body("{\"error\":\"로그인이 필요합니다.\"}");
        }
        if (file == null || file.isEmpty()) {
            return ResponseEntity.badRequest().body("{\"error\":\"파일이 비어있습니다.\"}");
        }
        String ct = file.getContentType();
        if (ct == null || !ALLOWED_IMAGE_TYPES.contains(ct.toLowerCase())) {
            return ResponseEntity.badRequest().body("{\"error\":\"이미지(JPEG/PNG/WEBP/GIF)만 업로드 가능합니다.\"}");
        }
        if (file.getSize() > 5 * 1024 * 1024) {
            return ResponseEntity.badRequest().body("{\"error\":\"최대 5MB까지 업로드 가능합니다.\"}");
        }

        // ✅ [변경] AWS S3 서비스 사용
        String urlPath = awsS3Service.uploadFile(file);

        // DB 업데이트
        UserProfileDTO p = new UserProfileDTO();
        p.setUserId(userId);
        p.setProfileImageUrl(urlPath);
        myPageService.updateProfileImage(p);

        // 세션 갱신 (화면 즉시 반영)
        session.setAttribute("SS_USER_PROFILE_IMG_URL", urlPath);

        // 프론트에 URL 반환
        return ResponseEntity.ok("{\"url\":\"" + urlPath + "\"}");
    }


    // 전체 태그: [ { tagId, tagName, tagType } ]
    @GetMapping("tags/all")
    @ResponseBody
    public ResponseEntity<List<UserTagDTO>> tagsAll(){
        List<UserTagDTO> list = myPageService.getAllTagsWithType();
        return ResponseEntity.ok(list);
    }

    // 내 태그(그룹별 1개): [ { tagId, tagType } ]
    @GetMapping("tags/my")
    @ResponseBody
    public ResponseEntity<List<UserTagDTO>> tagsMy(HttpSession session){
        UserInfoDTO p = new UserInfoDTO();
        p.setUserId((String) session.getAttribute("SS_USER_ID"));
        List<UserTagDTO> list = myPageService.getMyTagSelections(p); // DTO만
        return ResponseEntity.ok(list);
    }

    // 저장: 본문 = UserTagDTO { tagList: [...] }  (DTO 단일만 받음)
    @PostMapping("tags/update")
    @ResponseBody
    public ResponseEntity<?> tagsUpdate(@RequestBody UserTagDTO p, HttpSession session){
        p.setUserId((String) session.getAttribute("SS_USER_ID"));
        int res = myPageService.updateMyTagsByGroup(p); // DTO만
        UserInfoDTO q = new UserInfoDTO(); q.setUserId(p.getUserId());
        List<TagDTO> chips = myPageService.getMyTagChips(q); // 칩 표시용
        return ResponseEntity.ok(java.util.Map.of("res", res, "tags", chips));
    }

    @PostMapping(value = "/passwordVerify")
    @ResponseBody
    public MsgDTO passwordVerify(HttpServletRequest request, HttpSession session) throws Exception {
        log.info("{}.mypage/passwordVerify Start!", this.getClass().getName());

        MsgDTO dto = new MsgDTO();

        // 로그인 세션에서 사용자 ID 확보 (프로젝트 세션 키에 맞춰 사용)
        String ssUserId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID"));
        String currentPw = CmmUtil.nvl(request.getParameter("currentPw"));

        if (ssUserId.isEmpty() || currentPw.isEmpty()) {
            dto.setResult(0);
            dto.setMsg("요청 정보가 부족합니다. 다시 시도해주세요.");
            log.info("세션 또는 파라미터 누락");
            return dto;
        }

        // 입력 비번 해시
        String encPw = EncryptUtil.encHashSHA256(currentPw);

        // DTO 규칙 준수
        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(ssUserId);
        pDTO.setPassword(encPw);

        boolean ok = myPageService.verifyPassword(pDTO); // 서비스에서 DB와 비교

        if (ok) {
            // ★★ 핵심: /user/newPasswordProc가 요구하는 세션값 세팅
            // 기존 newPasswordProc은 NEW_PASSWORD 세션에 "userId"를 담아 사용 중
            session.setAttribute("NEW_PASSWORD", ssUserId);

            dto.setResult(1);
            dto.setMsg("현재 비밀번호가 확인되었습니다.");
        } else {
            dto.setResult(0);
            dto.setMsg("현재 비밀번호가 일치하지 않습니다.");
        }

        log.info("{}.mypage/passwordVerify End!", this.getClass().getName());
        return dto;
    }

    @PostMapping("/addressUpdate")
    @ResponseBody
    public ResponseEntity<Map<String,Object>> addressUpdate(UserProfileDTO pDTO, HttpSession session) {

        String userId = (String) session.getAttribute("SS_USER_ID");
        Map<String,Object> res = new HashMap<>();

        if (userId == null) {
            res.put("result", 0);
            res.put("msg", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(res);
        }

        // JSP의 name과 DTO 필드명이 매칭되어 자동 바인딩됨
        pDTO.setUserId(userId);
        // addr1: 표시용 한 줄 주소, addr2: 상세주소(동/호)
        int r = myPageService.updateAddress(pDTO);

        res.put("result", r > 0 ? 1 : 0);
        res.put("msg", r > 0 ? "주소가 저장되었어요!" : "주소 저장에 실패했어요.");
        return ResponseEntity.ok(res);
    }

}