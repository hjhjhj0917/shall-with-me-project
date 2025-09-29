package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.SharehouseCardDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ISharehouseMapper {

    // 카드 목록 (무한스크롤용)
    List<SharehouseCardDTO> listCards(
            @Param("offset") int offset,
            @Param("limit") int limit,
            @Param("city") String city,
            @Param("minRent") Integer minRent,
            @Param("maxRent") Integer maxRent
    );

    // ⬇ 아래 메서드들은 다음 단계에서 추가 예정
    // List<String> listAmenitiesForCard(@Param("houseId") Long houseId);
    // SharehouseDetailDTO getDetail(@Param("houseId") Long houseId);
    // List<String> listPhotos(@Param("houseId") Long houseId);
    // List<String> listAmenities(@Param("houseId") Long houseId);
}
