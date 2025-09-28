package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChatRoomDTO {
    private Integer roomId;
    private String user1Id;
    private String user2Id;

    private String myUserId;
}
