package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.ChatDTO;
import kopo.shallwithme.dto.ChatPartnerDTO;
import kopo.shallwithme.dto.ChatRoomDTO;
import kopo.shallwithme.dto.UserInfoDTO;
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
    public void saveMessage(ChatDTO pDTO) {

        chatMapper.insertChatMessage(pDTO);
    }

    @Override
    public List<ChatDTO> getMessages(String roomId) {
        return chatMapper.selectChatMessages(roomId);
    }

    @Override
    public int createRoom(String user1Id, String user2Id) {

        log.info("{}.createRoom Start!", this.getClass().getName());

        ChatRoomDTO roomDTO = new ChatRoomDTO();
        roomDTO.setUser1Id(user1Id);
        roomDTO.setUser2Id(user2Id);
        chatMapper.createChatRoom(roomDTO);

        log.info("{}.createRoom End!", this.getClass().getName());

        return roomDTO.getRoomId(); // 생성된 roomId 리턴
    }

    @Override
    public List<ChatRoomDTO> getRoomsByUserId(String userId) {

        return chatMapper.getRoomsByUserId(userId);
    }

    // 메세지 주고받은 유저만 불러오기
    @Override
    public List<ChatPartnerDTO> getChatPartners(UserInfoDTO pDTO) throws Exception {

        log.info(this.getClass().getName() + ".getChatPartners Start!");

        return chatMapper.selectChatPartnersWithLastMsg(pDTO); // 새 매퍼 메소드 호출
    }

    @Override
    public List<UserInfoDTO> getUserList() throws Exception {

        return chatMapper.selectUserList();
    }

    @Override
    public int createOrGetChatRoom(String user1Id, String user2Id) throws Exception {

        log.info("{}.createOrGetChatRoom Start!", this.getClass().getName());

        log.info("user1Id={}, user2Id={}", user1Id, user2Id);

        // 오름차순 정렬
        String firstUser = user1Id.compareTo(user2Id) < 0 ? user1Id : user2Id;
        String secondUser = user1Id.compareTo(user2Id) < 0 ? user2Id : user1Id;

        log.info("정렬된 유저 순서: {}, {}", firstUser, secondUser);

        ChatRoomDTO dto = new ChatRoomDTO();
        dto.setUser1Id(firstUser);
        dto.setUser2Id(secondUser);

        Integer roomId = chatMapper.findRoomIdByUsers(dto);
        if (roomId != null) {
            log.info("기존 채팅방 존재: roomId={}", roomId);
            return roomId;
        }

        log.info("📦 채팅방 존재하지 않음 → 새로 생성 시도");
        chatMapper.insertChatRoom(dto);

        Integer newRoomId = chatMapper.findRoomIdByUsers(dto);
        log.info("채팅방 생성 후 roomId={}", newRoomId);

        log.info("{}.createOrGetChatRoom End!", this.getClass().getName());

        return newRoomId;
    }

    @Override
    public List<ChatDTO> getMessagesByRoomId(Integer roomId) {

        return chatMapper.selectMessagesByRoomId(roomId);
    }

}
