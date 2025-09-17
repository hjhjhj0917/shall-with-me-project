package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.mapper.IRoommateMapper;
import kopo.shallwithme.mapper.IUserInfoMapper;
import kopo.shallwithme.service.IRoommateService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class RoommateService implements IRoommateService {

    private final IRoommateMapper mapper;
    private final IUserInfoMapper userInfoMapper;

    @Override
    public List<UserTagDTO> getUserTagsByUserId(String userId) {
        if (userId == null || userId.isBlank()) {
            log.warn("User ID is null or blank. Returning empty tag list.");
            return List.of();
        }

        // DTO 생성해서 userId 세팅 후 매퍼로 전달 (XML: parameterType=UserInfoDTO와 일치)
        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        return mapper.findByUserId(pDTO);
    }

    /**
     * ✅ 룸메이트 카드에 표시할 태그/성별 가공
     *  - 태그1: tagId 5~7 중 첫 번째
     *  - 태그2: tagId 15~17 중 첫 번째
     *  - 성별: USER_INFO.GENDER → M=남, F=여
     */
    public Map<String, Object> getDisplayInfo(String userId) {
        Map<String, Object> result = new HashMap<>();

        if (userId == null || userId.isBlank()) {
            log.warn("User ID is null or blank. Returning empty info map.");
            return result;
        }

        // 1. 태그 조회
        List<UserTagDTO> userTags = mapper.selectUserTags(userId);

        // 태그1 → tagId 5~7 중 DB에 저장된 값
        UserTagDTO tag1 = userTags.stream()
                .filter(t -> t.getTagId() >= 5 && t.getTagId() <= 7)
                .findAny() // 아무거나 1개
                .orElse(null);

        // 태그2 → tagId 15~17 중 DB에 저장된 값
        UserTagDTO tag2 = userTags.stream()
                .filter(t -> t.getTagId() >= 15 && t.getTagId() <= 17)
                .findAny()
                .orElse(null);

        result.put("tag1", tag1);
        result.put("tag2", tag2);

        // 2. 성별 조회
        UserInfoDTO user = mapper.getUserById(userId);
        String gender = "기타";
        if ("M".equalsIgnoreCase(user.getGender())) {
            gender = "남";
        } else if ("F".equalsIgnoreCase(user.getGender())) {
            gender = "여";
        }
        result.put("gender", gender);

        return result;
    }


    @Override
    public void saveUserProfile(String userId, String introduction, String profileImageUrl) throws Exception {
        if (userId == null || userId.isBlank()) {
            throw new IllegalArgumentException("userId is required");
        }
        UserProfileDTO pDTO = new UserProfileDTO();
        pDTO.setUserId(userId);
        pDTO.setIntroduction(introduction);
        pDTO.setProfileImageUrl(profileImageUrl);
        userInfoMapper.upsertUserProfile(pDTO);
        log.info("User profile saved. userId={}, imageUrl={}", userId, profileImageUrl);
    }

    @Override
    public List<Map<String, Object>> getRoommateList(int page) {
        // ✅ 첫 페이지는 12장, 그 이후는 4장씩
        int pageSize = (page == 1) ? 12 : 4;
        int offset   = (page == 1) ? 0 : (12 + (page - 2) * 4);

        List<Map<String, Object>> baseList = mapper.getRoommateList(offset, pageSize);

        for (Map<String, Object> item : baseList) {
            String userId = (String) item.get("userId");

            // tag1, tag2, gender 조회
            Map<String, Object> displayInfo = getDisplayInfo(userId);
            UserTagDTO tag1 = (UserTagDTO) displayInfo.get("tag1");
            UserTagDTO tag2 = (UserTagDTO) displayInfo.get("tag2");

            item.put("tag1", (tag1 != null) ? tag1.getTagName() : null);
            item.put("tag2", (tag2 != null) ? tag2.getTagName() : null);
            item.put("gender", displayInfo.get("gender"));
        }

        return baseList;
    }

    @Override
    public UserProfileDTO getUserProfile(String userId) {
        if (userId == null || userId.isBlank()) {
            return null;
        }
        return mapper.findUserProfileById(userId); // Mapper 호출
    }

}

