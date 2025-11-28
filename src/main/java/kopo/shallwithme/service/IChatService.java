package kopo.shallwithme.service;

import kopo.shallwithme.dto.*;

import java.util.List;

public interface IChatService {

    ChatMessageDTO saveMessage(ChatMessageDTO pDTO) throws Exception;

    ChatRoomDTO getOtherUserId(ChatRoomDTO pDTO);

    int createRoom(ChatRoomDTO pDTO);

    List<ChatRoomDTO> getRoomsByUserId(UserInfoDTO pDTO);

    List<UserInfoDTO> getUserList() throws Exception;

    int createOrGetChatRoom(ChatRoomDTO pDTO) throws Exception;

    List<ChatMessageDTO> getMessagesByRoomId(Integer roomId);

    List<ChatPartnerDTO> getChatPartners(UserInfoDTO pDTO) throws Exception;

    UserProfileDTO getImageUrlByUserId(ChatRoomDTO pDTO) throws Exception;

    void updateReadStatus(String roomId, String readerId) throws Exception;

    int getTotalUnreadCount(String userId) throws Exception;
}
