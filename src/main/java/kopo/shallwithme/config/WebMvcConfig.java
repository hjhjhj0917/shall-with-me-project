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
                        "/roommate/**", "/sharehouse/**", "/mypage/**", "/schedule/**", "/notice/**")
                .excludePathPatterns("/user/login", "/user/loginProc", "/user/userRegForm", "/user/insertUserInfo");

        registry.addInterceptor(new MyPageAuthInterceptor())
                .addPathPatterns("/mypage/userModify", "/mypage/sharehouseModify", "/mypage/scheduleCheck", "/mypage/withdraw")
                .excludePathPatterns("/mypage/myPagePwCheck");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/**")
                .addResourceLocations("classpath:/static/");
    }
}
