package kopo.shallwithme.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDTO {
    private String messageId;
    private String roomId;
    private String senderId;
    private String message;
    private LocalDateTime sentAt;
}
