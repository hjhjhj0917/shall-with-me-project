package kopo.shallwithme.service.impl;

import dev.langchain4j.data.embedding.Embedding;
import dev.langchain4j.data.message.AiMessage;
import dev.langchain4j.data.message.SystemMessage;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.model.output.Response;
import dev.langchain4j.store.embedding.EmbeddingMatch;
import dev.langchain4j.store.embedding.EmbeddingStore;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChatbotService {

    private final ChatLanguageModel chatLanguageModel;

    // ✅ 저수준(Low-level) RAG를 위해 Store와 Model을 직접 주입
    private final EmbeddingStore<TextSegment> embeddingStore;
    private final EmbeddingModel embeddingModel;

    public String getAnswer(String userQuestion) throws Exception {

        // 1. 사용자 질문을 임베딩(벡터화)
        Response<Embedding> embeddingResponse = embeddingModel.embed(userQuestion);
        Embedding queryEmbedding = embeddingResponse.content();

        // 2. EmbeddingStore에서 유사한 벡터(TextSegment)를 직접 검색 (최대 5개, 유사도 0.65 이상)
        List<EmbeddingMatch<TextSegment>> relevantMatches = embeddingStore.findRelevant(queryEmbedding, 5, 0.65);

        // 3. 검색된 조각을 프롬프트용 데이터로 포맷팅
        String policyDataForPrompt = relevantMatches.stream()
                .map(match -> {
                    TextSegment segment = match.embedded();
                    String name = segment.metadata().getString("policy_name");
                    String url = segment.metadata().getString("policy_url");
                    String relevantChunk = segment.text();

                    return String.format("- 정책명: %s\n  관련 내용: %s\n  신청 주소: %s",
                            name, relevantChunk, url);
                })
                .collect(Collectors.joining("\n\n"));

        if (policyDataForPrompt.isBlank()) {
            policyDataForPrompt = "현재 질문에 맞는 정책 데이터가 없습니다.";
        }

        // 4. 시스템 프롬프트 구성
        String systemPrompt = "너는 대한민국 청년 정책 전문 챗봇 '살며시'야. " +
                "사용자가 궁금한 점에 대해 가장 관련 깊은 청년 정책 정보를 친절하고 알기 쉽게 알려줘. " +
                "**오직 아래 제공된 [정책 목록]에 있는 정보만을 사용해서 답변해야 해.** 목록에 없는 내용은 모른다고 답해.\n\n" +
                "[정책 목록]\n" + policyDataForPrompt + "\n\n" +
                "답변은 평이한 문장으로 작성하고, 각 정책은 정책명, 관련 내용, 신청 주소를 꼭 포함해줘.";

        // 5. LLM 호출
        try {
            SystemMessage systemMessage = SystemMessage.from(systemPrompt);
            UserMessage userMessage = UserMessage.from(userQuestion);

            Response<AiMessage> response = chatLanguageModel.generate(systemMessage, userMessage);
            return response.content().text();

        } catch (Exception e) {
            log.error("Langchain4j RAG 모델 호출 실패", e);
            return "죄송합니다. 답변을 생성하는 데 문제가 발생했습니다.";
        }
    }
}
