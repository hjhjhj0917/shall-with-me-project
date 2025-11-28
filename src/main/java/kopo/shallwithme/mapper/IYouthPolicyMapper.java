package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.YouthPolicyDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface IYouthPolicyMapper {

    List<YouthPolicyDTO> getPolicyList();

    YouthPolicyDTO getPolicyById(String plcyNo);

    void insertPolicy(YouthPolicyDTO pDTO);

    void deleteAllPolicies();

    List<YouthPolicyDTO> getPolicyListPaginated(@Param("offset") int offset, @Param("limit") int limit);

    int getTotalPolicyCount();
}
