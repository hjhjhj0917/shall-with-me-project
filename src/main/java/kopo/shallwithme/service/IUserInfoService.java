package kopo.shallwithme.service;

import java.util.Map;

public interface IUserInfoService {
    void saveUserTags(String userId, Map<String, String> tags);
}
