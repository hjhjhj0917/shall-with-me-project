package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.mapper.IUserInfoMapper;
import kopo.shallwithme.service.IRoommateService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class RoommateService implements IRoommateService {

    private final IUserInfoMapper mapper;

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

    @Override
    public void saveUserProfile(String userId, String introduction, String profileImageUrl) throws Exception {
        if (userId == null || userId.isBlank()) {
            throw new IllegalArgumentException("userId is required");
        }
        UserProfileDTO pDTO = new UserProfileDTO();
        pDTO.setUserId(userId);
        pDTO.setIntroduction(introduction);
        pDTO.setProfileImageUrl(profileImageUrl);
        mapper.upsertUserProfile(pDTO);
        log.info("User profile saved. userId={}, imageUrl={}", userId, profileImageUrl);
    }

    @Override
    public List<Map<String, Object>> getRoommateList(int page) {
        return List.of();
    }
}

