package kopo.shallwithme.service;

import kopo.shallwithme.dto.YouthPolicyDTO;

import java.util.List;

public interface IYouthPolicyService {

    List<YouthPolicyDTO> getPolicies(int page, int size) throws Exception;

    int getTotalPolicyCount() throws Exception;
}
