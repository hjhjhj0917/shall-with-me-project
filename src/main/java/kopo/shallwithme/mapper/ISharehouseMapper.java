package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.UserTagDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface ISharehouseMapper {

    List<SharehouseCardDTO> listCards(Map<String, Object> params);

    SharehouseCardDTO getCardById(Long houseId);

    Map<String, Object> getDetail(Long houseId);

    // ★ 추가: 이미지 목록 조회 ★
    List<Map<String, Object>> selectSharehouseImages(Long houseId);

    List<UserTagDTO> selectSharehouseTags(Long houseId);

    int insertSharehouse(SharehouseCardDTO dto);

    // ★★★ 추가: 이미지 배치 저장 ★★★
    int insertSharehouseImages(List<Map<String, Object>> images);
}