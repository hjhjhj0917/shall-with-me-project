package kopo.shallwithme.dto;

import lombok.Data;
import java.util.List;
import kopo.shallwithme.dto.UserTagDTO;
import java.util.ArrayList;

@Data
public class SharehouseCardDTO {

    private Long houseId;

    private String title;
    private String subText;

    // ✅ 주소 필드 2개로 분리
    private String address;        // 기본 주소 (addr1) - DB: ADDRESS
    private String detailAddress;  // 상세주소 (addr2) - DB: DETAIL_ADDRESS

    private String coverUrl;       // SHARE_HOUSE.image_url
    private String thumbnailUrl;   // 목록/단건 서브쿼리 결과용

    // 카드 표시용
    private Integer price;

    // 층 추가
    private Integer floorNumber;

    // INSERT 시 바인딩 (XML에서 #{regId})
    private String regId;

    private List<UserTagDTO> tags = new ArrayList<>();

    // ✅ JSP에서 사용하는 별칭 (getter만 제공)
    public String getAddr1() {
        return this.address;
    }

    public String getAddr2() {
        return this.detailAddress;
    }
}