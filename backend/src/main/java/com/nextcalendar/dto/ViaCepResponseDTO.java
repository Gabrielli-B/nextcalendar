package com.nextcalendar.dto;

/**
 * Resposta da API ViaCEP.
 * Quando o CEP não é encontrado, a API retorna {"erro": "true"} (String, não boolean).
 */
public record ViaCepResponseDTO(
        String cep,
        String logradouro,
        String complemento,
        String bairro,
        String localidade,
        String uf,
        String erro          // "true" (String) quando CEP não encontrado
) {}
