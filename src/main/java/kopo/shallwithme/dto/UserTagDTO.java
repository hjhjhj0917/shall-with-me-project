package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class UserTagDTO {
    private String userId;
    private Long tagId;
    private String tagType;
    private List<Integer> tagList;
    private String tagName;
}
