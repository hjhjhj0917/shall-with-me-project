package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.YouthPolicyDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface INoticeMapper {

    YouthPolicyDTO getPolicyById(YouthPolicyDTO pDTO) throws Exception;
}
