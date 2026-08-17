package com.nextcalendar.dto.login_register;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import com.nextcalendar.entity.UserRole;

import java.time.LocalDate;

public record RegisterRequestDTO(
        @NotBlank(message = "Nome é obrigatório")
        String name,

        @NotBlank(message = "Email é obrigatório")
        @Email(message = "Email inválido")
        String email,

        @NotBlank(message = "Senha é obrigatória")
        @Size(min = 6, message = "Senha deve ter no mínimo 6 caracteres")
        String password,

        @NotNull(message = "O tipo de usuário é obrigatório")
        UserRole role,

        // Campos opcionais para criação de Empresa
        // Dados usados no cadastro de estabelecimento
        String cnpj,
        @NotBlank(message = "Telefone é obrigatório")
        String phone,
        String whatsapp,
        String cep,
        String street,
        String number,
        String complement,
        String city,
        String neighborhood,
        String state,

        // Dados específicos do cliente
        LocalDate dateOfBirth,
        String photoUrl,
        String notes
) {}
