package kopo.shallwithme.service.impl;

import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.document.Metadata;
import dev.langchain4j.data.document.DocumentSplitter;
import dev.langchain4j.data.document.splitter.DocumentSplitters;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.data.embedding.Embedding;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.model.output.Response;
import dev.langchain4j.store.embedding.inmemory.InMemoryEmbeddingStore;
import kopo.shallwithme.dto.YouthPolicyDTO;
import kopo.shallwithme.service.IYouthPolicyService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
public class PolicyEmbeddingService implements ApplicationListener<ContextRefreshedEvent> {

    private final IYouthPolicyService youthPolicyService;
    private final EmbeddingModel embeddingModel;
    private final InMemoryEmbeddingStore<TextSegment> embeddingStore;

    @Value("${langchain4j.embedding.store.path:./shallwithme-embedding-store.json}")
    private String embeddingStorePath;

    // Splitter를 필드로 선언하여 재사용
    private final DocumentSplitter documentSplitter = DocumentSplitters.recursive(300, 50);

    public PolicyEmbeddingService(@Lazy IYouthPolicyService youthPolicyService,
                                  EmbeddingModel embeddingModel,
                                  InMemoryEmbeddingStore<TextSegment> embeddingStore) {
        this.youthPolicyService = youthPolicyService;
        this.embeddingModel = embeddingModel;
        this.embeddingStore = embeddingStore;
    }

    @Override
    public void onApplicationEvent(ContextRefreshedEvent event) {
        // (onApplicationEvent 메서드 내용은 이전과 동일)
        log.info("Application context refreshed. Checking embedding store status...");
        Path storePath = Paths.get(embeddingStorePath);
        if (!Files.exists(storePath)) {
            log.info("Embedding store file ({}) not found. Embedding all policies from DB...", embeddingStorePath);
            try {
                List<YouthPolicyDTO> allPolicies = youthPolicyService.getPolicies();
                if (allPolicies == null || allPolicies.isEmpty()) {
                    log.warn("No policy data found in the database. Skipping initial embedding.");
                    return;
                }
                int embeddedCount = this.embedAndStorePolicies(allPolicies); // 메서드 이름 변경
                log.info("Successfully embedded and stored {} segments from {} initial policies.", embeddedCount, allPolicies.size());
                if (embeddedCount > 0) {
                    saveStoreToFile();
                }
            } catch (Exception e) {
                log.error("Failed during initial embedding of all policies.", e);
            }
        } else {
            log.info("Embedding store file ({}) exists. Assuming it was loaded successfully.", embeddingStorePath);
        }
    }

    public void embedNewPolicies(List<YouthPolicyDTO> policiesToEmbed) {
        // (embedNewPolicies 메서드 내용은 이전과 거의 동일, 호출 메서드 이름 변경)
        if (policiesToEmbed == null || policiesToEmbed.isEmpty()) {
            log.info("No new policies to embed.");
            return;
        }
        log.info("Starting embedding for {} new policies...", policiesToEmbed.size());
        try {
            int embeddedCount = this.embedAndStorePolicies(policiesToEmbed); // 메서드 이름 변경
            log.info("Successfully embedded {} segments from {} new policies.", embeddedCount, policiesToEmbed.size());
            if (embeddedCount > 0) {
                saveStoreToFile();
            }
        } catch (Exception e) {
            log.error("Failed embedding new policies.", e);
        }
    }

