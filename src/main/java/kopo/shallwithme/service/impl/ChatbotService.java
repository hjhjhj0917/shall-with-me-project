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

    private final YouthPolicyService youthPolicyService; // 기존 정책 서비스 재사용
    private final RestTemplate restTemplate;

    @Value("${secure.openai.api.key}")
    private String openAiApiKey;

    // 최대 정책 개수 제한
    private static final int MAX_POLICY_COUNT = 15;

    // 최대 설명 길이 (글자수)
    private static final int MAX_DESCRIPTION_LENGTH = 120;

    // 최대 프롬프트 정책 데이터 길이(토큰 과다 방지용)
    private static final int MAX_PROMPT_LENGTH = 3500; // 대략 글자 수

    public String getAnswer(String userQuestion) throws Exception {

        // 1. 사용자의 질문에서 주요 키워드를 뽑는 간단 로직 (여기서는 띄어쓰기 기준 단어 추출)
        String[] keywords = userQuestion.toLowerCase().split("\\s+");

        // 2. DB에서 모든 정책 불러오기 (또는 최대 제한 개수)
        List<YouthPolicyDTO> allPolicies = youthPolicyService.getPolicies();

        // 3. 키워드가 포함된 정책만 필터링 (정책명 또는 설명에 키워드 포함 시)
        List<YouthPolicyDTO> filteredPolicies = allPolicies.stream()
                .filter(p -> {
                    String name = p.getPlcyNm() != null ? p.getPlcyNm().toLowerCase() : "";
                    String desc = p.getPlcyExplnCn() != null ? p.getPlcyExplnCn().toLowerCase() : "";
                    // 키워드 중 하나라도 포함하면 true
                    for (String kw : keywords) {
                        if (name.contains(kw) || desc.contains(kw)) {
                            return true;
                        }
                    }
                    return false;
                })
                .limit(MAX_POLICY_COUNT) // 최대 개수 제한
                .collect(Collectors.toList());

        // 4. 설명 텍스트 자르고, 정책 정보 간단 요약 형식 만들기
        List<String> policyDescriptions = filteredPolicies.stream()
                .map(p -> {
                    String desc = p.getPlcyExplnCn() != null ? p.getPlcyExplnCn() : "";
                    if (desc.length() > MAX_DESCRIPTION_LENGTH) {
                        desc = desc.substring(0, MAX_DESCRIPTION_LENGTH) + "...";
                    }
                    return String.format("- 정책명: %s, 설명: %s, 신청주소: %s",
                            p.getPlcyNm(), desc, p.getAplyUrlAddr());
                })
                .collect(Collectors.toList());

        // 5. 너무 길면 일부만 사용 (안전장치)
        String policyDataForPrompt = "";
        StringBuilder sb = new StringBuilder();
        for (String line : policyDescriptions) {
            if (sb.length() + line.length() + 1 > MAX_PROMPT_LENGTH) break;
            sb.append(line).append("\n");
        }
        policyDataForPrompt = sb.toString();

        if (policyDataForPrompt.isEmpty()) {
            policyDataForPrompt = "현재 질문에 맞는 정책 데이터가 없습니다.";
        }

        // 6. GPT에 보낼 시스템 메시지 구성
        String systemPrompt = "너는 대한민국 청년 정책 전문 챗봇 '살며시'야. " +
                "사용자의 질문에 가장 적합한 청년 정책 정보를 제공해. " +
                "주어진 정책 목록 데이터를 기반으로 친절하고 이해하기 쉬운 말투로 응답해. " +
                "정책은 아래 형식을 **정확히 지켜서** 응답하고, 반드시 **줄바꿈(\\n)** 으로 항목을 구분해서 가독성 좋게 정리해.\n\n" +
                "📌 출력 형식 예시:\n" +
                "1. 정책명: 청년 월세 지원\n" +
                "   설명: 월세 부담을 덜어주기 위해 청년에게 최대 20만 원을 지원합니다.\n" +
                "   신청 주소: https://example.com/rent\n\n" +
                "2. 정책명: 청년 전세 자금 이자지원\n" +
                "   설명: 전세 자금 대출에 대한 이자를 일부 지원합니다.\n" +
                "   신청 주소: https://example.com/loan\n\n" +
                "⚠️ 모든 항목마다 반드시 줄바꿈(\n)을 하고, 보기 좋게 들여쓰기(띄어쓰기 3~4칸)를 유지해. " +
                "HTML이 아니고, 일반 텍스트 환경에서 보았을 때도 잘 읽히도록 출력해.";


        Map<String, String> systemMessage = Map.of(
                "role", "system",
                "content", systemPrompt + "\n\n[정책 데이터]\n" + policyDataForPrompt);

        Map<String, String> userMessage = Map.of(
                "role", "user",
                "content", userQuestion);

        // 7. OpenAI API 호출 준비
        String openAiApiUrl = "https://api.openai.com/v1/chat/completions";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(openAiApiKey);

        Map<String, Object> requestBody = Map.of(
                "model", "gpt-4o-mini",
                "messages", List.of(systemMessage, userMessage)
        );

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        // 8. API 호출
        String response = restTemplate.postForObject(openAiApiUrl, entity, String.class);

        // 9. 응답에서 답변 추출
        ObjectMapper mapper = new ObjectMapper();
        return mapper.readTree(response)
                .path("choices").get(0)
                .path("message")
                .path("content").asText("죄송합니다. 답변을 생성하는 데 문제가 발생했습니다.");
    }
}
