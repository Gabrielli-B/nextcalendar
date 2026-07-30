package com.nextcalendar.service;

import com.nextcalendar.dto.ViaCepResponseDTO;
import com.nextcalendar.entity.AddressEmbeddable;
import com.nextcalendar.exception.CepInvalidException;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

/**
 * Serviço responsável por consultar a API pública ViaCEP.
 *
 * UC01 — Fluxos:
 *   6a: CEP inválido → lança CepInvalidException (HTTP 422)
 *   6b: API indisponível → retorna null, permitindo preenchimento manual
 */
@Service
public class ViaCepService {

    private final RestClient restClient = RestClient.builder()
            .baseUrl("https://viacep.com.br")
            .build();

    /**
     * Consulta o ViaCEP e retorna um AddressEmbeddable preenchido.
     *
     * @param cep    CEP informado pelo usuário (com ou sem formatação)
     * @param number Número complementado pelo usuário
     * @param complement Complemento informado pelo usuário
     * @return AddressEmbeddable com dados do ViaCEP + número/complemento do usuário
     * @throws CepInvalidException se o CEP tiver formato inválido ou não for encontrado (UC01 6a)
     */
    public AddressEmbeddable buscarEPreencherEndereco(String cep, String number, String complement) {
        String cepNormalizado = normalizarCep(cep);

        ViaCepResponseDTO resposta = consultarApi(cepNormalizado);

        // UC01 6b: API indisponível — retorna null para que o serviço use os dados manuais
        if (resposta == null) {
            return null;
        }

        // UC01 6a: CEP não encontrado → 422
        if ("true".equalsIgnoreCase(resposta.erro())) {
            throw new CepInvalidException("CEP não encontrado: " + cep);
        }

        return new AddressEmbeddable(
                cepNormalizado,
                resposta.logradouro(),
                number,
                complement,
                resposta.bairro(),
                resposta.localidade(),
                resposta.uf()
        );
    }

    /**
     * Consulta apenas os dados do CEP, sem montar o endereço completo.
     * Usado pelo endpoint auxiliar GET /api/v1/cep/{cep}.
     */
    public ViaCepResponseDTO consultar(String cep) {
        String cepNormalizado = normalizarCep(cep);
        ViaCepResponseDTO resposta = consultarApi(cepNormalizado);

        if (resposta == null) {
            throw new CepInvalidException("Serviço de CEP indisponível no momento. Preencha o endereço manualmente.");
        }
        if ("true".equalsIgnoreCase(resposta.erro())) {
            throw new CepInvalidException("CEP não encontrado: " + cep);
        }
        return resposta;
    }

    // ------------------------------------------------------------------ privado

    private String normalizarCep(String cep) {
        if (cep == null) throw new CepInvalidException("CEP não pode ser nulo");
        String normalizado = cep.replaceAll("[^0-9]", "");
        if (normalizado.length() != 8) {
            throw new CepInvalidException("CEP inválido — deve conter 8 dígitos: " + cep);
        }
        return normalizado;
    }

    /**
     * Faz a chamada HTTP ao ViaCEP.
     * Em caso de falha de rede (UC01 6b), retorna null em vez de propagar exceção.
     */
    private ViaCepResponseDTO consultarApi(String cepNormalizado) {
        try {
            return restClient.get()
                    .uri("/ws/{cep}/json/", cepNormalizado)
                    .retrieve()
                    .body(ViaCepResponseDTO.class);
        } catch (RestClientException e) {
            // UC01 6b: API indisponível → retorna null para que o chamador decida
            return null;
        }
    }
}
