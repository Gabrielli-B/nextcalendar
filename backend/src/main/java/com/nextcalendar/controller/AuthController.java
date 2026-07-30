package com.nextcalendar.controller;

import com.nextcalendar.dto.LoginRequestDTO;
import com.nextcalendar.dto.LoginResponseDTO;
import com.nextcalendar.dto.RegisterRequestDTO;
import com.nextcalendar.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * POST /api/v1/auth/login
     *
     * Body: { "email": "...", "password": "..." }
     * Retorna: { "token": "eyJ...", "user": { "id", "name", "email" } }
     *
     * Erros:
     *   400 — Email ou senha inválidos
     *   422 — Campos obrigatórios ausentes ou mal formatados
     */
    @PostMapping("/login")
    public LoginResponseDTO login(@Valid @RequestBody LoginRequestDTO dto) {
        return authService.login(dto);
    }

    /**
     * POST /api/v1/auth/register
     *
     * Body: { "name": "...", "email": "...", "password": "..." }
     * Retorna: { "token": "eyJ...", "user": { "id", "name", "email" } }
     *
     * Erros:
     *   409 — Email já cadastrado
     *   422 — Campos inválidos
     */
    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public LoginResponseDTO register(@Valid @RequestBody RegisterRequestDTO dto) {
        return authService.register(dto);
    }
}
