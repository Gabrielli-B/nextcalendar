package com.nextcalendar.dto.services;

import com.nextcalendar.entity.ServiceEntity;

import java.math.BigDecimal;

public record ServiceMinResponseDTO(
        String name,
        BigDecimal price,
        Integer duration,
        String category
) {
    public ServiceMinResponseDTO(ServiceEntity entity) {
        this(entity.getName(),entity.getPrice(),entity.getDuration(),entity.getCategory());
    }
}
