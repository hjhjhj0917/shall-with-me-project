package kopo.shallwithme.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Slf4j
@Component
public class MyPageAuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        log.info(this.getClass().getName() + ".preHandle Start!");

        HttpSession session = request.getSession();

        // 1. 비밀번호 인증을 마쳤는지 세션에서 확인
        Boolean isVerified = (Boolean) session.getAttribute("SS_PASSWORD_CHK");

        if (Boolean.TRUE.equals(isVerified)) {
            // 2. 인증을 마쳤다면, 그대로 요청을 통과시킴
            log.info("Mypage access verified. Allowing access.");
            return true;

        } else {
            // 3. 인증을 마치지 않았다면, 비밀번호 확인 페이지로 리다이렉트
            log.info("Mypage access NOT verified. Redirecting to password check page.");

            // [핵심] 원래 가려던 목적지 주소를 세션에 저장
            String targetUrl = request.getRequestURI();
            session.setAttribute("MYPAGE_TARGET_URL", targetUrl);

            // 비밀번호 확인 페이지로 강제 이동 (리다이렉트)
            response.sendRedirect("/mypage/myPagePwCheck");
            return false; // 원래 요청은 중단
        }
    }
}
