package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.MailDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.mapper.IMyPageMapper;
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
    public int deactivateUser(UserInfoDTO pDTO) {
        log.info("{}.deactivateUser Start!", this.getClass().getName());

        int res = myPageMapper.softDeleteUser(pDTO);

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
