package kopo.shallwithme.service;

import kopo.shallwithme.dto.UserInfoDTO;

public interface IMyPageService {

    // 마이페이지 접속을 위한 비밀번호 확인
    UserInfoDTO pwCheck(UserInfoDTO pDTO) throws Exception;

    // 회원 탈퇴를 진행하기위한 이메일 확인
    UserInfoDTO emailCheck(UserInfoDTO pDTO) throws Exception;

    // 회원 비활성화
    int deactivateUser(UserInfoDTO pDTO);

    // 비활성 계정을 영구 삭제
    int hardDeleteDeactivatedUsers();

}
