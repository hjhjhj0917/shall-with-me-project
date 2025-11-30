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

        Boolean isVerified = (Boolean) session.getAttribute("SS_PASSWORD_CHK");

        if (Boolean.TRUE.equals(isVerified)) {
            log.info("Mypage access verified. Allowing access.");
            return true;

        } else {
            log.info("Mypage access NOT verified. Redirecting to password check page.");

            String targetUrl = request.getRequestURI();
            session.setAttribute("MYPAGE_TARGET_URL", targetUrl);

            response.sendRedirect("/mypage/myPagePwCheck");
            return false;
        }
    }
}
