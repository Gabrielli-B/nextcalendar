package com.nextcalendar.dto.professional;

import com.nextcalendar.entity.ProfessionalEntity;
import jakarta.persistence.Column;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record ProfessionalDetailsResponseDTO(
        UUID id,
        String name,
        String nickname,
        String cpf,
        String email,
        String phone,
        String gender,
        String photoUrl,
        BigDecimal commission,
        Boolean active,
        LocalDateTime createdAt,
        LocalDateTime updatedAt) {

    public ProfessionalDetailsResponseDTO(ProfessionalEntity professional){
        this(
                professional.getId(),
                professional.getName(),
                professional.getNickname(),
                professional.getCpf(),
                professional.getEmail(),
                professional.getPhone(),
                professional.getGender(),
                professional.getPhotoUrl(),
                professional.getCommission(),
                professional.getActive(),
                professional.getCreatedAt(),
                professional.getUpdatedAt()
        );
    }
}
