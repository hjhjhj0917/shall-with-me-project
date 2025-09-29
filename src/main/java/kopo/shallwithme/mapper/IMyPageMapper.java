package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface IMyPageMapper {

    // 마이페이지 접속을 위한 비밀번호 확인
    UserInfoDTO pwCheck(UserInfoDTO pDTO) throws Exception;

    // 회원 탈퇴를 진행하기위한 이메일 확인
    UserInfoDTO emailCheck(UserInfoDTO pDTO) throws Exception;

    // 회원 비활성화
    int softDeleteUser(UserInfoDTO pDTO);

    // 회원 프로필 이미지 비활성화
    int deactivateProfile(UserProfileDTO pDTO);

    // 비활성 계정을 영구 삭제
    int deleteOldDeactivatedUsers();


    UserInfoDTO myPageUserInfo (UserInfoDTO pDTO) throws Exception;

    List<UserTagDTO> myPageUserTag(UserInfoDTO pDTO) throws Exception;
}
