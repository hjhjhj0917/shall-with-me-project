package kopo.shallwithme.service;


import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserTagDTO;

import java.util.List;
import java.util.Map;

public interface IUserInfoService {

    UserInfoDTO getUserIdExists(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getEmailExists(UserInfoDTO pDTO) throws Exception;

    int insertUserInfo(UserInfoDTO pDTO) throws Exception;

    boolean saveUserTags(UserTagDTO dto) throws Exception;

}
