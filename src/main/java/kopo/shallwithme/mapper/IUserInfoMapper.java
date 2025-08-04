package kopo.shallwithme.mapper;


import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserTagDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.Map;

@Mapper
public interface IUserInfoMapper {
    //비밀번호 재설정
    int updatePassword(UserInfoDTO pDTO) throws Exception;
    /*
    아이디, 비밀번호 찾기에 활용
    1.이름과 이메일이 맞다면, 아이디 알려주기
    2.아이디, 이름과 이메일이 맞다면, 비밀번호 재설정하기
     */
    UserInfoDTO getUserId(UserInfoDTO pDTO) throws Exception;

    //로그인을 위해 아이디와 비밀번호가 일치하는지 확인하기
    UserInfoDTO getLogin(UserInfoDTO pDTO) throws Exception;

    int insertUserInfo(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getUserIdExists(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getEmailExists(UserInfoDTO pDTO) throws Exception;

    // 태그 삽입
    int insertUserTags(UserTagDTO dto);

    // DB에 저장된 태그 개수 확인
    int countUserTags(UserTagDTO dto);
}


