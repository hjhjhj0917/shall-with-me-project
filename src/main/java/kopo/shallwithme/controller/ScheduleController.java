package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.ChatMessageDTO;
import kopo.shallwithme.dto.ScheduleDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.service.impl.ScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import java.time.LocalDateTime;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping(value = "/schedule")
@RequiredArgsConstructor
@Controller
public class ScheduleController {

    private final ScheduleService scheduleService;
    private final SimpMessagingTemplate messagingTemplate;

    @GetMapping("scheduleReg")
    public String scheduleReg() {
        log.info("{}.scheduleReg Start!", this.getClass().getName());

        return "schedule/scheduleReg";
    }

    // 2. FullCalendar가 사용할 일정 데이터를 조회하는 API
    @GetMapping("/api/events")
    @ResponseBody
    public List<ScheduleDTO> getEvents(HttpSession session) {
        log.info("{}.getEvents Start!", this.getClass().getName());

        String userId = (String) session.getAttribute("SS_USER_ID");
        log.info("userId : {}", userId);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        List<ScheduleDTO> rList = scheduleService.getScheduleList(pDTO);

        log.info("{}.getEvents End!", this.getClass().getName());

        return rList;
    }

    // 3. 새로운 일정을 저장하는 API
    @PostMapping("/api/events")
    @ResponseBody
    public String addEvent(@RequestBody ScheduleDTO pDTO, HttpSession session) {
        log.info("{}.addEvent Start!", this.getClass().getName());

        String res = "";

        String userId = (String) session.getAttribute("SS_USER_ID");
        log.info("userId : {}", userId);

        pDTO.setCreatorId(userId); // 일정 생성자는 현재 로그인한 사용자

        int result = scheduleService.insertSchedule(pDTO);

        if (result > 0) {
            res = "일정저장 완료";
        } else {
            res = "일정저장 실패";
        }

        log.info("{}.addEvent End!", this.getClass().getName());

        return res;
    }

    // 일정 수정
    @PostMapping("/api/events/{id}")
    @ResponseBody
    public String updateSchedule(@PathVariable("id") int id, @RequestBody ScheduleDTO pDTO) throws Exception {
        log.info("{}.updateSchedule Start!", this.getClass().getName());

        log.info("scheduleId : {}", id);
        log.info("ScheduleDTO: {}", pDTO);

        pDTO.setScheduleId(id);

        int result = scheduleService.updateSchedule(pDTO);
        String msg;

        if (result > 0) {
            msg = "일정이 수정되었습니다.";
        } else {
            msg = "일정 수정에 실패했습니다.";
        }

        log.info("{}.updateSchedule End!", this.getClass().getName());

        return msg;
    }

    // 일정 삭제
    @PostMapping("/scheduleDelete")
    @ResponseBody
    public String deleteSchedule(@RequestBody ScheduleDTO pDTO) throws Exception {
        log.info("{}.deleteSchedule Start!", this.getClass().getName());

        log.info("ScheduleDTO: {}", pDTO);

        int result = scheduleService.deleteSchedule(pDTO);
        String msg;

        if (result > 0) {
            msg = "일정이 삭제되었습니다.";
        } else {
            msg = "일정 삭제에 실패했습니다.";
        }

        log.info("{}.deleteSchedule End!", this.getClass().getName());

        return msg;
    }

    @PostMapping("/api/events/request")
    @ResponseBody
    public ResponseEntity<?> requestSchedule(@RequestBody ScheduleDTO pDTO, HttpSession session) {
        String userId = (String) session.getAttribute("SS_USER_ID");
        String roomId = pDTO.getRoomId();

        pDTO.setCreatorId(userId);

        // DB 저장 없이 수락 요청 메시지 생성
        ChatMessageDTO chatMessage = new ChatMessageDTO();
        chatMessage.setRoomId(roomId);
        chatMessage.setSenderId(userId);
        chatMessage.setMessageType("SCHEDULE");
        chatMessage.setSchedule(pDTO);
        chatMessage.setSentAt(LocalDateTime.now());

        // WebSocket으로 수락 요청 메시지 전송
        messagingTemplate.convertAndSend("/topic/chatroom/" + roomId, chatMessage);

        return ResponseEntity.ok().build();
    }

    @PostMapping("/api/events/accept")
    @ResponseBody
    public ResponseEntity<?> acceptSchedule(@RequestBody Map<String, String> payload) {
        String scheduleId = payload.get("scheduleId");
        String userId = payload.get("userId");

        try {
            // 실제 일정 저장/업데이트 로직 수행
            scheduleService.updateScheduleStatus(scheduleId, "ACCEPTED", userId);

            // 업데이트된 메시지 가져오기 (필요시)
            ChatMessageDTO updatedMsg = scheduleService.getChatMessageByScheduleId(scheduleId);

            // WebSocket으로 변경된 일정 메시지 전송 (알림용)
            messagingTemplate.convertAndSend("/topic/chatroom/" + updatedMsg.getRoomId(), updatedMsg);

            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("일정 수락 처리 실패");
        }
    }

    @PostMapping("/api/events/reject")
    @ResponseBody
    public ResponseEntity<?> rejectSchedule(@RequestBody Map<String, String> payload) {
        String scheduleId = payload.get("scheduleId");
        String userId = payload.get("userId");

        try {
            scheduleService.updateScheduleStatus(scheduleId, "REJECTED", userId);

            ChatMessageDTO updatedMsg = scheduleService.getChatMessageByScheduleId(scheduleId);

            messagingTemplate.convertAndSend("/topic/chatroom/" + updatedMsg.getRoomId(), updatedMsg);

            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("일정 거절 처리 실패");
        }
    }


}
