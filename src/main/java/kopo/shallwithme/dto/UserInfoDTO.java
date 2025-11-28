package kopo.shallwithme.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_DEFAULT)
public class UserInfoDTO {

    private String userId;
    private String userName;
    private String password;
    private String email;
    private String addr1;
    private String addr2;
    private String regId;
    private String regDt;
    private String chgId;
    private String chgDt;
    private int age;
    private String gender;
    private Date birthDate;
    private String status;
    private LocalDateTime deletedAt;

    private String existsYn;
    private int authNumber;

    private String tagId;
    private String tagType;

    private String profileImageUrl;
    private String introduction;

    private List<String> tags;
    private String tag1;
    private String tag2;
    private String genderLabel;
}
