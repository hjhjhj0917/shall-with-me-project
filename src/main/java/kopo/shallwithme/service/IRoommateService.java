package kopo.shallwithme.service;

import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import java.util.List;
import java.util.Map;

public interface IRoommateService {

    List<UserTagDTO> getUserTagsByUserId(String userId);

    void saveUserProfile(String userId, String introduction, String profileImageUrl) throws Exception;

    List<Map<String, Object>> getRoommateList(int page);

    UserProfileDTO getUserProfile(String userId);

    TagDTO searchUsersByTags(TagDTO pDTO);

    List<TagDTO> getAllTags() throws Exception;
}