package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.UserInfoDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface IMyPageMapper {

    // 마이페이지 접속을 위한 비밀번호 확인
    UserInfoDTO pwCheck(UserInfoDTO pDTO) throws Exception;

    // 회원 탈퇴를 진행하기위한 이메일 확인
    UserInfoDTO emailCheck(UserInfoDTO pDTO) throws Exception;
}
