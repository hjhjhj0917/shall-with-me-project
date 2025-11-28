package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SharehouseImageDTO {

    private Integer imgId;
    private Integer houseId;
    private String url;
    private Integer isMain;
    private Integer sortOrder;
    private String regDt;
}
