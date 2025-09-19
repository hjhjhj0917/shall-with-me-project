package kopo.shallwithme.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.shallwithme.dto.YouthPolicyDTO;
import kopo.shallwithme.mapper.IYouthPolicyMapper; // 새로 만든 매퍼 주입
import lombok.RequiredArgsConstructor; // RequiredArgsConstructor로 변경
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor // 생성자 주입을 위해 변경
public class YouthPolicyService {

    private final IYouthPolicyMapper youthPolicyMapper; // DB와 통신할 매퍼
    private final RestTemplate restTemplate;

    @Value("${secure.api.url}")
    private String apiUrl;

    @Value("${secure.api.key}")
    private String apiKey;

    /**
     * [수정] 이제 이 메소드는 외부 API가 아닌, 우리 DB에서 정책 목록을 조회합니다.
     */
    public List<YouthPolicyDTO> getPolicies() throws Exception {
        log.info(this.getClass().getName() + ".getPolicies from DB Start!");
        return youthPolicyMapper.getPolicyList();
    }

    /**
     * [추가] 스케줄러가 호출할 메소드.
     * 외부 API에서 데이터를 가져와 DB에 저장(갱신)합니다.
     */
    @Transactional
    public void fetchAndSavePolicies() throws Exception {
        log.info("fetchAndSavePolicies Start!");

        // 1. API 호출 URL 구성 및 데이터 받아오기
        String url = UriComponentsBuilder.fromHttpUrl(apiUrl)
                .queryParam("apiKeyNm", apiKey)
                .queryParam("pageNum", 1)
                .queryParam("pageSize", 100) // 100개씩 한번에 가져오기 (페이지네이션 처리 필요)
                .queryParam("rtnType", "json")
                .build().toUriString();

        // 전체 정책을 담을 리스트
        List<YouthPolicyDTO> allPolicies = new ArrayList<>();

        ObjectMapper mapper = new ObjectMapper();

        // 총 데이터 건수, 페이지 처리용 변수
        int totalCount = 0;
        int pageNum = 1;
        int pageSize = 100;
        int totalPages;

        do {
            // API 호출할 때 페이지 번호 바꿔가며 요청
            String pagedUrl = UriComponentsBuilder.fromHttpUrl(apiUrl)
                    .queryParam("apiKeyNm", apiKey)
                    .queryParam("pageNum", pageNum)
                    .queryParam("pageSize", pageSize)
                    .queryParam("rtnType", "json")
                    .build().toUriString();

            String response = restTemplate.getForObject(pagedUrl, String.class);
            log.info("API response page {}: {}", pageNum, response);

            JsonNode rootNode = mapper.readTree(response);
            JsonNode resultNode = rootNode.path("result");
            JsonNode paggingNode = resultNode.path("pagging");
            JsonNode itemsNode = resultNode.path("youthPolicyList");

            // 총 데이터 건수 구하기 (첫 호출 때만 세팅)
            if (totalCount == 0) {
                totalCount = paggingNode.path("totCount").asInt();
                totalPages = (totalCount + pageSize - 1) / pageSize;
                log.info("Total policy count: {}, total pages: {}", totalCount, totalPages);
            }

            if (itemsNode.isArray()) {
                for (JsonNode item : itemsNode) {
                    YouthPolicyDTO dto = mapper.treeToValue(item, YouthPolicyDTO.class);
                    allPolicies.add(dto);
                }
            }

            pageNum++;

        } while (pageNum <= (totalCount + pageSize - 1) / pageSize);

        // DB 저장
        log.info("DB 저장 전 기존 정책 모두 삭제");
        youthPolicyMapper.deleteAllPolicies();

        log.info("DB 저장 시작, 총 {}건 저장", allPolicies.size());

        int batchSize = 100;
        for (int i = 0; i < allPolicies.size(); i += batchSize) {
            int end = Math.min(i + batchSize, allPolicies.size());
            List<YouthPolicyDTO> batchList = allPolicies.subList(i, end);

            insertBatch(batchList);
        }

        log.info("fetchAndSavePolicies End!");
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void insertBatch(List<YouthPolicyDTO> batchList) {
        for (YouthPolicyDTO dto : batchList) {
            try {
                youthPolicyMapper.insertPolicy(dto);
            } catch (Exception e) {
                log.error("정책 삽입 실패: {}, 이유: {}", dto.getPlcyNo(), e.getMessage());
            }
        }
    }

}
