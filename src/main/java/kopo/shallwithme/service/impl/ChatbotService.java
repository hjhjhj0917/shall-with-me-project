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
    private final EmbeddingStore<TextSegment> embeddingStore;
    private final EmbeddingModel embeddingModel;

    public String getAnswer(String userQuestion) throws Exception {

        Response<Embedding> embeddingResponse = embeddingModel.embed(userQuestion);
        Embedding queryEmbedding = embeddingResponse.content();

        List<EmbeddingMatch<TextSegment>> relevantMatches = embeddingStore.findRelevant(queryEmbedding, 5, 0.65);

        String policyDataForPrompt = relevantMatches.stream()
                .map(match -> {
                    TextSegment segment = match.embedded();
                    String name = segment.metadata().getString("policy_name");
                    String url = segment.metadata().getString("policy_url");
                    String relevantChunk = segment.text();

                    StringBuilder infoBuilder = new StringBuilder();
                    infoBuilder.append(String.format("- 정책명: %s\n  관련 내용: %s", name, relevantChunk));

                    if (url != null && !url.isBlank() && !url.equals("null")) {
                        infoBuilder.append(String.format("\n  신청 주소: %s", url));
                    }

                    return infoBuilder.toString();
                })
                .collect(Collectors.joining("\n\n"));

        if (policyDataForPrompt.isBlank()) {
            policyDataForPrompt = "현재 질문에 맞는 정책 데이터가 없습니다.";
        }

        String systemPrompt = "너는 대한민국 청년 정책 전문 챗봇 '살며시'야. " +
                "사용자가 궁금한 점에 대해 가장 관련 깊은 청년 정책 정보를 친절하고 알기 쉽게 알려줘. " +
                "**오직 아래 제공된 [정책 목록]에 있는 정보만을 사용해서 답변해야 해.** 목록에 없는 내용은 모른다고 답해.\n\n" +
                "[정책 목록]\n" + policyDataForPrompt + "\n\n" +
                "[답변 규칙]\n" +
                "1. 답변은 평이한 문장으로 작성해줘.\n" +
                "2. 각 정책의 이름과 관련 내용을 먼저 설명해줘.\n" +
                "3. **'신청 주소' 정보가 정책 목록에 있는 경우에만 포함하고, 없다면 절대 '신청주소'라는 단어나 URL을 언급하지 마.**";

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