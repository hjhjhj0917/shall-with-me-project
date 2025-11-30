package kopo.shallwithme.service.impl;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
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
import org.springframework.core.io.ClassPathResource;
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
        log.info("Application context refreshed. Checking embedding store status...");

        try {
            Path storePath;
            Resource classpathResource = null;

            if (embeddingStorePath.startsWith("classpath:")) {
                String resourcePath = embeddingStorePath.replace("classpath:", "");
                classpathResource = new ClassPathResource(resourcePath);
            } else {
                storePath = Paths.get(embeddingStorePath);
            }

            if (!embeddingStorePath.startsWith("classpath:") && Files.exists(Paths.get(embeddingStorePath))) {
                log.info("Embedding store file ({}) found in filesystem.", embeddingStorePath);
                return;
            }

            if (classpathResource != null && classpathResource.exists()) {
                log.info("Embedding store found in classpath: {}", classpathResource.getFilename());
                return;
            }

            log.info("Embedding store not found. Generating from database...");
            List<YouthPolicyDTO> allPolicies = youthPolicyService.getPolicies();
            if (allPolicies == null || allPolicies.isEmpty()) {
                log.warn("No policy data found in the database. Skipping initial embedding.");
                return;
            }

            int embeddedCount = this.embedAndStorePolicies(allPolicies);
            log.info("Successfully embedded and stored {} segments from {} initial policies.", embeddedCount, allPolicies.size());
            if (embeddedCount > 0) {
                saveStoreToFile();
            }

        } catch (Exception e) {
            log.error("Error initializing embedding store", e);
        }
    }

    public void embedNewPolicies(List<YouthPolicyDTO> policiesToEmbed) {
        if (policiesToEmbed == null || policiesToEmbed.isEmpty()) {
            log.info("No new policies to embed.");
            return;
        }
        log.info("Starting embedding for {} new policies...", policiesToEmbed.size());
        try {
            int embeddedCount = this.embedAndStorePolicies(policiesToEmbed);
            log.info("Successfully embedded {} segments from {} new policies.", embeddedCount, policiesToEmbed.size());
            if (embeddedCount > 0) {
                saveStoreToFile();
            }
        } catch (Exception e) {
            log.error("Failed embedding new policies.", e);
        }
    }


    private int embedAndStorePolicies(List<YouthPolicyDTO> policies) {
        if (policies == null || policies.isEmpty()) {
            return 0;
        }

        List<Document> documents = policies.stream()
                .map(this::dtoToDocument)
                .collect(Collectors.toList());

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

        List<TextSegment> allSegments = new ArrayList<>();
        for (Document doc : validDocuments) {
            allSegments.addAll(documentSplitter.split(doc));
        }
        log.debug("Split {} documents into {} segments.", validDocuments.size(), allSegments.size());

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

        log.info("Sending {} text segments to OpenAI embedding API...", validSegments.size());

        int BATCH_SIZE = 500;
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
        try {
            log.info("Saving embedding store state to file ({}) ...", embeddingStorePath);
            String json = embeddingStore.serializeToJson();

            if (embeddingStorePath.startsWith("classpath:")) {
                log.warn("Cannot save to classpath resource ({}). Skipping save.", embeddingStorePath);
                return;
            }

            Path storePath = Paths.get(embeddingStorePath);
            Files.writeString(storePath, json);

            log.info("Embedding store saved successfully.");
        } catch (IOException e) {
            log.error("Failed to save embedding store file ({}).", embeddingStorePath, e);
        } catch (Exception e) {
            log.error("Unexpected error while saving embedding store JSON.", e);
        }
    }
}
