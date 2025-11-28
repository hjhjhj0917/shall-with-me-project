package kopo.shallwithme.controller;

import jakarta.servlet.http.HttpSession;
import kopo.shallwithme.dto.ChatMessageDTO;
import kopo.shallwithme.dto.ScheduleDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.service.impl.ScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@RequestMapping(value = "/schedule")
@RequiredArgsConstructor
@Controller
public class ScheduleController {


    private final ScheduleService scheduleService;
    private final SimpMessagingTemplate messagingTemplate;


    // 일정 데이터를 조회하는 API
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


    // 새로운 일정을 저장하는 API
    @PostMapping("/api/events")
    @ResponseBody
    public String addEvent(@RequestBody ScheduleDTO pDTO, HttpSession session) {
        log.info("{}.addEvent Start!", this.getClass().getName());

        String res = "";

        String userId = (String) session.getAttribute("SS_USER_ID");
        log.info("userId : {}", userId);

        pDTO.setCreatorId(userId);

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

        ScheduleDTO savedSchedule = scheduleService.insertScheduleRequest(pDTO);

        ChatMessageDTO chatMessage = ChatMessageDTO.builder()
                .roomId(savedSchedule.getRoomId())
                .senderId(userId)
                .messageType("SCHEDULE_REQUEST")
                .scheduleRequest(savedSchedule)
                .sentAt(LocalDateTime.now())
                .build();

        messagingTemplate.convertAndSend("/topic/chatroom/" + savedSchedule.getRoomId(), chatMessage);

        log.info("{}.requestSchedule (Refactored) End!", this.getClass().getName());

        return ResponseEntity.ok(savedSchedule);
    }


    @PostMapping("/api/events/{scheduleId}/confirm")
    @ResponseBody
    public ResponseEntity<String> acceptSchedule(@PathVariable("scheduleId") int scheduleId) {
        log.info("acceptSchedule for ID: {}", scheduleId);

        scheduleService.updateScheduleStatus(scheduleId, "CONFIRMED");

        ScheduleDTO confirmedSchedule = scheduleService.getScheduleById(scheduleId);

        ChatMessageDTO noticeMessage = ChatMessageDTO.builder()
                .roomId(confirmedSchedule.getRoomId())
                .messageType("SCHEDULE_CONFIRMED")
                .message(confirmedSchedule.getTitle() + " 일정이 확정되었습니다.")
                .sentAt(LocalDateTime.now())
                .build();

        messagingTemplate.convertAndSend("/topic/chatroom/" + confirmedSchedule.getRoomId(), noticeMessage);

        return ResponseEntity.ok("일정을 수락했습니다.");
    }


    @PostMapping("/api/events/{scheduleId}/reject")
    @ResponseBody
    public ResponseEntity<String> rejectSchedule(@PathVariable("scheduleId") int scheduleId) {
        log.info("rejectSchedule for ID: {}", scheduleId);

        scheduleService.updateScheduleStatus(scheduleId, "REJECTED");

        return ResponseEntity.ok("일정을 거절했습니다.");
    }


    @GetMapping("scheduleReg")
    public String scheduleReg() {
        log.info("{}.scheduleReg Start!", this.getClass().getName());

        return "schedule/scheduleReg";
    }
}
