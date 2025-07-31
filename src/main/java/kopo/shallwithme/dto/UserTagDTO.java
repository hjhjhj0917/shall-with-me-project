package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class UserTagDTO {
    private String userId;
    private String tagType;
    private List<Integer> tagList;
}
