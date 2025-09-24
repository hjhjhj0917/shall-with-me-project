package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class UserProfileDTO {
    private String userId;          // 유저 아이디
    private String profileImageUrl; // 프로필 이미지 경로
    private String introduction;    // 자기소개
    private String userName;        // 이름
    private Integer age;            // 나이
    private String gender;          // 성별

    private String regDt;           // 등록일 (추가 데이터)
    private String chgDt;           // 수정일 (추가 데이터)

    private List<String> tags;
    private String status;
}