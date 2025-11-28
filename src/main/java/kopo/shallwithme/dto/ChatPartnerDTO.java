package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChatPartnerDTO {
    private String userId;
    private String userName;
    private String profileImgUrl;
    private String lastMessage;
    private String lastMessageTimestamp;

    private int unreadCount;
}
