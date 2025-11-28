package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.TagDTO;
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
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class RoommateService implements IRoommateService {



    private final IRoommateMapper mapper;
    private final IUserInfoMapper userInfoMapper;
    private static final int DEFAULT_PAGE_SIZE = 10;



    @Override
    public List<UserTagDTO> getUserTagsByUserId(String userId) {
        if (userId == null || userId.isBlank()) {
            log.warn("User ID is null or blank. Returning empty tag list.");
            return List.of();
        }

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        return mapper.findByUserId(pDTO);
    }

    public Map<String, Object> getDisplayInfo(String userId) {
        Map<String, Object> result = new HashMap<>();

        if (userId == null || userId.isBlank()) {
            log.warn("User ID is null or blank. Returning empty info map.");
            return result;
        }

        List<UserTagDTO> userTags = mapper.selectUserTags(userId);

        UserTagDTO tag1 = userTags.stream()
                .filter(t -> t.getTagId() >= 5 && t.getTagId() <= 7)
                .findAny()
                .orElse(null);

        UserTagDTO tag2 = userTags.stream()
                .filter(t -> t.getTagId() >= 15 && t.getTagId() <= 16)
                .findAny()
                .orElse(null);

        result.put("tag1", tag1);
        result.put("tag2", tag2);

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
        int pageSize = (page == 1) ? 15 : 5;
        int offset = (page == 1) ? 0 : (15 + (page - 2) * 5);

        List<Map<String, Object>> baseList = mapper.getRoommateList(offset, pageSize);

        for (Map<String, Object> item : baseList) {
            String userId = (String) item.get("userId");

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

        UserProfileDTO user = mapper.findUserProfileById(userId);

        if (user != null) {
            List<UserTagDTO> tagList = mapper.selectUserTags(userId);

            List<String> tagNames = tagList.stream()
                    .map(UserTagDTO::getTagName)
                    .collect(Collectors.toList());

            user.setTags(tagNames);
        }

        return user;
    }

    @Override
    public TagDTO searchUsersByTags(TagDTO pDTO) {
        log.info("{}.searchUsersByTags Start! Received DTO: {}", this.getClass().getName(), pDTO.toString());

        Map<String, List<Integer>> tagGroupMap = pDTO.getTagGroupMap();
        String location = pDTO.getLocation();
        List<UserInfoDTO> users;
        int totalCount;

        boolean hasTags = tagGroupMap != null && !tagGroupMap.isEmpty();
        boolean hasLocation = location != null && !location.isEmpty();

        if (hasTags || hasLocation) {
            users = mapper.selectUsersByTagsWithPagination(pDTO);
            totalCount = mapper.countUsersByTags(pDTO).getCount();
        } else {
            users = mapper.selectUsersByPagination(pDTO);
            totalCount = mapper.countAllUsers(pDTO).getCount();
        }

        for (UserInfoDTO user : users) {
            List<UserTagDTO> tags = mapper.selectUserTags(user.getUserId());

            String tag1 = tags.stream()
                    .filter(t -> t.getTagId() >= 5 && t.getTagId() <= 7)
                    .map(UserTagDTO::getTagName)
                    .findFirst()
                    .orElse(null);

            String tag2 = tags.stream()
                    .filter(t -> t.getTagId() >= 15 && t.getTagId() <= 16)
                    .map(UserTagDTO::getTagName)
                    .findFirst()
                    .orElse(null);

            user.setTag1(tag1);
            user.setTag2(tag2);

            if ("M".equalsIgnoreCase(user.getGender())) {
                user.setGenderLabel("남");
            } else if ("F".equalsIgnoreCase(user.getGender())) {
                user.setGenderLabel("여");
            } else {
                user.setGenderLabel("기타");
            }
        }

        pDTO.setUsers(users);
        pDTO.setTotalCount(totalCount);

        boolean isLast = (pDTO.getOffset() + users.size()) >= totalCount;
        pDTO.setLastPage(isLast);

        log.info("Pagination Info -> PageSize: {}, Offset: {}, UsersOnPage: {}, TotalCount: {}, IsLastPage: {}",
                pDTO.getPageSize(), pDTO.getOffset(), users.size(), totalCount, isLast);

        log.info("{}.searchUsersByTags End!", this.getClass().getName());
        return pDTO;
    }


    @Override
    public List<TagDTO> getAllTags() throws Exception {
        log.info("{}.getAllTags Start!", this.getClass().getName());

        List<TagDTO> rList = mapper.getAllTags();
        log.info("rList : {}", rList);

        log.info("{}.getAllTags End!", this.getClass().getName());

        return rList;
    }
}

