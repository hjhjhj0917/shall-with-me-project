package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import kopo.shallwithme.dto.*;
import kopo.shallwithme.service.IChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping(value = "/chat")
@RequiredArgsConstructor
@Controller
public class ChattingController {


    private final SimpMessagingTemplate messagingTemplate;
    private final IChatService chatService;


    @MessageMapping("/chat.sendMessage")
    public void sendMessage(ChatMessageDTO chatMessage) {
        log.info("{}.sendMessage Start!", this.getClass().getName());

        try {
            ZoneId seoulZone = ZoneId.of("Asia/Seoul");
            LocalDateTime seoulTime = LocalDateTime.now(seoulZone);
            chatMessage.setSentAt(seoulTime);

            ChatMessageDTO savedMessage = chatService.saveMessage(chatMessage);

            messagingTemplate.convertAndSend("/topic/chatroom/" + savedMessage.getRoomId(), savedMessage);

        } catch (Exception e) {
            log.error("메시지 전송 및 저장 중 오류 발생: {}", chatMessage.toString(), e);
        }

        log.info("{}.sendMessage End!", this.getClass().getName());
    }


    @GetMapping("/messages")
    @ResponseBody
    public List<ChatMessageDTO> getMessages(HttpServletRequest request) {

        log.info("{}.getMessages Start!", this.getClass().getName());

        String roomIdStr = request.getParameter("roomId");

        log.info("roomId : {}", roomIdStr);

        if (roomIdStr == null) {
            throw new IllegalArgumentException("roomId 파라미터가 필요합니다.");
        }
        Integer roomId = Integer.valueOf(roomIdStr);

        log.info("{}.getMessages End!", this.getClass().getName());

        return chatService.getMessagesByRoomId(roomId);
    }


    @PostMapping("createRoom")
    @ResponseBody
    public Map<String, Object> createChatRoom(@Valid @RequestBody ChatRoomDTO pDTO, BindingResult bindingResult) {

        log.info("{}.createRoom Start!", this.getClass().getName());

        Map<String, Object> response = new HashMap<>();

        if (bindingResult.hasErrors()) {
            String errorMessage = bindingResult.getAllErrors().get(0).getDefaultMessage();
            response.put("result", 0);
            response.put("msg", errorMessage);
            return response;
        }

        try {
            int newRoomId = chatService.createRoom(pDTO);

            log.info("새 룸 아이디 : {}", newRoomId);

            response.put("result", 1);
            response.put("roomId", newRoomId);

        } catch (Exception e) {
            log.error("채팅방 생성 실패", e);
            response.put("result", 0);
            response.put("msg", "채팅방 생성 중 오류가 발생했습니다.");
        }

        log.info("{}.createRoom End!", this.getClass().getName());

        return response;
    }


    @GetMapping("chatRoom")
    public String chatRoomPage(ChatRoomDTO pDTO, Model model, HttpSession session) throws Exception {

        log.info("{}.chatRoomPage Start!", this.getClass().getName());

        log.info("roomId: {}", pDTO.getRoomId());
        model.addAttribute("roomId", pDTO.getRoomId());

        ChatRoomDTO cDTO = new ChatRoomDTO();
        cDTO.setRoomId(pDTO.getRoomId());

        ChatRoomDTO rDTO = chatService.getOtherUserId(cDTO);
        rDTO.setMyUserId(session.getAttribute("SS_USER_ID").toString());

        UserProfileDTO otherUser = chatService.getImageUrlByUserId(rDTO);

        log.info("myUserId : {}", rDTO.getMyUserId());
        log.info("user2Id : {}", rDTO.getUser2Id());
        log.info("otherUser : {}", otherUser);

        model.addAttribute("otherUser", otherUser);

        log.info("{}.chatRoomPage End!", this.getClass().getName());

        return "chat/chatRoom";
    }


    // 메세지 주고받은 유저만 불러오기
    @GetMapping("chatPartners")
    @ResponseBody
    public ResponseEntity<List<ChatPartnerDTO>> getChatPartners(HttpSession session) throws Exception {

        log.info(this.getClass().getName() + ".getChatPartners Start!");

        String userId = (String) session.getAttribute("SS_USER_ID");

        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(java.util.Collections.emptyList());
        }

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        List<ChatPartnerDTO> rList = chatService.getChatPartners(pDTO);

        log.info(this.getClass().getName() + ".getChatPartners End!");

        return ResponseEntity.ok(rList);
    }


    // 상대방과의 채팅방 생성 또는 기존 방 조회
    @GetMapping("createOrGetRoom")
    @ResponseBody
    public Map<String, Object> createOrGetRoom(ChatRoomDTO pDTO, HttpSession session) {

        log.info("{}.createOrGetRoom Start!", this.getClass().getName());

        Map<String, Object> response = new HashMap<>();
        String currentUserId = (String) session.getAttribute("SS_USER_ID");

        // DTO에서 상대방 ID를 가져옴 (이제 user2Id 필드에 담겨있음)
        String otherUserId = pDTO.getUser2Id();

        // 파라미터 유효성 검사
        if (otherUserId == null || otherUserId.isBlank()) {
            response.put("result", 0);
            response.put("msg", "상대방 ID가 필요합니다.");
            return response;
        }

        if (currentUserId == null || currentUserId.equals(otherUserId)) {
            response.put("result", 0);
            response.put("msg", "올바르지 않은 사용자 요청입니다.");
            return response;
        }

        try {
            ChatRoomDTO cDTO = new ChatRoomDTO();
            cDTO.setUser1Id(currentUserId);
            cDTO.setUser2Id(otherUserId);

            int roomId = chatService.createOrGetChatRoom(cDTO);

            response.put("result", 1);
            response.put("roomId", roomId);

        } catch (Exception e) {
            log.error("채팅방 생성 실패: {}", e.getMessage(), e);
            response.put("result", 0);
            response.put("msg", "채팅방 생성 중 오류가 발생했습니다.");
        }

        log.info("{}.createOrGetRoom End!", this.getClass().getName());

        return response;
    }


    @MessageMapping("/chat.readMessage")
    public void readMessage(ChatMessageDTO readMessage) {
        log.info("{}.readMessage Start!", this.getClass().getName());

        if (readMessage.getReaderId() == null || readMessage.getReaderId().isBlank() || readMessage.getReaderId().equals("null")) {
            log.warn("비정상적인 readerId를 수신하여 읽음 처리를 중단합니다. DTO: {}", readMessage.toString());
            return; // readerId가 없으면 아무 작업도 하지 않고 종료
        }

        try {
            chatService.updateReadStatus(readMessage.getRoomId(), readMessage.getReaderId());

            messagingTemplate.convertAndSend("/topic/read/" + readMessage.getRoomId(), readMessage);

        } catch (Exception e) {
            log.error("메시지 읽음 처리 중 오류 발생: {}", readMessage.toString(), e);
        }

        log.info("{}.readMessage End!", this.getClass().getName());
    }


    @GetMapping("/totalUnreadCount")
    @ResponseBody
    public ResponseEntity<Map<String, Integer>> getTotalUnreadCount(HttpSession session) {
        String userId = (String) session.getAttribute("SS_USER_ID");
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        Map<String, Integer> response = new HashMap<>();
        try {
            int totalCount = chatService.getTotalUnreadCount(userId);
            response.put("totalCount", totalCount);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Total unread count 조회 중 오류", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }


    // 회원 메시지 보관 페이지
    @GetMapping("userListPage")
    public String userListPage() {

        log.info("{}.userListPage Start!", this.getClass().getName());
        log.info("{}.userListPage End!", this.getClass().getName());

        return "chat/userList";
    }

}
