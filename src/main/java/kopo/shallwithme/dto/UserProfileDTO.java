package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class UserProfileDTO {
    private String userId;
    private String profileImageUrl;
    private String introduction;
    private String userName;
    private Integer age;
    private String gender;
    private String birthDate;
    private String addr1;
    private String addr2;

    private String regDt;
    private String chgDt;

    private List<String> tags;
    private String status;

    private String zipCode;
    private String roadAddress;
    private String jibunAddress;
    private String extraAddress;
}