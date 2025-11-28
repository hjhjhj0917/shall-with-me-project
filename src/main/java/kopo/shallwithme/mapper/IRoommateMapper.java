package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.dto.TagDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface IRoommateMapper {

    List<UserTagDTO> findByUserId(UserInfoDTO pDTO);

    List<Map<String, Object>> getRoommateList(int offset, int pageSize);

    UserInfoDTO getUserById(String userId);

    List<UserTagDTO> selectUserTags(String userId);

    UserProfileDTO findUserProfileById(String userId);

    List<UserInfoDTO> selectUsersByPagination(TagDTO tagDTO);

    TagDTO countAllUsers(TagDTO pDTO);

    List<UserInfoDTO> selectUsersByTagsWithPagination(TagDTO pDTO);

    TagDTO countUsersByTags(TagDTO pDTO);

    List<TagDTO> getAllTags() throws Exception;

}
