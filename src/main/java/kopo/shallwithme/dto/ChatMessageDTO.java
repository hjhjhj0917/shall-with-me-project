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

    private String messageType;
    private ScheduleDTO schedule;

    private ScheduleDTO scheduleRequest;
    private String readerId;
    private boolean read;
}
