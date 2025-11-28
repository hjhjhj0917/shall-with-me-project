package kopo.shallwithme.service.impl;


import kopo.shallwithme.dto.MailDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.mapper.IUserInfoMapper;
import kopo.shallwithme.service.IMailService;
import kopo.shallwithme.service.IUserInfoService;
import kopo.shallwithme.util.CmmUtil;
import kopo.shallwithme.util.DateUtil;
import kopo.shallwithme.util.EncryptUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

@Slf4j
@RequiredArgsConstructor
@Service
public class UserInfoService implements IUserInfoService {

    private final IUserInfoMapper userInfoMapper;

    private final IMailService mailService;

    @Override
    public String getImageUrlByUserId(String userId) {

        log.info("{}.getImageUrlByUserId Start!", this.getClass().getName());

        String url = userInfoMapper.selectProfileImageUrlByUserId(userId);

        log.info("{}.getImageUrlByUserId end!", this.getClass().getName());

        return url;
    }

    @Override
    public List<UserInfoDTO> getAllUsers() {

        log.info("{}.getAllUsers Start!", this.getClass().getName());

        List<UserInfoDTO> userList = userInfoMapper.getAllUsersWithProfile();

        for (UserInfoDTO user : userList) {
            List<String> tags = userInfoMapper.getUserTags(user.getUserId());

            if (tags != null && !tags.isEmpty()) {
                Collections.shuffle(tags);
                if (tags.size() > 3) {
                    tags = tags.subList(0, 3);
                }
            }

            user.setTags(tags);
        }

        log.info("{}.getAllUsers End!", this.getClass().getName());
        return userList;
    }


    @Override
    public int newPasswordProc(UserInfoDTO pDTO) throws Exception {
        log.info("{}.newPasswordProc Start!", this.getClass().getName());

        int success = userInfoMapper.updatePassword(pDTO);

        log.info("{}.newPasswordProc End", this.getClass().getName());

        return success;
    }

