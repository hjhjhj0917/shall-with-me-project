package kopo.shallwithme.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDTO {
    private String roomId;
    private String senderId;
    private String message;
    private String sentAt; // 시간 타입 LocalDateTime으로 변경하기
    private String timestamp;
}
