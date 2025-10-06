package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.SharehouseImageDTO;
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
    private final ISharehouseImageMapper imageMapper; // 이미지 URL → DB 매핑

    /** 목록 (무한스크롤) */
    @Override
    public List<SharehouseCardDTO> listCards(int offset, int limit, String city, Integer minRent, Integer maxRent) {
        // DB 스키마에 city/rent 컬럼이 없으므로 offset/limit만 전달
        Map<String, Object> p = new HashMap<>();
        p.put("offset", Math.max(0, offset));
        p.put("limit", Math.max(1, limit));
        // city/minRent/maxRent는 현재 테이블에 컬럼이 없어 사용 안 함
        return sharehouseMapper.listCards(p);
    }

    /**
     * 등록
     * - 하우스 레코드 insert (PK 자동반환)
     * - (선택) 이미지 URL 리스트를 받으면 대표/정렬 순서로 이미지 테이블에 일괄 저장
     *
     * 기존 ISharehouseService 시그니처를 유지하기 위해 coverUrl만 받도록 두되,
     * 실제 이미지 배치 저장은 아래 attachImages(...)를 컨트롤러에서 이어서 호출하는 패턴 권장.
     */
    @Override
    @Transactional
    public void registerHouse(String ownerId, String title, String subText, Integer price, String coverUrl) {
        SharehouseCardDTO dto = new SharehouseCardDTO();
        dto.setTitle(title);
        dto.setSubText(subText);
        dto.setCoverUrl(coverUrl);
        dto.setRegId(ownerId);

        // 1) 하우스 insert → PK 자동반환 (mapper XML: useGeneratedKeys="true" keyProperty="houseId")
        int n = sharehouseMapper.insertSharehouse(dto);
        if (n != 1 || dto.getHouseId() == null) {
            throw new IllegalStateException("쉐어하우스 저장 실패 (PK 반환 없음)");
        }
        log.info("sharehouse inserted. houseId={}", dto.getHouseId());

        // 2) 이미지 저장은 컨트롤러에서 선업로드 URL 배열을 들고 있다가
        //    registerHouse 이후 houseId를 받아 attachImages(...)로 호출하는 흐름 권장
        //    (여기서는 아무 것도 하지 않음)
    }

    /** 카드 한 건 */
    @Override
    public SharehouseCardDTO getCardById(Long houseId) {
        if (houseId == null) return null;
        return sharehouseMapper.getCardById(houseId);
    }

    /** 상세(맵 구조) */
    @Override
    public Map<String, Object> getDetail(Long houseId) {
        if (houseId == null) return Collections.emptyMap();
        Map<String, Object> d = sharehouseMapper.getDetail(houseId);
        return (d != null) ? d : Collections.emptyMap();
    }

    // ====== 추가 유틸 (컨트롤러에서 호출) ======

    /**
     * 선업로드된 이미지 URL 목록을 houseId에 매핑 저장
     * - index 0: 대표(isMain=1, sortOrder=0)
     * - 나머지: isMain=0, sortOrder=index
     */
    @Transactional
    public int attachImages(Long houseId, List<String> urls) {
        if (houseId == null || urls == null || urls.isEmpty()) return 0;

        List<SharehouseImageDTO> list = new ArrayList<>();
        for (int i = 0; i < urls.size(); i++) {
            String url = urls.get(i);
            if (url == null || url.isBlank()) continue;

            SharehouseImageDTO img = new SharehouseImageDTO();
            img.setHouseId(houseId.intValue());   // DTO가 Integer이므로 캐스팅
            img.setUrl(url);
            img.setIsMain(i == 0 ? 1 : 0);
            img.setSortOrder(i);
            list.add(img);
        }
        if (list.isEmpty()) return 0;
        return imageMapper.insertImages(list);
    }
}
