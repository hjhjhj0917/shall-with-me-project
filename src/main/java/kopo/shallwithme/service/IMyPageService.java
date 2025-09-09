package kopo.shallwithme.service;

import kopo.shallwithme.dto.UserInfoDTO;

public interface IMyPageService {

    UserInfoDTO pwCheck(UserInfoDTO pDTO) throws Exception;
}