    @Override
    public UserInfoDTO searchUserIdOrPasswordProc(UserInfoDTO pDTO) throws Exception {
        log.info("{}.searchUserIdOrPassword Start!", this.getClass().getName());

        UserInfoDTO rDTO;
        if (pDTO.getUserId() != null && !pDTO.getUserId().trim().isEmpty()) {
            rDTO = Optional.ofNullable(userInfoMapper.getUserForPassword(pDTO))
                    .orElseGet(UserInfoDTO::new);
        } else {
            rDTO = Optional.ofNullable(userInfoMapper.getUserId(pDTO))
                    .orElseGet(UserInfoDTO::new);
        }

        log.info("{}.searchUserIdOrPassword End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    public UserInfoDTO getLogin(UserInfoDTO pDTO) throws Exception {

        log.info("{}.getLogin Start", this.getClass().getName());

        UserInfoDTO rDTO = Optional.ofNullable(userInfoMapper.getLogin(pDTO)).orElseGet(UserInfoDTO::new);

        if (!CmmUtil.nvl(rDTO.getUserId()).isEmpty()) {

            MailDTO mDTO = new MailDTO();

            mDTO.setToMail(EncryptUtil.decAES128BCBC(CmmUtil.nvl(rDTO.getEmail())));
            mDTO.setTitle("로그인 알람!");

            mDTO.setContents(DateUtil.getDateTime("yyy.mm.dd.hh:ss") + "에 "
                        + CmmUtil.nvl(rDTO.getUserName()) + "님이 로그인하였습니다.");

            mailService.doSendMail(mDTO);
        }

        log.info("{}.getLogin End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    public UserInfoDTO getUserIdExists(UserInfoDTO pDTO) throws Exception {
        log.info("{}.getUserIdExists Start!", this.getClass().getName());

        UserInfoDTO rDTO = userInfoMapper.getUserIdExists(pDTO);

        log.info("{}.getUserIdExists End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    public UserInfoDTO getEmailExists(UserInfoDTO pDTO) throws Exception {
        log.info("{}.emailAuth Start!", this.getClass().getName());

        UserInfoDTO rDTO = Optional.ofNullable(userInfoMapper.getEmailExists(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("rDTO : {}", rDTO);

        if (CmmUtil.nvl(rDTO.getExistsYn()).equals("N")) {

            int authNumber = ThreadLocalRandom.current().nextInt(100000, 1000000);

            log.info("authNumber : {}", authNumber);

            MailDTO dto = new MailDTO();

            dto.setTitle("이메일 중복 확인 인증번호 발송 메일");
            dto.setContents("인증번호는 " + authNumber + " 입니다. ");
            dto.setToMail(EncryptUtil.decAES128BCBC(CmmUtil.nvl(pDTO.getEmail())));

            mailService.doSendMail(dto);

            dto = null;

            rDTO.setAuthNumber(authNumber);
        }

        log.info("{}.emailAuth End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    public UserInfoDTO emailAuthNumber(UserInfoDTO pDTO) throws Exception {

        log.info("{}.emailAuth Start!", this.getClass().getName());

        UserInfoDTO rDTO = Optional.ofNullable(userInfoMapper.emailAuthNumber(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("rDTO : {}", rDTO);
        log.info("rDTO.getExistsYn() : {}", rDTO.getExistsYn());

        if (CmmUtil.nvl(rDTO.getExistsYn()).equals("Y")) {

            int authNumber = ThreadLocalRandom.current().nextInt(100000, 1000000);
            log.info("authNumber : {}", authNumber);

            MailDTO dto = new MailDTO();

            dto.setTitle("아이디 찾기 인증번호 안내"); // 문구만 약간 일반화
            dto.setContents("인증번호는 " + authNumber + " 입니다.");
            dto.setToMail(CmmUtil.nvl(EncryptUtil.decAES128BCBC(pDTO.getEmail())));

            mailService.doSendMail(dto);
            dto = null;

            rDTO.setAuthNumber(authNumber);
        }

        log.info("{}.emailAuth End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    public UserInfoDTO emailAuthNumberPw(UserInfoDTO pDTO) throws Exception {

        log.info("{}.emailAuthNumberPw Start!", this.getClass().getName());

        UserInfoDTO rDTO = Optional.ofNullable(userInfoMapper.emailAuthNumberPw(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("rDTO : {}", rDTO);
        log.info("rDTO.getExistsYn() : {}", rDTO.getExistsYn());

        if (CmmUtil.nvl(rDTO.getExistsYn()).equals("Y")) {

            int authNumber = ThreadLocalRandom.current().nextInt(100000, 1000000);
            log.info("authNumber : {}", authNumber);

            MailDTO dto = new MailDTO();

            dto.setTitle("비밀번호 찾기 인증번호 안내");
            dto.setContents("인증번호는 " + authNumber + " 입니다.");
            dto.setToMail(CmmUtil.nvl(EncryptUtil.decAES128BCBC(pDTO.getEmail())));

            mailService.doSendMail(dto);
            dto = null;

            rDTO.setAuthNumber(authNumber);
        }

        log.info("{}.emailAuthNumberPw End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    public int insertUserInfo(UserInfoDTO pDTO) throws Exception {

        log.info("{}.insertUserInfo Start!", this.getClass().getName());

        int res;

        int success = userInfoMapper.insertUserInfo(pDTO);

        if (success > 0) {
            res = 1;

            MailDTO mDTO = new MailDTO();

            mDTO.setToMail(EncryptUtil.decAES128BCBC(CmmUtil.nvl(pDTO.getEmail())));

            mDTO.setTitle("회원가입을 축하드립니다.");

            mDTO.setContents(CmmUtil.nvl(pDTO.getUserName()) + "님의 회원가입을 진심으로 축하드립니다.");

            mailService.doSendMail(mDTO);

        } else {
            res = 0;
        }

        log.info("{}.insertUserInfo End!", this.getClass().getName());
        return res;
    }

    @Override
    public boolean saveUserTags(UserTagDTO dto) {
        int insertedCount = userInfoMapper.insertUserTags(dto);
        return insertedCount == dto.getTagList().size();
    }

    @Override
    public int countUserTags(UserTagDTO dto) throws Exception {
        return userInfoMapper.countUserTags(dto);
    }

    @Override
    public UserProfileDTO findUserProfileByUserId(UserProfileDTO pDTO) {
        log.info("[UserInfoService] findUserProfileByUserId start, pDTO={}", pDTO);

        UserProfileDTO rDTO = userInfoMapper.findUserProfileByUserId(pDTO);

        if (rDTO == null) {
            log.info("[UserInfoService] no profile found for userId={}", pDTO.getUserId());
            rDTO = new UserProfileDTO(); // NPE 방지
            rDTO.setUserId(pDTO.getUserId());
        }

        log.info("[UserInfoService] findUserProfileByUserId end, rDTO={}", rDTO);
        return rDTO;
    }



}

