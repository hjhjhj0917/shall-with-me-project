package kopo.shallwithme.service;

import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.UserTagDTO;
import java.util.List;
import java.util.Map;

public interface ISharehouseService {

    List<SharehouseCardDTO> listCards(
            int offset,
            int limit,
            String city,
            Integer minRent,
            Integer maxRent
    );

    void registerHouse(String ownerId, String title, String subText, Integer price, String coverUrl);

    // ★★★ 추가: 이미지 포함 등록 ★★★
    Long registerHouseWithImages(String ownerId, String title, String subText,
                                 String address, List<String> imageUrls);

    SharehouseCardDTO getCardById(Long houseId);

    Map<String, Object> getDetail(Long houseId);

    // ✅ 추가!
    List<UserTagDTO> selectSharehouseTags(Long houseId);

    // ✅ 이미지 조회도 추가 (일관성을 위해)
    List<Map<String, Object>> selectSharehouseImages(Long houseId);
}