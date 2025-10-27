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
    private String birthDate;
    private String addr1;
    private String addr2;          // 상세주소 (★ 누락으로 인해 오류 발생)

    private String regDt;           // 등록일 (추가 데이터)
    private String chgDt;           // 수정일 (추가 데이터)

    private List<String> tags;
    private String status;

    // 아래 필드들도 선택적으로 이미 존재할 수 있음
    private String zipCode;
    private String roadAddress;
    private String jibunAddress;
    private String extraAddress;
}