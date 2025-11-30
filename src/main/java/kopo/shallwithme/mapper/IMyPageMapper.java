package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface IMyPageMapper {

    UserInfoDTO pwCheck(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO emailCheck(UserInfoDTO pDTO) throws Exception;

    int softDeleteUser(UserInfoDTO pDTO);

    int deactivateProfile(UserProfileDTO pDTO);

    int deleteOldDeactivatedUsers();

    UserInfoDTO myPageUserInfo (UserInfoDTO pDTO) throws Exception;

    List<UserTagDTO> myPageUserTag(UserInfoDTO pDTO) throws Exception;

    int updateIntroduction(UserProfileDTO pDTO);

    int updateProfileImage(UserProfileDTO pDTO);

    List<UserTagDTO> selectAllTagsWithType();

    List<UserTagDTO> selectMyTagSelectionsByUser(UserInfoDTO p);

    int deleteUserTagsByTagTypesOfTagIds(UserTagDTO p);

    int insertUserTagsFromIds(UserTagDTO p);

    List<TagDTO> selectMyTagNames(UserInfoDTO p);

    UserInfoDTO getPasswordHashByUserId(UserInfoDTO pDTO) throws Exception;

    int updateAddress(UserProfileDTO pDTO);

    void updateUserStatus(UserInfoDTO pDTO) throws Exception;
}
