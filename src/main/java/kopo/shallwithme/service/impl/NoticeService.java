package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.YouthPolicyDTO;
import kopo.shallwithme.mapper.INoticeMapper;
import kopo.shallwithme.service.INoticeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@RequiredArgsConstructor
@Service
public class NoticeService implements INoticeService {

    private final INoticeMapper noticeMapper;

    @Override
    public YouthPolicyDTO getPolicyById(YouthPolicyDTO pDTO) throws Exception {
        log.info("{}.getPolicyById Start!", this.getClass().getName());

        YouthPolicyDTO rDTO = noticeMapper.getPolicyById(pDTO);

        log.info("{}.getPolicyById End!", this.getClass().getName());

        return rDTO;
    }
}
