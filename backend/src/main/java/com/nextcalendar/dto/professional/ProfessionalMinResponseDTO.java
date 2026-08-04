package com.nextcalendar.dto.professional;

import com.nextcalendar.entity.ProfessionalEntity;

import java.math.BigDecimal;
import java.util.UUID;

public record ProfessionalMinResponseDTO(
        UUID id,
        String name,
        String phone,
        String photoUrl,
        BigDecimal commission) {

    public ProfessionalMinResponseDTO(ProfessionalEntity professional){
        this(
                professional.getId(),
                professional.getName(),
                professional.getPhone(),
                professional.getPhotoUrl(),
                professional.getCommission()
        );
    }
}
