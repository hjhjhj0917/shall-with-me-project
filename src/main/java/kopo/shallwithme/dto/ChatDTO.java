package kopo.shallwithme.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChatDTO {
    private String roomId;
    private String senderId;
    private String message;
    private String sentAt; // DB에서 불러올 때 사용됨
}
