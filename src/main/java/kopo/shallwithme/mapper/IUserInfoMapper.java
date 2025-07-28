package kopo.shallwithme.mapper;


import kopo.shallwithme.dto.UserInfoDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface IUserInfoMapper {

    int insertUserInfo(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getUserIdExists(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getEmailExists(UserInfoDTO pDTO) throws Exception;

    Integer findTagIdByName(@Param("tagName") String tagName);

    void insertUserTag(@Param("userId") String userId,
                       @Param("tagId") int tagId,
                       @Param("tagType") String tagType);
}


