package kopo.shallwithme.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@JsonIgnoreProperties(ignoreUnknown = true)
public class YouthPolicyDTO {
    private String plcyNo;
    private String plcyNm;
    private String plcyKywdNm;
    private String plcyExplnCn;
    private String lclsfNm;
    private String mclsfNm;
    private String sprvsnInstCdNm;
    private String bizPrdBgngYmd;
    private String bizPrdEndYmd;
    private String aplyUrlAddr;
    private int inqCnt;

    private String plcySprtCn;
    private String plcyAplyMthdCn;
    private String sbmsnDcmntCn;
    private String sprtTrgtMinAge;
    private String sprtTrgtMaxAge;
    private String earnMinAmt;
    private String earnMaxAmt;
    private String earnEtcCn;
    private String addAplyQlfcCndCn;
    private String ptcpPrpTrgtCn;
    private String refUrlAddr1;
    private String refUrlAddr2;
    private String operInstCdNm;

    private int page = 1;
    private int size = 10;
}
