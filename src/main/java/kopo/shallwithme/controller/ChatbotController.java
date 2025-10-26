package kopo.shallwithme.controller;

import kopo.shallwithme.dto.ChatbotAnswerDTO;
import kopo.shallwithme.dto.ChatbotQuestionDTO;
import kopo.shallwithme.service.impl.ChatbotService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/chatbot")
@RequiredArgsConstructor
public class ChatbotController {

    private final ChatbotService chatbotService;

    @PostMapping("/ask")
    public ChatbotAnswerDTO ask(@RequestBody ChatbotQuestionDTO questionDTO) {
        log.info(this.getClass().getName() + ".ask Start!");

        ChatbotAnswerDTO answerDTO = new ChatbotAnswerDTO();
        try {
            String answer = chatbotService.getAnswer(questionDTO.getQuestion());
            answerDTO.setAnswer(answer);
        } catch (Exception e) {
            log.error("Error getting answer from chatbot service", e);
            answerDTO.setAnswer("죄송합니다. 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
        }

        log.info(this.getClass().getName() + ".ask End!");
        return answerDTO;
    }
}


