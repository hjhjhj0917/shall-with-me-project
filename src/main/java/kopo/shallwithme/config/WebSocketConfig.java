package kopo.shallwithme.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.*;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic"); // 구독용
        config.setApplicationDestinationPrefixes("/app"); // 메시지 보낼 때 prefix
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 채팅방 페이지에서 사용하는 엔드포인트
        registry.addEndpoint("/ws-chat").setAllowedOriginPatterns("*").withSockJS();

        // 채팅 목록 페이지에서 사용하는 엔드포인트
        registry.addEndpoint("/ws").setAllowedOriginPatterns("*").withSockJS();
    }
}
