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
    private String plcyKywdNm;          // 정책키워드명 (테이블에 없지만 API 출력에 있음)
    private String plcyExplnCn;         // 정책설명내용
    private String lclsfNm;             // 정책대분류명 (테이블에 없지만 API 출력에 있음)
    private String mclsfNm;             // 정책중분류명 (테이블에 없지만 API 출력에 있음)
    private String sprvsnInstCdNm;      // 주관기관코드명
    private String bizPrdBgngYmd;       // 사업기간 시작일
    private String bizPrdEndYmd;        // 사업기간 종료일
    private String aplyUrlAddr;         // 신청 URL 주소
    private int inqCnt;                 // 조회수

    // 상세보기용 추가 필드
    private String plcySprtCn;          // 정책 지원 내용
    private String plcyAplyMthdCn;      // 정책 신청 방법
    private String sbmsnDcmntCn;        // 제출 서류
    private String sprtTrgtMinAge;      // 지원 대상 최소 연령
    private String sprtTrgtMaxAge;      // 지원 대상 최대 연령
    private String earnMinAmt;          // 소득 최소 금액
    private String earnMaxAmt;          // 소득 최대 금액
    private String earnEtcCn;           // 소득 기타 조건
    private String addAplyQlfcCndCn;    // 추가 신청자격 조건
    private String ptcpPrpTrgtCn;       // 참여 제안 대상 내용
    private String refUrlAddr1;         // 참고 URL 1
    private String refUrlAddr2;         // 참고 URL 2
    private String operInstCdNm;        // 운영기관 이름

    private int page = 1;   // 기본값 1
    private int size = 10;  // 기본값 10
}
