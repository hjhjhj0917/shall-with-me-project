package kopo.shallwithme.service;

import kopo.shallwithme.dto.SharehouseCardDTO;
import java.util.List;
import java.util.Map;

public interface ISharehouseService {

    // 구현체(SharehouseService)와 대소문자·파라미터까지 완전 동일하게
    List<SharehouseCardDTO> listCards(
            int offset,
            int limit,
            String city,
            Integer minRent,
            Integer maxRent
    );

    void registerHouse(String ownerId, String title, String subText, Integer price, String coverUrl);

    SharehouseCardDTO getCardById(Long houseId);

    Map<String, Object> getDetail(Long houseId);
}
