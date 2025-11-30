package kopo.shallwithme.dto;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Data
public class SharehouseCardDTO {

    private Long houseId;

    private String title;
    private String subText;

    private String address;
    private String detailAddress;

    private String coverUrl;
    private String thumbnailUrl;

    private Integer price;
    private Integer floorNumber;
    private String regId;
    private List<UserTagDTO> tags = new ArrayList<>();

    public String getAddr1() {
        return this.address;
    }
    public String getAddr2() {
        return this.detailAddress;
    }
}