    /**
     * ✅ [로직 변경] DTO 리스트를 Document로 변환하고, 직접 분할 및 필터링 후,
     * EmbeddingModel과 EmbeddingStore를 직접 사용하여 임베딩하고 저장합니다.
     * @param policies 임베딩할 정책 DTO 리스트
     * @return 실제로 저장된 TextSegment의 개수
     */
    private int embedAndStorePolicies(List<YouthPolicyDTO> policies) {
        if (policies == null || policies.isEmpty()) {
            return 0;
        }

        // 1. DTO -> Document 변환
        List<Document> documents = policies.stream()
                .map(this::dtoToDocument)
                .collect(Collectors.toList());

        // 2. 내용이 비어있지 않은 Document만 필터링
        List<Document> validDocuments = documents.stream()
                .filter(doc -> doc.text() != null && !doc.text().isBlank())
                .collect(Collectors.toList());

        int skippedDocCount = documents.size() - validDocuments.size();
        if (skippedDocCount > 0) {
            log.warn("{} documents were skipped due to blank content before splitting.", skippedDocCount);
        }

        if (validDocuments.isEmpty()) {
            log.info("No valid documents found to split and embed.");
            return 0;
        }

        // 3. 유효한 문서를 TextSegment로 직접 분할
        List<TextSegment> allSegments = new ArrayList<>();
        for (Document doc : validDocuments) {
            allSegments.addAll(documentSplitter.split(doc));
        }
        log.debug("Split {} documents into {} segments.", validDocuments.size(), allSegments.size());


        // 4. 분할된 세그먼트 중 텍스트가 비어있지 않은 것만 필터링 (OpenAI 오류 방지)
        List<TextSegment> validSegments = allSegments.stream()
                .filter(segment -> segment.text() != null && !segment.text().isBlank())
                .collect(Collectors.toList());

        int skippedSegCount = allSegments.size() - validSegments.size();
        if (skippedSegCount > 0) {
            log.warn("{} segments were skipped due to blank content after splitting.", skippedSegCount);
        }

        if (validSegments.isEmpty()) {
            log.info("No valid segments found to embed after splitting.");
            return 0;
        }

        // --- [디버깅 로그] ---
        log.info("Sending {} text segments to OpenAI embedding API...", validSegments.size());

        // --- 배치 단위로 나누어 임베딩 ---
        int BATCH_SIZE = 500; // 한 번에 보낼 세그먼트 수 (조정 가능)
        List<Embedding> allEmbeddings = new ArrayList<>();
        List<TextSegment> allValidSegments = new ArrayList<>();

        for (int i = 0; i < validSegments.size(); i += BATCH_SIZE) {
            int end = Math.min(i + BATCH_SIZE, validSegments.size());
            List<TextSegment> batch = validSegments.subList(i, end);

            log.info("Sending batch of {} text segments to OpenAI embedding API...", batch.size());
            Response<List<Embedding>> response = embeddingModel.embedAll(batch);
            List<Embedding> batchEmbeddings = response.content();

            allEmbeddings.addAll(batchEmbeddings);
            allValidSegments.addAll(batch);
        }

        // --- 임베딩 저장 ---
        try {
            embeddingStore.addAll(allEmbeddings, allValidSegments);
            log.info("Successfully added {} embeddings to the store.", allEmbeddings.size());
        } catch (UnsupportedOperationException e) {
            log.warn("EmbeddingStore does not support addAll(). Adding one by one.");
            if (allEmbeddings.size() == allValidSegments.size()) {
                for (int i = 0; i < allEmbeddings.size(); i++) {
                    embeddingStore.add(allEmbeddings.get(i), allValidSegments.get(i));
                }
            } else {
                log.error("Mismatch between embeddings ({}) and segments ({}).", allEmbeddings.size(), allValidSegments.size());
                return 0;
            }
        } catch (Exception e) {
            log.error("Error adding embeddings to the store.", e);
            return 0;
        }

        log.info("Successfully added {} embeddings to the store.", allEmbeddings.size());
        return allEmbeddings.size();

    }


    private Document dtoToDocument(YouthPolicyDTO dto) {
        // (dtoToDocument 메서드 내용은 이전과 동일)
        String content = dto.getPlcyExplnCn();
        if (content == null || content.isBlank()) {
            content = dto.getPlcyNm() != null ? dto.getPlcyNm() : "";
            if (content.isBlank()) {
                log.warn("Policy ID {} has blank explanation (plcyExplnCn) and name (plcyNm). Resulting document will be blank.", dto.getPlcyNo());
            } else {
                log.warn("Policy ID {} ('{}') has blank explanation (plcyExplnCn). Using name (plcyNm) as content.", dto.getPlcyNo(), dto.getPlcyNm());
            }
        }
        Metadata metadata = new Metadata();
        metadata.put("policy_name", dto.getPlcyNm());
        metadata.put("policy_url", dto.getAplyUrlAddr());
        return Document.from(content, metadata);
    }

    private synchronized void saveStoreToFile() {
        Path storePath = Paths.get(embeddingStorePath);
        try {
            log.info("Saving embedding store state to file ({}) ...", embeddingStorePath);

            ObjectMapper objectMapper = new ObjectMapper();

            // entries에 접근할 수 없으면, store 자체를 fromJson/serializeToJson 메서드를 활용
            // InMemoryEmbeddingStore는 serializeToJson() 메서드 제공
            String json = embeddingStore.serializeToJson();

            // 만약 serializeToJson()으로 바로 저장하면, 모든 Embedding+TextSegment가 JSON으로 직렬화됨
            Files.writeString(storePath, json);

            log.info("Embedding store saved successfully.");
        } catch (IOException e) {
            log.error("Failed to save embedding store file ({}).", embeddingStorePath, e);
        } catch (Exception e) {
            log.error("An unexpected error occurred while saving embedding data to JSON.", e);
        }
    }

}

