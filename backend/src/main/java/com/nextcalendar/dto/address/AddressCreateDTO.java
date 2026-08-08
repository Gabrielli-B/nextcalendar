package com.nextcalendar.dto.address;

import jakarta.validation.constraints.NotBlank;

/**
 * Sub-DTO de endereço para criação de estabelecimento.
 *
 * O sistema tenta preencher rua/bairro/cidade/estado via ViaCEP.
 * Os campos opcionais (street, neighborhood, city, state) são usados como
 * fallback manual quando a API de CEP estiver indisponível (UC01 fluxo 6b).
 */
public record AddressCreateDTO(

        @NotBlank(message = "CEP é obrigatório")
        String cep,

        @NotBlank(message = "Número é obrigatório")
        String number,

        String complement,

        // UC01 — Fluxo 6b: preenchimento manual quando API indisponível
        String street,
        String neighborhood,
        String city,
        String state
) {}
