package kopo.shallwithme.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@JsonIgnoreProperties(ignoreUnknown = true)  // DTO에 없는 필드 무시
public class YouthPolicyDTO {
    private String plcyNo;              // 정책번호
    private String plcyNm;              // 정책명
    private String plcyKywdNm;          // 정책키워드명
    private String plcyExplnCn;         // 정책설명내용
    private String lclsfNm;             // 정책대분류명
    private String mclsfNm;             // 정책중분류명
    private String sprvsnInstCdNm;      // 주관기관코드명
    private String bizPrdBgngYmd;       // 사업기간 시작일
    private String bizPrdEndYmd;        // 사업기간 종료일
    private String aplyUrlAddr;         // 신청 URL 주소
    private String inqCnt;              // 조회수

    private int page = 1;   // 기본값 1
    private int size = 10;  // 기본값 10
}
