package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.SpamDTO;
import kopo.shallwithme.service.ISpamService;
import kopo.shallwithme.service.ITestService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@RequiredArgsConstructor
@Service
public class TestService implements ITestService {

    private final ISpamService spamService;

    @Override
    public SpamDTO test(SpamDTO pDTO) {
        return spamService.predict(pDTO);
    }
}
