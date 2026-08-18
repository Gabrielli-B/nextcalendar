package com.nextcalendar.service;

import com.nextcalendar.entity.EstablishmentEntity;
import com.nextcalendar.repository.EstablishmentRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * UC05 — Scheduler automático de verificação do trial.
 *
 * Roda todos os dias às 08:00 e:
 *  - Loga/notifica estabelecimentos com trial expirando em até 7 dias
 *  - Loga/notifica estabelecimentos com trial já expirado
 *
 * Ponto de extensão: substituir os logs por chamadas ao serviço de e-mail
 * quando o módulo de notificações for implementado.
 */
@Service
public class TrialSchedulerService {

    private static final Logger log = LoggerFactory.getLogger(TrialSchedulerService.class);
    private static final int WARNING_DAYS = 7;

    private final EstablishmentRepository establishmentRepository;

    public TrialSchedulerService(EstablishmentRepository establishmentRepository) {
        this.establishmentRepository = establishmentRepository;
    }

    /**
     * UC05 — Executa diariamente às 08:00.
     * Cron: segundo minuto hora dia mês dia-semana
     */
    @Scheduled(cron = "0 0 8 * * *")
    public void verificarStatusTrial() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime warningThreshold = now.plusDays(WARNING_DAYS);

        // UC05 passo 3 — Trial expirando em <= 7 dias → notificação de aviso
        List<EstablishmentEntity> proximosDoVencimento =
                establishmentRepository.findByTrialEndDateBetweenAndActiveTrue(now, warningThreshold);

        proximosDoVencimento.forEach(e -> {
            long diasRestantes = java.time.temporal.ChronoUnit.DAYS.between(now, e.getTrialEndDate());
            log.warn("[TRIAL-AVISO] Estabelecimento '{}' (id={}) expira em {} dia(s). Enviar notificação de aviso.",
                    e.getName(), e.getId(), diasRestantes);
            log.info("[TRIAL-AVISO] Notificação pendente para '{}' (id={}) — {} dia(s) restante(s). Implementar notificationService.sendTrialWarning().",
                    e.getName(), e.getId(), diasRestantes);
        });

        // UC05 passo 4a — Trial expirado → bloquear funcionalidades premium + e-mail upgrade
        List<EstablishmentEntity> expirados =
                establishmentRepository.findByTrialEndDateBeforeAndActiveTrue(now);

        expirados.forEach(e -> {
            log.warn("[TRIAL-EXPIRADO] Estabelecimento '{}' (id={}) com trial vencido desde {}. Enviar e-mail de upgrade.",
                    e.getName(), e.getId(), e.getTrialEndDate());
            log.info("[TRIAL-EXPIRADO] E-mail de upgrade pendente para '{}' (id={}). Implementar notificationService.sendTrialExpiredUpgradeEmail().",
                    e.getName(), e.getId());
        });

        log.info("[TRIAL-CHECK] Verificação concluída: {} aviso(s), {} expirado(s).",
                proximosDoVencimento.size(), expirados.size());
    }
}
