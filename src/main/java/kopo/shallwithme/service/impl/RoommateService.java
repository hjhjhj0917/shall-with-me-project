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

        // DTO 생성해서 userId 세팅 후 매퍼로 전달 (XML: parameterType=UserInfoDTO와 일치)
        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        return mapper.findByUserId(pDTO);
    }

    /**
     * ✅ 룸메이트 카드에 표시할 태그/성별 가공
     * - 태그1: tagId 5~7 중 첫 번째
     * - 태그2: tagId 15~17 중 첫 번째
     * - 성별: USER_INFO.GENDER → M=남, F=여
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
                .filter(t -> t.getTagId() >= 15 && t.getTagId() <= 16)
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
        int pageSize = (page == 1) ? 15 : 5;
        int offset = (page == 1) ? 0 : (15 + (page - 2) * 5);

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

        // 1) 기본 프로필 정보 가져오기
        UserProfileDTO user = mapper.findUserProfileById(userId);

        if (user != null) {
            // 2) 해당 유저의 태그 리스트 가져오기
            List<UserTagDTO> tagList = mapper.selectUserTags(userId);

            // 3) 태그 이름만 추출해서 String 리스트로 변환
            List<String> tagNames = tagList.stream()
                    .map(UserTagDTO::getTagName)
                    .collect(Collectors.toList());

            // 4) DTO에 태그 추가
            user.setTags(tagNames);
        }

        return user;
    }

    @Override
    public TagDTO searchUsersByTags(TagDTO pDTO) {
        log.info("{}.searchUsersByTags Start! Received DTO: {}", this.getClass().getName(), pDTO.toString());

        // DTO에서 새로운 필드들을 가져옴
        Map<String, List<Integer>> tagGroupMap = pDTO.getTagGroupMap();
        String location = pDTO.getLocation();
        List<UserInfoDTO> users;
        int totalCount; // long 타입으로 변경하여 더 큰 숫자를 안전하게 처리

        // 태그 또는 지역 조건이 있는지 확인
        boolean hasTags = tagGroupMap != null && !tagGroupMap.isEmpty();
        boolean hasLocation = location != null && !location.isEmpty();

        // pDTO 객체는 offset과 pageSize 값을 이미 가지고 매퍼로 전달됩니다.
        if (hasTags || hasLocation) {
            users = mapper.selectUsersByTagsWithPagination(pDTO);
            totalCount = mapper.countUsersByTags(pDTO).getCount();
        } else {
            users = mapper.selectUsersByPagination(pDTO);
            totalCount = mapper.countAllUsers(pDTO).getCount();
        }

        // 사용자별 tag1/tag2/genderLabel 세팅 (이 로직은 그대로 유지)
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

        // [수정] DTO에 담겨온 offset 값을 사용하여 isLast 계산
        boolean isLast = (pDTO.getOffset() + users.size()) >= totalCount;
        pDTO.setLastPage(isLast);

        // [수정] DTO에 담겨온 값으로 로그 출력
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

