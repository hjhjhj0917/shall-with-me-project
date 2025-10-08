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

    // INSERT 및 상세용
    private String address;        // DB가 NOT NULL이면 반드시 값 채워야 함
    private String coverUrl;       // SHARE_HOUSE.image_url
    private String thumbnailUrl;   // 목록/단건 서브쿼리 결과용

    // 카드 표시용
    private Integer price;

    // INSERT 시 바인딩 (XML에서 #{regId})
    private String regId;
    // import java.util.*;
    private List<UserTagDTO> tags = new ArrayList<>();

}
