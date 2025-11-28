package kopo.shallwithme.dto;


import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Getter
@Setter
public class TagDTO {
    private int tagId;
    private String tagName;

    private int page = 1;
    private int pageSize = 10;

    private int offset;
    private boolean lastPage;

    private List<UserInfoDTO> users;
    private int totalCount;
    private int count;
    private String location;

    private Map<String, List<Integer>> tagGroupMap;
}
