package kopo.shallwithme.service;

import kopo.shallwithme.dto.YouthPolicyDTO;

import java.util.List;

public interface IYouthPolicyService {

    /**
     * 1. 컨트롤러용: 페이징 처리된 정책 목록 조회
     */
    List<YouthPolicyDTO> getPolicies(int page, int size) throws Exception;

    /**
     * 2. 컨트롤러용: 전체 정책 개수 조회 (페이지네이션 계산용)
     */
    int getTotalPolicyCount() throws Exception;

    /**
     * 3. PolicyEmbeddingService용: 모든 정책 목록 조회
     */
    List<YouthPolicyDTO> getPolicies() throws Exception;

    /**
     * 4. PolicyUpdateScheduler용: 증분 업데이트 실행
     */
    void fetchAndSavePolicies() throws Exception;
}
