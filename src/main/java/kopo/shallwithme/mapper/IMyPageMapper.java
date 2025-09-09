package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.UserInfoDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface IMyPageMapper {

    UserInfoDTO pwCheck(UserInfoDTO pDTO) throws Exception;
}
