package kopo.shallwithme.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.shallwithme.dto.YouthPolicyDTO;
import kopo.shallwithme.mapper.IYouthPolicyMapper;
import kopo.shallwithme.service.IYouthPolicyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class YouthPolicyService implements IYouthPolicyService {

    private final IYouthPolicyMapper youthPolicyMapper;
    private final RestTemplate restTemplate;

    // ✅ [추가] 새로 추가된 정책을 임베딩하기 위해 주입
    private final PolicyEmbeddingService policyEmbeddingService;

    @Value("${secure.api.url}")
    private String apiUrl;

    @Value("${secure.api.key}")
    private String apiKey;

    /**
     * (인터페이스 구현)
     * 페이징 처리를 위한 정책 목록 조회
     */
    @Override
    public List<YouthPolicyDTO> getPolicies(int page, int size) throws Exception {
        log.info(this.getClass().getName() + ".getPolicies (paginated) from DB Start!");
        int offset = (page - 1) * size;
        return youthPolicyMapper.getPolicyListPaginated(offset, size);
    }

    /**
     * (인터페이스 구현)
     * 전체 정책 개수 조회
     */
    @Override
    public int getTotalPolicyCount() throws Exception {
        log.info(this.getClass().getName() + ".getTotalPolicyCount from DB Start!");
        return youthPolicyMapper.getTotalPolicyCount();
    }

    /**
     * (인터페이스 구현)
     * 모든 정책 목록 조회 (PolicyEmbeddingService용)
     */
    @Override
    public List<YouthPolicyDTO> getPolicies() throws Exception {
        log.info(this.getClass().getName() + ".getPolicies (all) from DB Start!");
        return youthPolicyMapper.getPolicyList();
    }

    /**
     * (인터페이스 구현)
     * 스케줄러가 호출할 증분 업데이트 메서드
     */
    @Override
    @Transactional
    public void fetchAndSavePolicies() throws Exception {
        log.info("fetchAndSavePolicies (Incremental Update) Start!");

        // 1. API에서 모든 정책을 조회 (페이지네이션 처리)
        List<YouthPolicyDTO> allPoliciesFromApi = new ArrayList<>();
        ObjectMapper mapper = new ObjectMapper();

        int totalCount = 0;
        int pageNum = 1;
        int pageSize = 100;

        do {
            String pagedUrl = UriComponentsBuilder.fromHttpUrl(apiUrl)
                    .queryParam("apiKeyNm", apiKey).queryParam("pageNum", pageNum)
                    .queryParam("pageSize", pageSize).queryParam("rtnType", "json")
                    .build().toUriString();

            String response = restTemplate.getForObject(pagedUrl, String.class);
            JsonNode rootNode = mapper.readTree(response);
            JsonNode resultNode = rootNode.path("result");
            JsonNode paggingNode = resultNode.path("pagging");
            JsonNode itemsNode = resultNode.path("youthPolicyList");

            if (totalCount == 0) {
                totalCount = paggingNode.path("totCount").asInt();
                log.info("Total policy count from API: {}", totalCount);
            }

            if (itemsNode.isArray()) {
                for (JsonNode item : itemsNode) {
                    allPoliciesFromApi.add(mapper.treeToValue(item, YouthPolicyDTO.class));
                }
            }
            pageNum++;
        } while (pageNum <= (totalCount + pageSize - 1) / pageSize); // 페이지네이션 끝까지

        log.info("API에서 총 {}건의 정책 조회 완료. DB와 비교 시작...", allPoliciesFromApi.size());

        // 2. DB와 비교하여 *새로운 정책*만 저장
        List<YouthPolicyDTO> newPoliciesToEmbed = new ArrayList<>();
        int newPolicyCount = 0;

        for (YouthPolicyDTO apiDto : allPoliciesFromApi) {
            // API에서 가져온 정책의 ID(plcyNo)로 DB 조회
            YouthPolicyDTO existingPolicy = youthPolicyMapper.getPolicyById(apiDto.getPlcyNo());

            // DB에 해당 정책이 없으면 (새로운 정책이면)
            if (existingPolicy == null) {
                try {
                    // DB에 삽입
                    youthPolicyMapper.insertPolicy(apiDto);
                    // 임베딩 목록에 추가
                    newPoliciesToEmbed.add(apiDto);
                    newPolicyCount++;
                } catch (Exception e) {
                    log.error("새 정책 삽입 실패: {}, 이유: {}", apiDto.getPlcyNo(), e.getMessage());
                }
            }
        }

        log.info("DB 저장 완료. 신규 정책 {}건 추가됨.", newPolicyCount);

        // 3. 새로 추가된 정책들만 임베딩 서비스로 전달
        policyEmbeddingService.embedNewPolicies(newPoliciesToEmbed);

        log.info("fetchAndSavePolicies (Incremental Update) End!");
    }
}
