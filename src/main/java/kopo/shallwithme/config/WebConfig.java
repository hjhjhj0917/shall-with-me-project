package kopo.shallwithme.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 로컬 폴더 "uploads/" 를 "/uploads/**" 로 노출
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:uploads/");
    }
}