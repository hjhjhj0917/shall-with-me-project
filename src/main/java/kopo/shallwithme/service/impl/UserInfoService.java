package kopo.shallwithme.service.impl;

import kopo.shallwithme.mapper.UserInfoMapper;
import kopo.shallwithme.service.IUserInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class UserInfoService implements IUserInfoService {

    private final UserInfoMapper userInfoMapper;

    @Override
    public void saveUserTags(String userId, Map<String, String> tags) {
        for (Map.Entry<String, String> entry : tags.entrySet()) {
            userInfoMapper.insertUserTag(userId, entry.getKey(), entry.getValue());
        }
    }
}
