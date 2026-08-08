package com.nextcalendar.dto.address;

/**
 * Sub-DTO de endereço para atualização parcial.
 * Todos os campos são opcionais — apenas os não-nulos são aplicados.
 * Se o CEP mudar, o sistema re-consulta o ViaCEP automaticamente.
 */
public record AddressUpdateDTO(
        String cep,
        String number,
        String complement,
        // Fallback manual (UC01 fluxo 6b)
        String street,
        String neighborhood,
        String city,
        String state
) {}
