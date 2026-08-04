package com.nextcalendar.dto.professional;

import com.nextcalendar.entity.ProfessionalEntity;

import java.math.BigDecimal;

public record ProfessionalProfileResponseDTO(
        String name,
        String nickname,
        String cpf,
        String email,
        String phone,
        String gender,
        String photoUrl,
        BigDecimal commission){

    public ProfessionalProfileResponseDTO(ProfessionalEntity professional){
        this(
                professional.getName(),
                professional.getNickname(),
                professional.getCpf(),
                professional.getEmail(),
                professional.getPhone(),
                professional.getGender(),
                professional.getPhotoUrl(),
                professional.getCommission()
        );
    }

    }
