package kopo.shallwithme.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@JsonInclude(JsonInclude.Include.NON_DEFAULT)
public class SpamDTO {

    private String text;
    private String label;
    private Double score;
    private String score_str;

}
