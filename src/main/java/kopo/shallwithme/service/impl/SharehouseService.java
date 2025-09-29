package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.service.ISharehouseService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Service
public class SharehouseService implements ISharehouseService {

    // ===== 현재는 FAKE 모드만 사용 (DB/API 미정) =====
    private static final List<SharehouseCardDTO> FAKE_LIST = new ArrayList<>();
    static {
        FAKE_LIST.add(build(101L, "동래구의 아파트", "조용한 주거지역, 2호선 도보 5분", 5_000_000, null, List.of("지하철가까움", "풀옵션")));
        FAKE_LIST.add(build(102L, "송파구 원룸", "석촌호수 근처, 풀옵션", 7_000_000, null, List.of("한적한동네", "반려동물가능")));
        FAKE_LIST.add(build(103L, "해운대 오션뷰", "바다 보이는 방, 주차 가능", 9_000_000, null, List.of("오션뷰", "주차가능")));
        FAKE_LIST.add(build(104L, "수원 영통 빌라", "초등학교 인접, 신혼부부 추천", 6_000_000, null, List.of("학교가까움", "저층")));
        FAKE_LIST.add(build(105L, "강남 오피스텔", "테헤란로 도보, 보안우수", 12_000_000, null, List.of("역세권", "보안우수")));
        FAKE_LIST.add(build(106L, "광안리 근처 투룸", "카페거리 도보 3분", 8_000_000, null, List.of("카페거리", "반려동물가능")));
        FAKE_LIST.add(build(107L, "대구 수성구 원룸", "학군/치안 양호", 5_000_000, null, List.of("학군우수", "조용한동네")));
        FAKE_LIST.add(build(108L, "전남 여수 단독주택", "마당 넓고 햇살좋음", 4_000_000, null, List.of("마당있음", "채광좋음")));
    }

    private static SharehouseCardDTO build(Long id, String title, String subText, Integer price, String cover, List<String> tags) {
        SharehouseCardDTO dto = new SharehouseCardDTO();
        dto.setHouseId(id);
        dto.setTitle(title);
        dto.setSubText(subText);
        dto.setPrice(price);
        dto.setCoverUrl(cover); // null이면 프론트 기본이미지 사용
        dto.setTags(tags != null ? tags : Collections.emptyList());
        return dto;
    }

    // 목록
    @Override
    public List<SharehouseCardDTO> listCards(int offset, int limit, String city, Integer minRent, Integer maxRent) {
        // 간단 필터(도시/임대료 조건이 있으면 적용)
        List<SharehouseCardDTO> filtered = new ArrayList<>(FAKE_LIST);
        if (city != null && !city.isBlank()) {
            filtered.removeIf(c -> c.getTitle() == null || !c.getTitle().contains(city));
        }
        if (minRent != null) filtered.removeIf(c -> c.getPrice() == null || c.getPrice() < minRent);
        if (maxRent != null) filtered.removeIf(c -> c.getPrice() == null || c.getPrice() > maxRent);

        // 페이징
        int start = Math.max(0, offset);
        int end = Math.min(filtered.size(), start + Math.max(1, limit));
        if (start >= end) return Collections.emptyList();

        List<SharehouseCardDTO> page = new ArrayList<>(filtered.subList(start, end));

        // 태그는 최대 2개만 노출(룸메이트 UX와 동일)
        page.forEach(c -> {
            List<String> t = c.getTags();
            if (t != null && t.size() > 2) c.setTags(t.subList(0, 2));
        });
        return page;
    }

    // 등록(임시로 FAKE 리스트에 추가)
    @Override
    public void registerHouse(String ownerId, String title, String subText, Integer price, String coverUrl) {
        long nextId = FAKE_LIST.stream().mapToLong(SharehouseCardDTO::getHouseId).max().orElse(200) + 1;
        FAKE_LIST.add(build(nextId, title != null ? title : "새 매물", subText, price, coverUrl, List.of("신규")));
        log.info("FAKE 등록 완료. houseId={}", nextId);

        // ※ DB 붙일 때:
        // ISharehouseMapper에 insert 메서드 시그니처를 만들고 여기서 호출해주면 됨.
    }

    // 카드 1건
    @Override
    public SharehouseCardDTO getCardById(Long houseId) {
        return FAKE_LIST.stream()
                .filter(c -> Objects.equals(c.getHouseId(), houseId))
                .findFirst()
                .orElse(null);

        // ※ DB 붙일 때: mapper.getCardById(houseId) 추가
    }

    // 상세
    @Override
    public Map<String, Object> getDetail(Long houseId) {
        SharehouseCardDTO c = getCardById(houseId);
        if (c == null) return Map.of();

        Map<String, Object> d = new LinkedHashMap<>();
        // 프론트가 룸메이트 키를 재사용하므로 키 이름을 맞춰줌
        d.put("userId", String.valueOf(c.getHouseId()));
        d.put("profileImgUrl", c.getCoverUrl());
        d.put("name", c.getTitle());
        d.put("age", null);
        d.put("tag1", c.getTags() != null && !c.getTags().isEmpty() ? c.getTags().get(0) : null);
        d.put("tag2", c.getTags() != null && c.getTags().size() > 1 ? c.getTags().get(1) : null);
        d.put("gender", null);
        d.put("intro", Optional.ofNullable(c.getSubText()).orElse("FAKE 상세 설명입니다."));
        d.put("location", "임시 위치");
        d.put("availableDt", LocalDateTime.now().plusDays(3));
        d.put("price", c.getPrice());
        return d;

        // ※ DB 붙일 때: mapper.getDetail(houseId) 추가
    }
}
