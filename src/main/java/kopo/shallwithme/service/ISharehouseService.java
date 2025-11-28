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

    Long registerHouseWithImages(String ownerId, String title, String subText,
                                 String addr1, String addr2, List<String> imageUrls, String floorNumber);

    SharehouseCardDTO getCardById(Long houseId);

    Map<String, Object> getDetail(Long houseId);

    List<UserTagDTO> selectSharehouseTags(Long houseId);

    List<Map<String, Object>> selectSharehouseImages(Long houseId);

    List<TagDTO> getAllTags();

    int saveSharehouseTags(Long houseId, List<Integer> tagList);

    List<SharehouseCardDTO> getSharehouseByUserId(String userId);

    boolean deleteSharehouse(Long houseId);
}