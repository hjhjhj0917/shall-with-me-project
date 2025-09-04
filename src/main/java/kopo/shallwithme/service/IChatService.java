package kopo.shallwithme.service;

import kopo.shallwithme.dto.*;

import java.util.List;

public interface IChatService {

    // 채팅 내용을 저장
    void saveMessage(ChatMessageDTO pDTO);

    ChatRoomDTO getOtherUserId(ChatRoomDTO pDTO);

    // 채팅방 생성
    int createRoom(ChatRoomDTO pDTO);

    // 회원 채팅방 조회
    List<ChatRoomDTO> getRoomsByUserId(UserInfoDTO pDTO);

    // 회원 정보 불러오기 (삭제 해야함!)
    List<UserInfoDTO> getUserList() throws Exception;

    // 채팅방을 생성할지 기존 채팅방을 불러올지 판단
    int createOrGetChatRoom(ChatRoomDTO pDTO) throws Exception;

    // 채팅방에 기존 메시지를 불러옴
    List<ChatMessageDTO> getMessagesByRoomId(Integer roomId);

    // 메세지 주고받은 유저만 불러옴
    List<ChatPartnerDTO> getChatPartners(UserInfoDTO pDTO) throws Exception;

    // 채팅방 상대 프로필 이미지 불러오기
    UserProfileDTO getImageUrlByUserId(ChatRoomDTO pDTO) throws Exception;

}
