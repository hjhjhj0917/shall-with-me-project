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

    private final PolicyEmbeddingService policyEmbeddingService;

    @Value("${secure.api.url}")
    private String apiUrl;

    @Value("${secure.api.key}")
    private String apiKey;

    @Override
    public List<YouthPolicyDTO> getPolicies(int page, int size) throws Exception {
        log.info(this.getClass().getName() + ".getPolicies (paginated) from DB Start!");
        int offset = (page - 1) * size;
        return youthPolicyMapper.getPolicyListPaginated(offset, size);
    }

    @Override
    public int getTotalPolicyCount() throws Exception {
        log.info(this.getClass().getName() + ".getTotalPolicyCount from DB Start!");
        return youthPolicyMapper.getTotalPolicyCount();
    }

    @Override
    public List<YouthPolicyDTO> getPolicies() throws Exception {
        log.info(this.getClass().getName() + ".getPolicies (all) from DB Start!");
        return youthPolicyMapper.getPolicyList();
    }

    @Override
    @Transactional
    public void fetchAndSavePolicies() throws Exception {
        log.info("fetchAndSavePolicies (Incremental Update) Start!");

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

        List<YouthPolicyDTO> newPoliciesToEmbed = new ArrayList<>();
        int newPolicyCount = 0;

        for (YouthPolicyDTO apiDto : allPoliciesFromApi) {
            YouthPolicyDTO existingPolicy = youthPolicyMapper.getPolicyById(apiDto.getPlcyNo());

            if (existingPolicy == null) {
                try {
                    youthPolicyMapper.insertPolicy(apiDto);
                    newPoliciesToEmbed.add(apiDto);
                    newPolicyCount++;
                } catch (Exception e) {
                    log.error("새 정책 삽입 실패: {}, 이유: {}", apiDto.getPlcyNo(), e.getMessage());
                }
            }
        }

        log.info("DB 저장 완료. 신규 정책 {}건 추가됨.", newPolicyCount);

        policyEmbeddingService.embedNewPolicies(newPoliciesToEmbed);

        log.info("fetchAndSavePolicies (Incremental Update) End!");
    }
}
