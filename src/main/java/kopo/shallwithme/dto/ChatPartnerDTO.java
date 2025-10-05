package kopo.shallwithme.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChatPartnerDTO {
    private String userId;
    private String userName;
    private String profileImgUrl; // 프로필 이미지 경로
    private String lastMessage; // 마지막 메시지
    private String lastMessageTimestamp;

    private int unreadCount;
}
