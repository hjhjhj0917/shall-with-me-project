package kopo.shallwithme.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.shallwithme.dto.YouthPolicyDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChatbotService {

    private final YouthPolicyService youthPolicyService;
    private final RestTemplate restTemplate;

    @Value("${secure.openai.api.key}")
    private String openAiApiKey;

    private static final int MAX_POLICY_COUNT = 15;
    private static final int MAX_DESCRIPTION_LENGTH = 120;
    private static final int MAX_PROMPT_LENGTH = 3500;

    public String getAnswer(String userQuestion) throws Exception {

        // 1. 사용자의 질문에서 키워드 추출 (여기서는 띄어쓰기 단순 분리)
        String[] keywords = userQuestion.toLowerCase().split("\\s+");

        // 2. DB에서 모든 정책 불러오기
        List<YouthPolicyDTO> allPolicies = youthPolicyService.getPolicies();

        // 3. 키워드 포함 여부 뿐 아니라 정책명과 설명에서 키워드 빈도수 기반으로 점수 매기기
        List<YouthPolicyDTO> scoredPolicies = allPolicies.stream()
                .map(p -> {
                    String name = p.getPlcyNm() != null ? p.getPlcyNm().toLowerCase() : "";
                    String desc = p.getPlcyExplnCn() != null ? p.getPlcyExplnCn().toLowerCase() : "";
                    int score = 0;
                    for (String kw : keywords) {
                        if (!kw.isBlank()) {
                            score += countOccurrences(name, kw) * 2;  // 정책명 키워드 가중치 높게
                            score += countOccurrences(desc, kw);
                        }
                    }
                    return new PolicyScore(p, score);
                })
                .filter(ps -> ps.score > 0) // 키워드가 하나도 포함 안된 건 제외
                .sorted((a, b) -> Integer.compare(b.score, a.score)) // 점수 내림차순 정렬
                .limit(MAX_POLICY_COUNT)
                .map(ps -> ps.policy)
                .collect(Collectors.toList());

        // 4. 설명을 자연스레 자르고 요약 (간단하게 자르기 + ...표시)
        List<String> policyDescriptions = scoredPolicies.stream()
                .map(p -> {
                    String desc = p.getPlcyExplnCn() != null ? p.getPlcyExplnCn() : "";
                    if (desc.length() > MAX_DESCRIPTION_LENGTH) {
                        desc = desc.substring(0, MAX_DESCRIPTION_LENGTH);
                        // 문장 중간 자름 방지: 마지막 마침표, 쉼표 위치 찾기
                        int lastPeriod = desc.lastIndexOf('.');
                        int lastComma = desc.lastIndexOf(',');
                        int cutPos = Math.max(lastPeriod, lastComma);
                        if (cutPos > 0) {
                            desc = desc.substring(0, cutPos + 1);
                        }
                        desc += "...";
                    }
                    return String.format("- 정책명: %s\n  설명: %s\n  신청 주소: %s",
                            p.getPlcyNm(), desc, p.getAplyUrlAddr());
                })
                .collect(Collectors.toList());

        // 5. 프롬프트 길이 제한
        StringBuilder sb = new StringBuilder();
        for (String line : policyDescriptions) {
            if (sb.length() + line.length() + 1 > MAX_PROMPT_LENGTH) break;
            sb.append(line).append("\n");
        }
        String policyDataForPrompt = sb.length() > 0 ? sb.toString() : "현재 질문에 맞는 정책 데이터가 없습니다.";

        // 6. 시스템 프롬프트 구성 (더 명확하고 친절한 톤)
        String systemPrompt = "너는 대한민국 청년 정책 전문 챗봇 '살며시'야. " +
                "사용자가 궁금한 점에 대해 가장 관련 깊은 청년 정책 정보를 친절하고 알기 쉽게 알려줘. " +
                "아래 정책 목록을 참고해 답변하되, 각 정책은 번호와 함께 정책명, 설명, 신청 주소를 포함해서 줄바꿈과 들여쓰기를 사용해 가독성 있게 정리해줘.\n\n" +
                "[정책 목록]\n" + policyDataForPrompt + "\n\n" +
                "답변은 평이한 문장으로 작성하고, 필요하면 추가 설명도 포함해줘.";

        Map<String, String> systemMessage = Map.of(
                "role", "system",
                "content", systemPrompt);

        Map<String, String> userMessage = Map.of(
                "role", "user",
                "content", userQuestion);

        // 7. OpenAI 호출 세팅
        String openAiApiUrl = "https://api.openai.com/v1/chat/completions";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(openAiApiKey);

        Map<String, Object> requestBody = Map.of(
                "model", "gpt-4o-mini",
                "messages", List.of(systemMessage, userMessage),
                "temperature", 0.7,       // 좀 더 다양하고 자연스러운 답변을 위해 약간 조정
                "max_tokens", 800         // 답변 최대 토큰 수 제한
        );

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        // 8. API 호출 및 응답 처리
        String response = restTemplate.postForObject(openAiApiUrl, entity, String.class);

        ObjectMapper mapper = new ObjectMapper();
        try {
            return mapper.readTree(response)
                    .path("choices").get(0)
                    .path("message")
                    .path("content").asText("죄송합니다. 답변을 생성하는 데 문제가 발생했습니다.");
        } catch (Exception e) {
            log.error("OpenAI 응답 파싱 실패", e);
            return "죄송합니다. 답변을 생성하는 데 문제가 발생했습니다.";
        }
    }

    // 키워드가 텍스트에 몇 번 등장하는지 세기 (단순 포함 횟수)
    private int countOccurrences(String text, String keyword) {
        int count = 0;
        int idx = 0;
        while ((idx = text.indexOf(keyword, idx)) != -1) {
            count++;
            idx += keyword.length();
        }
        return count;
    }

    // 정책과 점수를 묶는 내부 클래스
    private static class PolicyScore {
        YouthPolicyDTO policy;
        int score;

        PolicyScore(YouthPolicyDTO policy, int score) {
            this.policy = policy;
            this.score = score;
        }
    }
}


