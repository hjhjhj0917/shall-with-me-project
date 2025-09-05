package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserProfileDTO {
    private String userId;
    private String profileImageUrl;
    private String introduction;
    private String regDt;
    private String chgDt;

    private String userName;
}
