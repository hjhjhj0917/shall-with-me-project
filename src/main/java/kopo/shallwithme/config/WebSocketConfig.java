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
        // [수정] 모든 웹소켓 연결은 /ws 주소 하나만 사용하도록 통일합니다.
        registry.addEndpoint("/ws").setAllowedOriginPatterns("*").withSockJS();
    }
}
