package com.nextcalendar.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    public void sendConfirmationEmail(String toEmail, String userName) {
        // Como o usuário escolheu o modo Simulação, vamos apenas imprimir no terminal
        logger.info("\n\n=======================================================");
        logger.info("EMAIL DE CONFIRMAÇÃO ENVIADO");
        logger.info("=======================================================");
        logger.info("Para: {}", toEmail);
        logger.info("Assunto: Bem-vindo ao nextCalendar, {}!", userName);
        logger.info("Corpo:");
        logger.info("Olá, {}! Sua conta foi criada com sucesso.", userName);
        logger.info("Por favor, acesse o aplicativo para iniciar seus agendamentos.");
        logger.info("=======================================================\n\n");
    }
}
