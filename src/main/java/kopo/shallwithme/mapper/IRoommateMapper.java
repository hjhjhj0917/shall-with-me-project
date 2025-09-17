package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface IRoommateMapper {

    // 유저 태그 조회
    List<UserTagDTO> findByUserId(UserInfoDTO pDTO);

    // 룸메이트 카드 리스트 (페이징)
    List<Map<String, Object>> getRoommateList(int offset, int pageSize);

    // 성별, 유저 기본정보 조회
    UserInfoDTO getUserById(String userId);

    // 태그만 따로 조회
    List<UserTagDTO> selectUserTags(String userId);

    UserProfileDTO findUserProfileById(String userId);
}
