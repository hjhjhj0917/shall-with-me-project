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
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;

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

    // 2. Embedding Model
    @Bean
    public EmbeddingModel embeddingModel() {
        return OpenAiEmbeddingModel.builder()
                .apiKey(openAiApiKey)
                .modelName("text-embedding-3-small")
                .timeout(Duration.ofSeconds(60))

                .build();
    }

    // 3. Embedding Store

    @Bean
    public InMemoryEmbeddingStore<TextSegment> embeddingStore() {
        try {
            Resource resource = new ClassPathResource("shallwithme-embedding-store.json");

            if (resource.exists()) {
                log.info("기존 임베딩 파일(shallwithme-embedding)을 classpath에서 로드합니다.");

                String json = new String(resource.getInputStream().readAllBytes());
                return InMemoryEmbeddingStore.fromJson(json);
            } else {
                log.warn("임베딩 파일이 classpath에 없습니다. 새 InMemoryEmbeddingStore를 생성합니다.");
                return new InMemoryEmbeddingStore<>();
            }
        } catch (IOException e) {
            log.error("임베딩 파일 로드 중 오류 발생. 새 저장소를 생성합니다.", e);
            return new InMemoryEmbeddingStore<>();
        }
    }

}
