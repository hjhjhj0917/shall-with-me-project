package kopo.shallwithme.service;

import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;

import java.util.List;

public interface IMyPageService {

    UserInfoDTO pwCheck(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO emailCheck(UserInfoDTO pDTO) throws Exception;

    int deactivateUser(UserInfoDTO pDTO) throws Exception;

    int deactivateProfile(UserProfileDTO pDTO) throws Exception;

    int hardDeleteDeactivatedUsers();

    UserInfoDTO myPageUserInfo(UserInfoDTO pDTO) throws Exception;

    List<UserTagDTO> myPageUserTag(UserInfoDTO pDTO) throws Exception;

    int updateIntroduction(UserProfileDTO pDTO) throws Exception; // ← 추가

    int updateProfileImage(UserProfileDTO pDTO);

    List<UserTagDTO> getAllTagsWithType();

    List<UserTagDTO> getMyTagSelections(UserInfoDTO p);

    int updateMyTagsByGroup(UserTagDTO p);

    List<TagDTO> getMyTagChips(UserInfoDTO p);

    boolean verifyPassword(UserInfoDTO pDTO) throws Exception;

    int updateAddress(UserProfileDTO pDTO);

    void updateUserStatus(UserInfoDTO pDTO) throws Exception;
}
