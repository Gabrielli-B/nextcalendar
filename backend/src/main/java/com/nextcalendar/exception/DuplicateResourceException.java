package com.nextcalendar.exception;

/**
 * Lançada quando um recurso único (ex: CNPJ) já está cadastrado.
 * Mapeada para HTTP 409 Conflict.
 */
public class DuplicateResourceException extends RuntimeException {
    public DuplicateResourceException(String message) {
        super(message);
    }
}
