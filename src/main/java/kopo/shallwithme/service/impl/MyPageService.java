package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.mapper.IMyPageMapper;
import kopo.shallwithme.service.IMyPageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

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

}
