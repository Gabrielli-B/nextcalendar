package com.nextcalendar.service;

import com.nextcalendar.dto.LoginRequestDTO;
import com.nextcalendar.dto.LoginResponseDTO;
import com.nextcalendar.dto.RegisterRequestDTO;
import com.nextcalendar.entity.UserEntity;
import com.nextcalendar.exception.BusinessException;
import com.nextcalendar.exception.DuplicateResourceException;
import com.nextcalendar.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService,
                       EmailService emailService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.emailService = emailService;
    }

    // ─── Login ────────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public LoginResponseDTO login(LoginRequestDTO dto) {
        UserEntity user = userRepository.findByEmail(dto.email())
                .orElseThrow(() -> new BusinessException("Email ou senha inválidos"));

        if (!user.getActive()) {
            throw new BusinessException("Conta desativada. Entre em contato com o suporte.");
        }

        if (!passwordEncoder.matches(dto.password(), user.getPasswordHash())) {
            throw new BusinessException("Email ou senha inválidos");
        }

        String token = jwtService.generateToken(user.getId(), user.getEmail());

        return new LoginResponseDTO(
                token,
                new LoginResponseDTO.UserInfoDTO(user.getId(), user.getName(), user.getEmail())
        );
    }

    // ─── Cadastro ─────────────────────────────────────────────────────────────

    @Transactional
    public LoginResponseDTO register(RegisterRequestDTO dto) {
        if (userRepository.existsByEmail(dto.email())) {
            throw new DuplicateResourceException(
                    "Email '" + dto.email() + "' já está cadastrado.");
        }

        UserEntity user = new UserEntity();
        user.setName(dto.name());
        user.setEmail(dto.email());
        user.setPasswordHash(passwordEncoder.encode(dto.password()));
        user.setRole(dto.role());
        user.setActive(true);

        UserEntity saved = userRepository.save(user);
        
        emailService.sendConfirmationEmail(saved.getEmail(), saved.getName());

        String token = jwtService.generateToken(saved.getId(), saved.getEmail());

        return new LoginResponseDTO(
                token,
                new LoginResponseDTO.UserInfoDTO(saved.getId(), saved.getName(), saved.getEmail())
        );
    }
}
