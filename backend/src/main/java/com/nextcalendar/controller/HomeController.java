package com.nextcalendar.controller;

import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

/**
 * Redireciona a raiz "/" e "/api/v1/" para o Swagger UI.
 */
@RestController
public class HomeController {

    @GetMapping({"/", "/api/v1", "/api/v1/"})
    public void home(HttpServletResponse response) throws IOException {
        response.sendRedirect("/swagger-ui/index.html");
    }
}
