package kopo.shallwithme.service;

import kopo.shallwithme.dto.UserTagDTO;
import java.util.List;

public interface IRoommateService {
    List<UserTagDTO> getUserTagsByUserId(String userId);
    void saveUserProfile(String userId, String introduction, String profileImageUrl) throws Exception;
}