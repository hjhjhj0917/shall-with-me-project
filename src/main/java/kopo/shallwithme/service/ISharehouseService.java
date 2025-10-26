package kopo.shallwithme.service;

import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserTagDTO;
import java.util.List;
import java.util.Map;

public interface ISharehouseService {

    List<SharehouseCardDTO> listCards(
            int offset,
            int limit,
            String location,
            List<Integer> tagIds,
            Integer maxRent
    );

    void registerHouse(String ownerId, String title, String subText, Integer price, String coverUrl);

    // ✅ 수정: address 1개 → addr1, addr2 2개로 변경
    Long registerHouseWithImages(String ownerId, String title, String subText,
                                 String addr1, String addr2, List<String> imageUrls, String floorNumber);

    SharehouseCardDTO getCardById(Long houseId);

    Map<String, Object> getDetail(Long houseId);

    // ✅ 태그 조회
    List<UserTagDTO> selectSharehouseTags(Long houseId);

    // ✅ 이미지 조회
    List<Map<String, Object>> selectSharehouseImages(Long houseId);

    // ✅ 전체 태그 목록 조회 (룸메이트와 동일)
    List<TagDTO> getAllTags();

    // ✅ 태그 저장 (룸메이트와 동일한 방식)
    int saveSharehouseTags(Long houseId, List<Integer> tagList);

    // ✅ 본인의 쉐어하우스 조회 (userId 기준)
    SharehouseCardDTO getSharehouseByUserId(String userId);

    // ✅ 쉐어하우스 삭제 (태그, 이미지 포함)
    boolean deleteSharehouse(Long houseId);
}