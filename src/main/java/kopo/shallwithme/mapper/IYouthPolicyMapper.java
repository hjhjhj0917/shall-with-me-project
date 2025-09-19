package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.YouthPolicyDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface IYouthPolicyMapper {

    // DB에 저장된 모든 정책 목록 조회 (공지사항/챗봇용)
    List<YouthPolicyDTO> getPolicyList();

    // 새로운 정책 데이터를 DB에 삽입
    void insertPolicy(YouthPolicyDTO pDTO);

    // 데이터 갱신 전, 기존의 모든 정책 데이터를 삭제
    void deleteAllPolicies();
}
