package kopo.shallwithme.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {

        log.info("{}.handleError Start!", this.getClass().getName());

        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);

        if (status != null) {
            int statusCode = Integer.parseInt(status.toString());

            if (statusCode == HttpStatus.NOT_FOUND.value()) {

                log.info("{}.handleError End!", this.getClass().getName());

                return "error/notFound";
            }

            model.addAttribute("errorCode", statusCode);

            log.info("{}.handleError End!", this.getClass().getName());

            return "error/genericError";
        }

        log.info("{}.handleError End!", this.getClass().getName());

        return "error/genericError";
    }
}
