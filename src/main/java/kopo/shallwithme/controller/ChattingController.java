package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import kopo.shallwithme.dto.ChatDTO;
import kopo.shallwithme.dto.ChatPartnerDTO;
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
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
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
    public void sendMessage(ChatDTO chatMessage) {

        log.info("{}.sendMessage Start!", this.getClass().getName());

        // timestamp가 비어 있으면 현재 시간으로 설정
        if (chatMessage.getTimestamp() == null) {
            chatMessage.setTimestamp(LocalDateTime.now().toString());
        }

        chatService.saveMessage(chatMessage);
        messagingTemplate.convertAndSend("/topic/chatroom/" + chatMessage.getRoomId(), chatMessage);

        log.info("{}.sendMessage End!", this.getClass().getName());
    }

    @GetMapping("/messages")
    @ResponseBody
    public List<ChatDTO> getMessages(HttpServletRequest request) {

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
            response.put("result", 0); // 0: 실패
            response.put("msg", errorMessage);
            return response;
        }

        try {
            int newRoomId = chatService.createRoom(pDTO);

            response.put("result", 1); // 1: 성공
            response.put("roomId", newRoomId); // 성공 시 생성된 roomId 추가

            log.info("{}.createRoom End!", this.getClass().getName());

        } catch (Exception e) {
            log.error("채팅방 생성 실패", e);
            response.put("result", 0); // 0: 실패
            response.put("msg", "채팅방 생성 중 오류가 발생했습니다.");
        }

        return response;
    }

    @GetMapping("rooms")
    @ResponseBody
    public List<ChatRoomDTO> getChatRooms(@RequestParam String userId) {

        return chatService.getRoomsByUserId(userId);
    }

    @GetMapping("chatRoom")
    public String chatRoomPage(@RequestParam(required = false) Integer roomId, Model model) {

        log.info("{}.chatRoomPage Start!", this.getClass().getName());

        log.info("Controller roomId: {}", roomId);
        model.addAttribute("roomId", roomId);

        log.info("{}.chatRoomPage End!", this.getClass().getName());

        return "chat/chatRoom";
    }

    // 메세지 주고받은 유저만 불러오기
    @GetMapping("chatPartners")
    @ResponseBody
    public ResponseEntity<List<ChatPartnerDTO>> getChatPartners(HttpSession session) throws Exception {

        log.info(this.getClass().getName() + ".getChatPartners Start!");

        String userId = (String) session.getAttribute("SS_USER_ID");

        if (userId == null) { // 로그인한 상태인지 확인 // 보안상 더 안전한 방법이라는데 공부가 필요함!
            // HttpStatus.UNAUTHORIZED: 서버가 클라이언트에게 보내는 HTTP 응답 상태 코드를 401 Unauthorized 설정
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(java.util.Collections.emptyList());
        }

        // DTO 객체 생성 및 userId 설정
        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        // DTO를 매개변수로 전달
        List<ChatPartnerDTO> rList = chatService.getChatPartners(pDTO);

        log.info(this.getClass().getName() + ".getChatPartners End!");

        return ResponseEntity.ok(rList);
    }

    @GetMapping("userListPage")
    public String userListPage() {

        return "chat/userList";  // /WEB-INF/views/chat/userList.jsp
    }

    // 상대방과의 채팅방 생성 또는 기존 방 조회
    @GetMapping("createOrGetRoom")
    @ResponseBody
    public ResponseEntity<?> createOrGetRoom(@RequestParam String otherUserId, HttpSession session) {

        log.info("{}.createOrGetRoom Start!", this.getClass().getName());

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

    @GetMapping("userList")
    @ResponseBody
    public List<UserInfoDTO> getUserList() throws Exception {

        log.info("{}.getUserList Start!", this.getClass().getName());

        return chatService.getUserList(); // JSON 형태로 반환됨
    }


    @GetMapping("chatTest")
    public String chatTest() {

        return "chat/chatTest";  // /WEB-INF/views/chat/userList.jsp
    }

}
