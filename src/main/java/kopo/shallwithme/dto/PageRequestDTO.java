package kopo.shallwithme.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PageRequestDTO {
    private int page = 1;   // 기본 1페이지
    private int size = 8;   // 기본 8개

    public int getOffset() {
        return (page - 1) * size;
    }
}
