package kopo.shallwithme.dto;


import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class TagDTO {
    private int tagId;
    private String tagName;

    private List<Integer> tagIds;
    private int page = 1;
    private int pageSize = 10;

    // offset 계산용 필드
    private int offset;

    // 결과용 필드
    private List<UserInfoDTO> users;
    private int totalCount;
    private int count;
    private int tagCount;
}
