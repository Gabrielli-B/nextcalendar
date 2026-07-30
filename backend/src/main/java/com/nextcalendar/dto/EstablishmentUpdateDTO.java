package com.nextcalendar.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;

/**
 * DTO para atualização parcial do estabelecimento (tela Empresa — botão Salvar).
 * Todos os campos são opcionais; apenas os não-nulos são aplicados.
 */
public record EstablishmentUpdateDTO(
        String legalName,
        String name,
        String phone,
        String whatsapp,
        @Email(message = "E-mail inválido")
        String email,
        String businessType,
        String logoUrl,
        @Valid
        AddressUpdateDTO address
) {}
