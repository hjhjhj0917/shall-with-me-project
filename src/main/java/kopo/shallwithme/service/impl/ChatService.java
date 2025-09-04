package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.*;
import kopo.shallwithme.mapper.IChatMapper;
import kopo.shallwithme.service.IChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class ChatService implements IChatService {

    private final IChatMapper chatMapper;

    @Override
    public void saveMessage(ChatMessageDTO pDTO) {

        log.info("{}.saveMessage Start!", this.getClass().getName());

        try {
            chatMapper.insertChatMessage(pDTO);
        } catch (Exception e) {
            log.error("메시지 전송 및 저장 중 오류 발생 : {}", pDTO.toString(), e);
        }

        log.info("{}.saveMessage End!", this.getClass().getName());
    }

    @Override
    public ChatRoomDTO getOtherUserId(ChatRoomDTO pDTO) {

        log.info("{}.getOtherUserId Start!", this.getClass().getName());

        ChatRoomDTO rDTO = chatMapper.getOtherUserId(pDTO);

        log.info("{}.getOtherUserId End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    public UserProfileDTO getImageUrlByUserId(ChatRoomDTO pDTO) {

        log.info("{}.getImageUrlByUserId Start!", this.getClass().getName());

        UserProfileDTO rDTO = chatMapper.selectProfileImageUrlByUserId(pDTO);

        log.info("{}.getImageUrlByUserId end!", this.getClass().getName());

        return rDTO;
    }

    @Override
    public int createRoom(ChatRoomDTO pDTO) { // user1Id와 user2Id가 담긴 pDTO를 받음

        log.info("{}.createRoom Start!", this.getClass().getName());

        try {
            chatMapper.createChatRoom(pDTO);
        } catch (Exception e) {
            log.error("채팅방 생성 중 오류 발생 : {}", pDTO.toString(), e);
        }

        log.info("{}.createRoom End!", this.getClass().getName());

        return pDTO.getRoomId();
    }

    @Override
    public List<ChatRoomDTO> getRoomsByUserId(UserInfoDTO pDTO) {

        log.info("{}.createRoom Start!", this.getClass().getName());

        List<ChatRoomDTO> rList = chatMapper.getRoomsByUserId(pDTO);

        log.info("{}.createRoom End!", this.getClass().getName());

        return rList;
    }

    // 메세지 주고받은 유저만 불러오기
    @Override
    public List<ChatPartnerDTO> getChatPartners(UserInfoDTO pDTO) {

        log.info("{}.getChatPartners Start!", this.getClass().getName());

        List<ChatPartnerDTO> rList = chatMapper.selectChatPartnersWithLastMsg(pDTO);

        log.info("{}.getChatPartners End!", this.getClass().getName());

        return rList; // 새 매퍼 메소드 호출
    }

    @Override
    public List<UserInfoDTO> getUserList() throws Exception {

        log.info("{}.getUserList Start!", this.getClass().getName());

        List<UserInfoDTO> rList = chatMapper.selectUserList();

        log.info("{}.getUserList End!", this.getClass().getName());

        return rList;
    }

    // 채팅방을 새로 생성할지 기존 채팅방을 불러오는지 판단
    @Override
    public int createOrGetChatRoom(ChatRoomDTO pDTO) throws Exception {

        log.info("{}.createOrGetChatRoom Start!", this.getClass().getName());

        // DTO에서 사용자 ID들을 가져옴
        String user1Id = pDTO.getUser1Id();
        String user2Id = pDTO.getUser2Id();
        log.info("user1Id={}, user2Id={}", user1Id, user2Id);

        // 오름차순 정렬
        String firstUser = user1Id.compareTo(user2Id) < 0 ? user1Id : user2Id;
        String secondUser = user1Id.compareTo(user2Id) < 0 ? user2Id : user1Id;
        log.info("정렬된 유저 순서: {}, {}", firstUser, secondUser);

        // 정렬된 ID를 Mapper에 전달할 DTO에 다시 설정
        ChatRoomDTO dtoForFind = new ChatRoomDTO();
        dtoForFind.setUser1Id(firstUser);
        dtoForFind.setUser2Id(secondUser);

        ChatRoomDTO rDTO = chatMapper.findRoomIdByUsers(dtoForFind);

        if (rDTO != null) {
            log.info("기존 채팅방 존재: roomId={}", rDTO.getRoomId());

            log.info("{}.createOrGetChatRoom End!", this.getClass().getName());

            return rDTO.getRoomId();
        }

        log.info("채팅방 존재하지 않음 → 새로 생성 시도");

        try {
            chatMapper.insertChatRoom(dtoForFind);
        } catch (Exception e) {
            log.error("새 채팅방 생성 중 오류 발생 : {}", pDTO.toString(), e);
        }

        Integer newRoomId = dtoForFind.getRoomId();
        log.info("채팅방 생성 후 roomId={}", newRoomId);

        log.info("{}.createOrGetChatRoom End!", this.getClass().getName());

        return newRoomId;
    }

    @Override
    public List<ChatMessageDTO> getMessagesByRoomId(Integer roomId) {

        log.info("{}.getMessagesByRoomId Start!", this.getClass().getName());

        List<ChatMessageDTO> rList = chatMapper.selectMessagesByRoomId(roomId);

        log.info("{}.getMessagesByRoomId End!", this.getClass().getName());

        return rList;
    }

}
