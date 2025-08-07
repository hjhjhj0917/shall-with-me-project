package kopo.shallwithme.service;

import kopo.shallwithme.dto.ChatDTO;
import kopo.shallwithme.dto.ChatRoomDTO;
import kopo.shallwithme.dto.UserInfoDTO;

import java.util.List;

public interface IChatService {

    void saveMessage(ChatDTO dto);

    List<ChatDTO> getMessages(String roomId);

    int createRoom(String user1Id, String user2Id);

    List<ChatRoomDTO> getRoomsByUserId(String userId);

    List<UserInfoDTO> getUserList() throws Exception;

    int createOrGetChatRoom(String user1Id, String user2Id) throws Exception;

    List<ChatDTO> getMessagesByRoomId(Integer roomId);

}
