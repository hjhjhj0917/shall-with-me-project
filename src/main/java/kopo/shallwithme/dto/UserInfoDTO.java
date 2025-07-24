package kopo.shallwithme.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

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
    private String existsYn; // 중복 가입을 방지하기 위해 사용할 변수
    private int authNumber; // 메일 중복체크를 위한 인증번호
}
