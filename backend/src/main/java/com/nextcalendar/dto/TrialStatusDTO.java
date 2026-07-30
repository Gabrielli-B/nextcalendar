package com.nextcalendar.dto;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Resposta do UC05 — Verificar Status do Trial.
 * trialActive e trialExpired são calculados dinamicamente no serviço.
 */
public record TrialStatusDTO(
        UUID establishmentId,
        LocalDateTime trialStartDate,
        LocalDateTime trialEndDate,
        long daysRemaining,
        boolean trialActive,
        boolean warningActive,    // true quando daysRemaining <= 7
        boolean trialExpired
) {}
