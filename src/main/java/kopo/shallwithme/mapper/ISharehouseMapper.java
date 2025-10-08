package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserTagDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface ISharehouseMapper {

    // 목록 조회
    List<SharehouseCardDTO> listCards(Map<String, Object> params);

    // 단건 조회
    SharehouseCardDTO getCardById(Long houseId);

    // 상세 조회
    Map<String, Object> getDetail(Long houseId);

    // 쉐어하우스 등록
    int insertSharehouse(SharehouseCardDTO dto);

    // 이미지 조회
    List<Map<String, Object>> selectSharehouseImages(Long houseId);

    // ✅ 태그 조회 (최대 3개)
    List<UserTagDTO> selectSharehouseTags(Long houseId);

    // ✅ 전체 태그 목록 조회 (룸메이트와 동일)
    List<TagDTO> getAllTags();

    // ✅ 태그 저장
    int insertSharehouseTags(Map<String, Object> params);

    // ✅ 태그 삭제 (수정 시 사용)
    int deleteSharehouseTags(Long houseId);
}