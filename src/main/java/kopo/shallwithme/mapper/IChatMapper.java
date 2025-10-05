package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

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

    // 메세지 주고받은 유저만 불러오기
    List<ChatPartnerDTO> selectChatPartnersWithLastMsg(UserInfoDTO pDTO);

    // 채팅방 상대 프로필 이미지 불러오기
    UserProfileDTO selectProfileImageUrlByUserId(ChatRoomDTO pDTO);

    void incrementUnreadCount(ChatMessageDTO pDTO) throws Exception;


    void updateMessageReadStatus(@Param("roomId") String roomId, @Param("readerId") String readerId) throws Exception;

    void resetUnreadCount(@Param("roomId") String roomId, @Param("readerId") String readerId) throws Exception;

}

