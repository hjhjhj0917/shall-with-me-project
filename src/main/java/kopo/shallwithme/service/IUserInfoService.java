package kopo.shallwithme.service;


import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;

import java.util.List;

public interface IUserInfoService {
    int newPasswordProc(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO searchUserIdOrPasswordProc(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO emailAuthNumber(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO emailAuthNumberPw(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getLogin(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getUserIdExists(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getEmailExists(UserInfoDTO pDTO) throws Exception;

    int insertUserInfo(UserInfoDTO pDTO) throws Exception;

    boolean saveUserTags(UserTagDTO dto) throws Exception;

    int countUserTags(UserTagDTO dto) throws Exception;

    String getImageUrlByUserId(String userId);

    List<UserInfoDTO> getAllUsers();

    UserProfileDTO findUserProfileByUserId(UserProfileDTO pDTO);


}
