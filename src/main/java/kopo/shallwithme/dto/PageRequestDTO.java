package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PageRequestDTO {
    private int page = 1;
    private int size = 8;

    public int getOffset() {
        return (page - 1) * size;
    }
}
