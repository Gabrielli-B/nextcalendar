package com.nextcalendar.exception;

/**
 * Lançada quando um CEP tem formato inválido ou não é encontrado na API ViaCEP.
 * Mapeada para HTTP 422 Unprocessable Entity.
 */
public class CepInvalidException extends RuntimeException {
    public CepInvalidException(String message) {
        super(message);
    }
}
