package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.MailDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.mapper.IMyPageMapper;
import kopo.shallwithme.service.IMailService;
import kopo.shallwithme.service.IMyPageService;
import kopo.shallwithme.util.CmmUtil;
import kopo.shallwithme.util.EncryptUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Slf4j
@RequiredArgsConstructor
@Service
public class MyPageService implements IMyPageService {

    private final IMyPageMapper myPageMapper;
    private final IMailService mailService;

    @Override
    public int deactivateProfile(UserProfileDTO pDTO) throws Exception {
        log.info("{}.deactivateProfile Start!", this.getClass().getName());

        int res = myPageMapper.deactivateProfile(pDTO);

        log.info("{}.deactivateProfile End!", this.getClass().getName());

        return res;
    }

    @Override
    public UserInfoDTO pwCheck(UserInfoDTO pDTO) throws Exception {

        log.info("{}.pwCheck Start", this.getClass().getName());

        UserInfoDTO rDTO = Optional.ofNullable(myPageMapper.pwCheck(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("{}.pwCheck End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    public UserInfoDTO emailCheck(UserInfoDTO pDTO) throws Exception {

        log.info("{}.emailCheck Start!", this.getClass().getName());

        UserInfoDTO rDTO = Optional.ofNullable(myPageMapper.emailCheck(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("rDTO : {}", rDTO);
        log.info("rDTO.getExistsYn() : {}", rDTO.getExistsYn());

        log.info("{}.emailCheck End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    @Transactional
    public int deactivateUser(UserInfoDTO pDTO) throws Exception{
        log.info("{}.deactivateUser Start!", this.getClass().getName());

        int res = myPageMapper.softDeleteUser(pDTO);

        if (res > 0) {
            log.info("{} 회원 탈퇴 메일 전송 시작!", this.getClass().getName());

            MailDTO dto = new MailDTO();

            dto.setTitle("[살며시] " + pDTO.getUserName() + "님, 회원 탈퇴 신청이 정상적으로 처리되었습니다.");
            dto.setContents(pDTO.getUserName() + "님, '살며시'와의 동행을 마무리하시는군요.\n" +
                    "\n" +
                    "회원님의 탈퇴 신청이 정상적으로 처리되었습니다.\n" +
                    "지금부터 회원님의 계정은 비활성화 상태로 전환되며, 더 이상 로그인하실 수 없습니다.\n" +
                    "\n" +
                    "그동안 '살며시(shall with me)'와 함께 새로운 인연과 공간을 찾아주셔서 진심으로 감사했습니다.\n" +
                    "회원님께서 남겨주신 소중한 흔적들이 저희 서비스를 더욱 따뜻한 공간으로 만들어 주었습니다.");
            dto.setToMail(EncryptUtil.decAES128BCBC(pDTO.getEmail()));

            mailService.doSendMail(dto);

            dto = null;

            log.info("{} 회원 탈퇴 메일 전송 종료!", this.getClass().getName());
        }

        log.info("{}.deactivateUser End!", this.getClass().getName());

        return res;
    }

    @Override
    @Transactional
    public int hardDeleteDeactivatedUsers() {
        log.info("{}.hardDeleteDeactivatedUsers Start!", this.getClass().getName());

        int res = myPageMapper.deleteOldDeactivatedUsers();

        log.info("{}.hardDeleteDeactivatedUsers End!", this.getClass().getName());

        return res;
    }

}
