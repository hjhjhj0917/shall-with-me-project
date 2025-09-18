package kopo.shallwithme.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.shallwithme.dto.YouthPolicyDTO;
import kopo.shallwithme.service.IYouthPolicyService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
public class YouthPolicyService implements IYouthPolicyService {

    @Value("${secure.api.url}")
    private String apiUrl;

    @Value("${secure.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    public List<YouthPolicyDTO> getPolicies(int page, int size) throws Exception {
        String url = UriComponentsBuilder.fromHttpUrl(apiUrl)
                .queryParam("apiKeyNm", apiKey)
                .queryParam("pageNum", page)
                .queryParam("pageSize", size)
                .queryParam("rtnType", "json")
                .build()
                .toUriString();

        log.info("API 호출 URL: {}", url);

        String response = restTemplate.getForObject(url, String.class);

        log.info("API 응답 JSON: {}", response);

        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(response).path("result").path("youthPolicyList");

        List<YouthPolicyDTO> policies = new ArrayList<>();
        if (root.isArray()) {
            for (JsonNode node : root) {
                YouthPolicyDTO p = mapper.treeToValue(node, YouthPolicyDTO.class);
                policies.add(p);
            }
        }

        log.info("정책 수: {}", policies.size());
        return policies;
    }

    @Override
    public int getTotalPolicyCount() throws Exception {
        String url = UriComponentsBuilder.fromHttpUrl(apiUrl)
                .queryParam("apiKeyNm", apiKey)
                .queryParam("pageNum", 1)
                .queryParam("pageSize", 1)
                .queryParam("rtnType", "json")
                .build()
                .toUriString();

        log.info("TotalCount API 호출 URL: {}", url);

        String response = restTemplate.getForObject(url, String.class);
        log.info("TotalCount 응답 JSON: {}", response);

        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(response).path("result").path("pagging");

        int totalCount = root.path("totCount").asInt(0);
        log.info("총 정책 수: {}", totalCount);

        return totalCount;
    }
}
