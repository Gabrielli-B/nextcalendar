package com.nextcalendar.config;

import jakarta.servlet.Servlet;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class h2ConsoleConfig {
    @Bean
    public ServletRegistrationBean<Servlet> h2servletRegistration() {
        try {
            // Instancia o Servlet do H2 dinamicamente (compatível com runtime scope do Maven)
            Class<?> servletClass = Class.forName("org.h2.server.web.JakartaWebServlet");
            Servlet servlet = (Servlet) servletClass.getDeclaredConstructor().newInstance();

            ServletRegistrationBean<Servlet> registrationBean = new ServletRegistrationBean<>(servlet, "/h2-console/*");
            registrationBean.setName("H2Console");
            return registrationBean;
        } catch (Exception e) {
            throw new RuntimeException("Erro ao inicializar o H2 Console Servlet", e);
        }
    }
}
