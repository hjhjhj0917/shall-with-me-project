package kopo.shallwithme.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessageDTO {
    private String messageId;
    private String roomId;
    private String senderId;
    private String message;
    private LocalDateTime sentAt;

    private String messageType; // "TEXT", "SCHEDULE", 등
    private ScheduleDTO schedule; // 일정 메시지인 경우 일정 정보 포함

    private ScheduleDTO scheduleRequest;
}
