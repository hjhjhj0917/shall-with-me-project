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
    public ResponseEntity<ScheduleDTO> requestSchedule(@RequestBody ScheduleDTO pDTO, HttpSession session) {
        log.info("{}.requestSchedule (Refactored) Start!", this.getClass().getName());

        String userId = (String) session.getAttribute("SS_USER_ID");
        pDTO.setCreatorId(userId);

        // 1. 서비스 계층을 통해 'PENDING' 상태로 DB에 먼저 저장하고, ID가 부여된 객체를 반환받음
        ScheduleDTO savedSchedule = scheduleService.insertScheduleRequest(pDTO);

        // 2. 채팅 메시지 생성 시, DB에 저장되어 ID가 부여된 객체를 사용
        ChatMessageDTO chatMessage = ChatMessageDTO.builder()
                .roomId(savedSchedule.getRoomId())
                .senderId(userId)
                .messageType("SCHEDULE_REQUEST") // 프론트와 약속한 타입명 사용
                .scheduleRequest(savedSchedule) // ID가 포함된 스케줄 정보
                .sentAt(LocalDateTime.now())
                .build();

        // 3. WebSocket으로 요청 메시지 전송
        messagingTemplate.convertAndSend("/topic/chatroom/" + savedSchedule.getRoomId(), chatMessage);

        log.info("{}.requestSchedule (Refactored) End!", this.getClass().getName());

        // 4. 요청이 성공적으로 처리되었음을 프론트에 알림 (저장된 객체 반환)
        return ResponseEntity.ok(savedSchedule);
    }

    @PostMapping("/api/events/{scheduleId}/confirm")
    @ResponseBody
    public ResponseEntity<String> acceptSchedule(@PathVariable("scheduleId") int scheduleId) {
        log.info("acceptSchedule for ID: {}", scheduleId);

        // 1. 서비스 계층을 통해 상태를 'CONFIRMED'로 변경
        scheduleService.updateScheduleStatus(scheduleId, "CONFIRMED");

        // 2. 채팅방에 알릴 정보 조회
        ScheduleDTO confirmedSchedule = scheduleService.getScheduleById(scheduleId);

        // 3. 채팅방에 '수락됨' 알림 메시지 전송
        ChatMessageDTO noticeMessage = ChatMessageDTO.builder()
                .roomId(confirmedSchedule.getRoomId())
                .messageType("SCHEDULE_CONFIRMED") // 수락 알림 타입
                .message(confirmedSchedule.getTitle() + " 일정이 확정되었습니다.")
                // .senderId("system") // 시스템 메시지로 보낼 수도 있음
                .sentAt(LocalDateTime.now())
                .build();

        messagingTemplate.convertAndSend("/topic/chatroom/" + confirmedSchedule.getRoomId(), noticeMessage);

        return ResponseEntity.ok("일정을 수락했습니다.");
    }

    @PostMapping("/api/events/{scheduleId}/reject")
    @ResponseBody
    public ResponseEntity<String> rejectSchedule(@PathVariable("scheduleId") int scheduleId) {
        log.info("rejectSchedule for ID: {}", scheduleId);

        // 1. 서비스 계층을 통해 상태를 'REJECTED'로 변경
        scheduleService.updateScheduleStatus(scheduleId, "REJECTED");

        // ... (거절됨 알림 메시지를 WebSocket으로 보내는 로직 추가) ...

        return ResponseEntity.ok("일정을 거절했습니다.");
    }


}
