package kopo.shallwithme.service;

import kopo.shallwithme.dto.ChatDTO;
import kopo.shallwithme.dto.ChatPartnerDTO;
import kopo.shallwithme.dto.ChatRoomDTO;
import kopo.shallwithme.dto.UserInfoDTO;

import java.util.List;

public interface IChatService {

    void saveMessage(ChatDTO pDTO);

    List<ChatDTO> getMessages(String roomId);

    int createRoom(ChatRoomDTO pDTO);

    List<ChatRoomDTO> getRoomsByUserId(String userId);

    List<UserInfoDTO> getUserList() throws Exception;

    int createOrGetChatRoom(String user1Id, String user2Id) throws Exception;

    List<ChatDTO> getMessagesByRoomId(Integer roomId);

    // 메세지 주고받은 유저만 불러오기
    List<ChatPartnerDTO> getChatPartners(UserInfoDTO pDTO) throws Exception;

}
