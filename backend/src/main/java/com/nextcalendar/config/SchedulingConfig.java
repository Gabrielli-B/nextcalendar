package com.nextcalendar.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Habilita o suporte a @Scheduled no Spring.
 * Usado pelo TrialSchedulerService (UC05).
 */
@Configuration
@EnableScheduling
public class SchedulingConfig {}
