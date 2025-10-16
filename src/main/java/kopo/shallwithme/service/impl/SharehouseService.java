package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.SharehouseImageDTO;
import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.mapper.ISharehouseMapper;
import kopo.shallwithme.mapper.ISharehouseImageMapper;
import kopo.shallwithme.service.ISharehouseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class SharehouseService implements ISharehouseService {

    private final ISharehouseMapper sharehouseMapper;
    private final ISharehouseImageMapper imageMapper;

    @Override
    public List<SharehouseCardDTO> listCards(int offset, int limit, String city, Integer minRent, Integer maxRent) {
        Map<String, Object> p = new HashMap<>();
        p.put("offset", Math.max(0, offset));
        p.put("limit", Math.max(1, limit));
        List<SharehouseCardDTO> cards = sharehouseMapper.listCards(p);
        for (SharehouseCardDTO c : cards) {
            List<UserTagDTO> tags = sharehouseMapper.selectSharehouseTags(c.getHouseId());
            c.setTags(tags == null ? Collections.emptyList() : tags);
        }
        return cards;
    }

    @Override
    @Transactional
    public void registerHouse(String ownerId, String title, String subText, Integer price, String coverUrl) {
        SharehouseCardDTO dto = new SharehouseCardDTO();
        dto.setTitle(title);
        dto.setSubText(subText);
        dto.setCoverUrl(coverUrl);
        dto.setRegId(ownerId);

        int n = sharehouseMapper.insertSharehouse(dto);
        if (n != 1 || dto.getHouseId() == null) {
            throw new IllegalStateException("쉐어하우스 저장 실패 (PK 반환 없음)");
        }
        log.info("sharehouse inserted. houseId={}", dto.getHouseId());
    }

    /**
     * ★★★ 새로운 메서드: 이미지 + 층수 포함 등록 ★★★
     */
    /**
     * ✅ 수정: address 1개 → addr1, addr2 2개로 변경
     */
    @Override
    @Transactional
    public Long registerHouseWithImages(String ownerId, String title, String subText,
                                        String addr1, String addr2, List<String> imageUrls, String floorNumber) {

        log.info("=== 쉐어하우스 등록 시작 ===");
        log.info("ownerId: {}", ownerId);
        log.info("title: {}", title);
        log.info("addr1 (기본주소): {}", addr1);     // ✅ 수정
        log.info("addr2 (상세주소): {}", addr2);     // ✅ 추가
        log.info("floorNumber: {}", floorNumber);
        log.info("imageUrls 개수: {}", imageUrls != null ? imageUrls.size() : 0);

        // 1. 기본 정보 저장
        SharehouseCardDTO dto = new SharehouseCardDTO();
        dto.setTitle(title);
        dto.setSubText(subText);
        dto.setAddress(addr1);           // ✅ addr1 설정
        dto.setDetailAddress(addr2);     // ✅ addr2 설정
        dto.setRegId(ownerId);

        // 층수 설정
        if (floorNumber != null && !floorNumber.isBlank()) {
            try {
                dto.setFloorNumber(Integer.parseInt(floorNumber));
                log.info("✅ 층수 설정: {}", floorNumber);
            } catch (NumberFormatException e) {
                log.warn("⚠️ 층수 파싱 실패: {}", floorNumber);
            }
        }

        // 첫 번째 이미지를 coverUrl로 설정
        if (imageUrls != null && !imageUrls.isEmpty()) {
            dto.setCoverUrl(imageUrls.get(0));
            log.info("coverUrl 설정: {}", imageUrls.get(0));
        }

        int n = sharehouseMapper.insertSharehouse(dto);
        if (n != 1 || dto.getHouseId() == null) {
            log.error("쉐어하우스 저장 실패");
            throw new IllegalStateException("쉐어하우스 저장 실패 (PK 반환 없음)");
        }

        Long houseId = dto.getHouseId();
        log.info("✅ 쉐어하우스 저장 완료. houseId={}", houseId);

        // 2. 이미지 저장
        if (imageUrls != null && !imageUrls.isEmpty()) {
            int savedCount = attachImages(houseId, imageUrls);
            log.info("✅ 이미지 {}개 저장 완료", savedCount);
        } else {
            log.warn("⚠️ 저장할 이미지가 없습니다");
        }

        log.info("=== 쉐어하우스 등록 완료 ===");
        return houseId;
    }

    @Override
    public SharehouseCardDTO getCardById(Long houseId) {
        if (houseId == null) return null;
        return sharehouseMapper.getCardById(houseId);
    }

    @Override
    public Map<String, Object> getDetail(Long houseId) {
        if (houseId == null) return Collections.emptyMap();
        Map<String, Object> d = sharehouseMapper.getDetail(houseId);
        return (d != null) ? d : Collections.emptyMap();
    }

    /**
     * 이미지 URL 목록을 SHARE_HOUSE_IMAGE 테이블에 저장
     */
    @Transactional
    public int attachImages(Long houseId, List<String> urls) {
        if (houseId == null || urls == null || urls.isEmpty()) {
            log.warn("attachImages: houseId 또는 urls가 비어있음");
            return 0;
        }

        List<SharehouseImageDTO> list = new ArrayList<>();
        for (int i = 0; i < urls.size(); i++) {
            String url = urls.get(i);
            if (url == null || url.isBlank()) {
                log.warn("이미지 URL이 비어있음 (index: {})", i);
                continue;
            }

            SharehouseImageDTO img = new SharehouseImageDTO();
            img.setHouseId(houseId.intValue());
            img.setUrl(url);
            img.setIsMain(i == 0 ? 1 : 0);  // 첫 번째만 대표 이미지
            img.setSortOrder(i);
            list.add(img);

            log.debug("이미지 추가: url={}, sortOrder={}, isMain={}", url, i, i == 0 ? 1 : 0);
        }

        if (list.isEmpty()) {
            log.warn("저장할 이미지가 없습니다");
            return 0;
        }

        int result = imageMapper.insertImages(list);
        log.info("이미지 {} / {} 개 저장됨", result, list.size());
        return result;
    }

    /**
     * ✅ 쉐어하우스 태그 조회 (룸메이트와 동일)
     */
    @Override
    public List<UserTagDTO> selectSharehouseTags(Long houseId) {
        if (houseId == null) {
            log.warn("houseId가 null입니다");
            return Collections.emptyList();
        }
        return sharehouseMapper.selectSharehouseTags(houseId);
    }

    /**
     * ✅ 쉐어하우스 이미지 목록 조회
     */
    @Override
    public List<Map<String, Object>> selectSharehouseImages(Long houseId) {
        if (houseId == null) {
            log.warn("houseId가 null입니다");
            return Collections.emptyList();
        }
        return sharehouseMapper.selectSharehouseImages(houseId);
    }

    /**
     * ✅ 전체 태그 목록 조회 (룸메이트와 동일)
     */
    @Override
    public List<TagDTO> getAllTags() {
        return sharehouseMapper.getAllTags();
    }

    /**
     * ✅ 태그 저장 (룸메이트와 동일한 방식)
     */
    @Override
    @Transactional
    public int saveSharehouseTags(Long houseId, List<Integer> tagList) {
        if (houseId == null || tagList == null || tagList.isEmpty()) {
            log.warn("houseId 또는 tagList가 비어있음");
            return 0;
        }

        log.info("태그 저장 시작: houseId={}, tagList={}", houseId, tagList);

        // 1. 기존 태그 삭제
        sharehouseMapper.deleteSharehouseTags(houseId);
        log.info("기존 태그 삭제 완료");

        // 2. 새 태그 저장
        Map<String, Object> params = new HashMap<>();
        params.put("houseId", houseId);
        params.put("tagList", tagList);

        int result = sharehouseMapper.insertSharehouseTags(params);
        log.info("태그 {}개 저장 완료", result);

        return result;
    }
}