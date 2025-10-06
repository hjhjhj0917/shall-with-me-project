package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.UserTagDTO; // 없다면 주석 처리해도 됨
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface ISharehouseMapper {

    // 목록: XML이 parameterType="map" 이므로 Map으로 받는다.
    List<SharehouseCardDTO> listCards(Map<String, Object> params);

    // 단건 카드: XML에서 #{value} 로 바인딩 (단일 파라미터)
    SharehouseCardDTO getCardById(Long houseId);

    // 상세: XML에서 #{value} 로 바인딩 (단일 파라미터)
    Map<String, Object> getDetail(Long houseId);

    // 태그: XML에서 #{value} 로 바인딩 (단일 파라미터)
    List<UserTagDTO> selectSharehouseTags(Long houseId);

    // insert: PK 자동반환 (XML: useGeneratedKeys="true" keyProperty="houseId")
    int insertSharehouse(SharehouseCardDTO dto);
}
