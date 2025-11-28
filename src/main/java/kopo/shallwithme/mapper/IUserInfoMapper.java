package kopo.shallwithme.mapper;


import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface IUserInfoMapper {

    int updatePassword(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getUserId(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getLogin(UserInfoDTO pDTO) throws Exception;

    int insertUserInfo(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getUserIdExists(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getEmailExists(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO emailAuthNumber(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO emailAuthNumberPw(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getUserForPassword(UserInfoDTO pDTO) throws Exception;

    int insertUserTags(UserTagDTO dto);

    int countUserTags(UserTagDTO dto);

    List<UserTagDTO> findByUserId(UserInfoDTO pDTO);

    int upsertUserProfile(UserProfileDTO pDTO);

    UserProfileDTO getUserProfile(String userId);

    String selectProfileImageUrlByUserId(String userId);

    List<Map<String, Object>> getRoommateList(@Param("offset") int offset,
                                              @Param("limit") int limit);

    List<UserInfoDTO> getAllUsersWithProfile();

    List<String> getUserTags(String userId);

    UserInfoDTO getUserById(String userId);

    List<UserTagDTO> selectUserTags(String userId);

    UserProfileDTO findUserProfileByUserId(UserProfileDTO pDTO);

}
