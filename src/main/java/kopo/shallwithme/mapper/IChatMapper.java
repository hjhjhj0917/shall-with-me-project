package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.ChatDTO;
import kopo.shallwithme.dto.ChatRoomDTO;
import kopo.shallwithme.dto.UserInfoDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface IChatMapper {

    void insertChatMessage(ChatDTO pDTO);

    List<ChatDTO> selectChatMessages(String roomId);

    void createChatRoom(ChatRoomDTO pDTO);

    List<ChatRoomDTO> getRoomsByUserId(String userId);

    List<UserInfoDTO> selectUserList() throws Exception;

    Integer findRoomIdByUsers(ChatRoomDTO chatRoomDTO) throws Exception;

    void insertChatRoom(ChatRoomDTO chatRoomDTO) throws Exception;

    List<ChatDTO> selectMessagesByRoomId(Integer roomId);
}
