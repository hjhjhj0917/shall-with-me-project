package kopo.shallwithme.dto;

import lombok.Data;
import java.util.List;

@Data
public class SharehouseCardDTO {
    private Long houseId;      // 상세로 이동할 키
    private String title;      // 예: "동래구의 아파트"
    private String subText;    // 예: "9월 5일~7일" 또는 "부산 동래구"
    private Integer price;     // 표시 금액(월세/총비용 등)
    private String coverUrl;   // 대표 이미지 URL
    private List<String> tags; // 옵션: 카드 하단 태그 0~3개
}