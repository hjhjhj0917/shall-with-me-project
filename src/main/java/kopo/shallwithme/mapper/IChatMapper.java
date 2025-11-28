package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface IChatMapper {

    void insertChatMessage(ChatMessageDTO pDTO);

    ChatRoomDTO getOtherUserId(ChatRoomDTO pDTO);

    void createChatRoom(ChatRoomDTO pDTO);

    List<ChatRoomDTO> getRoomsByUserId(UserInfoDTO pDTO);

    List<UserInfoDTO> selectUserList() throws Exception;

    ChatRoomDTO findRoomIdByUsers(ChatRoomDTO pDTO) throws Exception;

    void insertChatRoom(ChatRoomDTO pDTO) throws Exception;

    List<ChatMessageDTO> selectMessagesByRoomId(Integer roomId);

    List<ChatPartnerDTO> selectChatPartnersWithLastMsg(UserInfoDTO pDTO);

    UserProfileDTO selectProfileImageUrlByUserId(ChatRoomDTO pDTO);

    void incrementUnreadCount(ChatMessageDTO pDTO) throws Exception;

    void updateMessageReadStatus(@Param("roomId") String roomId, @Param("readerId") String readerId) throws Exception;

    void resetUnreadCount(@Param("roomId") String roomId, @Param("readerId") String readerId) throws Exception;

    int getTotalUnreadCount(String userId) throws Exception;

}

