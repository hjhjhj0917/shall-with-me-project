package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SharehouseImageDTO {

    private Integer imgId;      // PK
    private Integer houseId;    // FK (SHARE_HOUSE.house_id)
    private String url;         // 파일 경로 또는 접근 URL
    private Integer isMain;     // 대표 이미지 여부 (0=일반, 1=대표)
    private Integer sortOrder;  // 정렬 순서 (0~4)
    private String regDt;       // 등록일시
}
