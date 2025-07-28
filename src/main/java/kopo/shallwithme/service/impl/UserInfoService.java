package kopo.shallwithme.service.impl;

import kopo.shallwithme.mapper.UserInfoMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional
public class UserInfoService {

    private final UserInfoMapper userInfoMapper;

    public void saveUserTags(String userId, Map<String, String> tags) {

        for (Map.Entry<String, String> entry : tags.entrySet()) {
            String tagType = entry.getKey();     // 예: "ME", "PREF"
            String tagName = entry.getValue();   // 예: "아침형", "프리랜서/무직" 등

            Integer tagId = userInfoMapper.findTagIdByName(tagName);
            if (tagId == null) {
                throw new IllegalArgumentException("해당 태그를 찾을 수 없습니다: " + tagName);
            }

            userInfoMapper.insertUserTag(userId, tagId, tagType);
        }
    }
}
