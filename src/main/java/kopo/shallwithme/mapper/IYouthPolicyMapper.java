package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.YouthPolicyDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface IYouthPolicyMapper {

    // 1. 임베딩용 전체 목록 조회
    List<YouthPolicyDTO> getPolicyList();

    // 2. 증분 업데이트 시 중복 확인용
    YouthPolicyDTO getPolicyById(String plcyNo);

    // 3. 증분 업데이트 시 신규 삽입용
    void insertPolicy(YouthPolicyDTO pDTO);

    // 4. (예비용)
    void deleteAllPolicies();

    // 5. 컨트롤러 페이징용
    List<YouthPolicyDTO> getPolicyListPaginated(@Param("offset") int offset, @Param("limit") int limit);

    // 6. 컨트롤러 페이징용
    int getTotalPolicyCount();
}
