package com.nextcalendar.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * O Spring Boot 4 auto-configura apenas o Jackson 3 (tools.jackson).
 * Os filtros de segurança e os testes de integração injetam o Jackson 2
 * (com.fasterxml.jackson), então registramos um ObjectMapper do Jackson 2
 * como bean. O jackson-databind 2 chega na classepath via jjwt-jackson.
 */
@Configuration
public class JacksonConfig {

    @Bean
    public ObjectMapper jackson2ObjectMapper() {
        return new ObjectMapper().findAndRegisterModules();
    }
}
