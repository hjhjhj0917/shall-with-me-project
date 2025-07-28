package kopo.shallwithme.service;


import kopo.shallwithme.dto.UserInfoDTO;

import java.util.Map;

public interface IUserInfoService {

    UserInfoDTO getUserIdExists(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getEmailExists(UserInfoDTO pDTO) throws Exception;

    int insertUserInfo(UserInfoDTO pDTO) throws Exception;

    void saveUserTags(String userId, Map<String, String> tags);

}
