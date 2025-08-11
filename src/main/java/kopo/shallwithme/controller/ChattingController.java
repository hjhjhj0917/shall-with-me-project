package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.ChatDTO;
import kopo.shallwithme.dto.ChatRoomDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.service.IChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
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
    public void sendMessage(ChatDTO chatMessage) {
        // timestamp가 비어 있으면 현재 시간으로 설정
        if (chatMessage.getTimestamp() == null) {
            chatMessage.setTimestamp(LocalDateTime.now().toString());
        }

        chatService.saveMessage(chatMessage);
        messagingTemplate.convertAndSend("/topic/chatroom/" + chatMessage.getRoomId(), chatMessage);
    }

    @GetMapping("/messages")
    @ResponseBody
    public List<ChatDTO> getMessages(HttpServletRequest request) {
        String roomIdStr = request.getParameter("roomId");
        if (roomIdStr == null) {
            throw new IllegalArgumentException("roomId 파라미터가 필요합니다.");
        }
        Integer roomId = Integer.valueOf(roomIdStr);
        return chatService.getMessagesByRoomId(roomId);
    }

    @PostMapping("createRoom")
    @ResponseBody
    public int createChatRoom(@RequestParam String user1Id, @RequestParam String user2Id) {
        return chatService.createRoom(user1Id, user2Id);
    }

    @GetMapping("rooms")
    @ResponseBody
    public List<ChatRoomDTO> getChatRooms(@RequestParam String userId) {
        return chatService.getRoomsByUserId(userId);
    }

    @GetMapping("chatRoom")
    public String chatRoomPage(@RequestParam(required = false) Integer roomId, Model model) {
        log.info("Controller roomId: {}", roomId);
        model.addAttribute("roomId", roomId);
        return "chat/chatRoom";
    }


    @GetMapping("userList")
    @ResponseBody
    public List<UserInfoDTO> getUserList() throws Exception {
        return chatService.getUserList(); // JSON 형태로 반환됨
    }


    @GetMapping("userListPage")
    public String userListPage() {
        return "chat/userList";  // /WEB-INF/views/chat/userList.jsp
    }

    // 상대방과의 채팅방 생성 또는 기존 방 조회
    @GetMapping("createOrGetRoom")
    @ResponseBody
    public ResponseEntity<?> createOrGetRoom(@RequestParam String otherUserId, HttpSession session) {
        String currentUserId = (String) session.getAttribute("SS_USER_ID");

        if (currentUserId == null || currentUserId.equals(otherUserId)) {
            return ResponseEntity.badRequest().body("올바르지 않은 사용자 요청입니다.");
        }

        try {
            int roomId = chatService.createOrGetChatRoom(currentUserId, otherUserId);
            // ✅ JSON 형태로 리턴
            return ResponseEntity.ok().body(Map.of("roomId", roomId));
        } catch (Exception e) {
            log.error("❌ 채팅방 생성 실패: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("채팅방 생성 중 오류가 발생했습니다.");
        }
    }

}
