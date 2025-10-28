package kopo.shallwithme.config;

import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.model.openai.OpenAiChatModel;
import dev.langchain4j.model.openai.OpenAiEmbeddingModel;
import dev.langchain4j.store.embedding.inmemory.InMemoryEmbeddingStore;
import dev.langchain4j.store.embedding.inmemory.InMemoryEmbeddingStoreJsonCodec;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;

@Slf4j
@Configuration
public class Langchain4jConfig {

    @Value("${secure.openai.api.key}")
    private String openAiApiKey;

    @Value("${langchain4j.embedding.store.path:./shallwithme-embedding-store.json}")
    private String embeddingStorePath;

    // 1. Chat Model (변경 없음)
    @Bean
    public ChatLanguageModel chatLanguageModel() {
        return OpenAiChatModel.builder()
                .apiKey(openAiApiKey)
                .modelName("gpt-4o-mini")
                .temperature(0.7)
                .maxTokens(800)
                .timeout(Duration.ofSeconds(60))
                .build();
    }

    // 2. Embedding Model (변경 없음)
    @Bean
    public EmbeddingModel embeddingModel() {
        return OpenAiEmbeddingModel.builder()
                .apiKey(openAiApiKey)
                .modelName("text-embedding-3-small")
                .timeout(Duration.ofSeconds(60))
                .build();
    }

    // 3. Embedding Store (✅ [핵심 수정])
    // Bean의 반환 타입을 'InMemoryEmbeddingStore' (구현 클래스)로 명시
    @Bean
    public InMemoryEmbeddingStore<TextSegment> embeddingStore() {

        Path storePath = Paths.get(embeddingStorePath);

        // 앱 시작 시 JSON 파일이 있으면, 파일을 읽어서 복원
        if (Files.exists(storePath)) {
            try {
                log.info("기존 임베딩 파일({})을 로드합니다.", embeddingStorePath);
                String json = Files.readString(storePath);
                // ✅ Codec이 아닌 'InMemoryEmbeddingStore.fromJson' (static 메서드) 사용
                return InMemoryEmbeddingStore.fromJson(json);
            } catch (IOException e) {
                log.error("임베딩 파일 로드 실패. 새 저장소를 생성합니다.", e);
            }
        }

        // 파일이 없으면, 비어있는 새 저장소를 생성
        log.info("기존 임베딩 파일이 없습니다. 새 InMemoryEmbeddingStore를 생성합니다.");
        return new InMemoryEmbeddingStore<>();
    }
}
