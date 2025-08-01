package kopo.shallwithme.service;


import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserTagDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

public interface IUserInfoService {
    //비밀번호 재설정
    int newPasswordProc(UserInfoDTO pDTO) throws Exception;

    //아이디, 비밀번호 찾기에 활용
    UserInfoDTO searchUserIdOrPasswordProc(UserInfoDTO pDTO) throws Exception;

    // 로그인을 위해 아이디와 비밀번호가 일치하는지 확인하기
    UserInfoDTO getLogin(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getUserIdExists(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getEmailExists(UserInfoDTO pDTO) throws Exception;

    int insertUserInfo(UserInfoDTO pDTO) throws Exception;

    boolean saveUserTags(UserTagDTO dto) throws Exception;

    int countUserTags(UserTagDTO dto) throws Exception;

}
