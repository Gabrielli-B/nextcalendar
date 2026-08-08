package com.nextcalendar.dto.establishment;

import com.nextcalendar.dto.address.AddressCreateDTO;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

import java.util.UUID;

/**
 * DTO para criação de estabelecimento — UC01.
 */
public record EstablishmentCreateDTO(

        @NotNull(message = "ownerId é obrigatório")
        UUID ownerId,

        @NotBlank(message = "Razão social é obrigatória")
        String legalName,

        @NotBlank(message = "Nome fantasia é obrigatório")
        String name,

        @NotBlank(message = "CNPJ é obrigatório")
        String cnpj,

        @NotBlank(message = "Telefone é obrigatório")
        String phone,

        String whatsapp,

        @NotBlank(message = "E-mail é obrigatório")
        @Email(message = "E-mail inválido")
        String email,

        String businessType,

        @NotNull(message = "Endereço é obrigatório")
        @Valid
        AddressCreateDTO address,

        /**
         * UC01 — Pré-condição: termos devem ser aceitos para persistir.
         * @AssertTrue garante que o valor seja true (não apenas não-nulo).
         */
        @NotNull(message = "É necessário aceitar os termos de uso")
        @AssertTrue(message = "Os termos de uso devem ser aceitos para criar o estabelecimento")
        Boolean termsAccepted
) {}
