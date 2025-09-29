package kopo.shallwithme.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        // 1. 요청에서 에러 상태 코드를 가져옵니다.
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);

        if (status != null) {
            int statusCode = Integer.parseInt(status.toString());

            // 2. 만약 상태 코드가 404 (NOT_FOUND)라면
            if (statusCode == HttpStatus.NOT_FOUND.value()) {
                // 3. 우리가 만든 404.jsp 페이지를 보여줍니다.
                return "error/notFound";
            }

            // 404 외의 다른 에러(500 등)가 발생한 경우
            model.addAttribute("errorCode", statusCode);
            return "error/genericError"; // 다른 에러들을 위한 공통 에러 페이지 (선택 사항)
        }

        // 상태 코드가 없는 경우 일반 에러 페이지로
        return "error/genericError";
    }
}
