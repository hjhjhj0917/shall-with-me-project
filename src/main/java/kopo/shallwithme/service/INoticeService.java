package kopo.shallwithme.service;

import kopo.shallwithme.dto.YouthPolicyDTO;

public interface INoticeService {

    YouthPolicyDTO getPolicyById(YouthPolicyDTO pDTO) throws Exception;
}
