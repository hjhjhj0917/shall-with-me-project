package kopo.shallwithme.config;

import kopo.shallwithme.interceptor.AuthInterceptor;
import kopo.shallwithme.interceptor.MyPageAuthInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new AuthInterceptor())
                .addPathPatterns("/user/roommateMain", "/user/sharehouseMain", "/chat/**", "/user/userTagSelect",
                        "/user/mypage/**", "/roommate/**", "/sharehouse/**", "/mypage/**") // 로그인 필요 경로
                .excludePathPatterns("/user/login", "/user/loginProc", "/user/userRegForm", "/user/insertUserInfo"); // 로그인 제외

        registry.addInterceptor(new MyPageAuthInterceptor())
                .addPathPatterns("/mypage/userModify", "/mypage/sharehouseModify", "/mypage/scheduleCheck", "/mypage/withdraw") // 이 주소들에만 적용
                .excludePathPatterns("/mypage/myPagePwCheck"); // 비밀번호 확인 페이지 자체는 제외 (무한 루프 방지)
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 정적 리소스(css, js 등) 무시 처리 (필요 시)
        registry.addResourceHandler("/**")
                .addResourceLocations("classpath:/static/");
    }
}
