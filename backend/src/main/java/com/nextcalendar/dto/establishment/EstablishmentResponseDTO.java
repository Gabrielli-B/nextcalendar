package com.nextcalendar.dto.establishment;

import com.nextcalendar.dto.address.AddressResponseDTO;
import com.nextcalendar.entity.EstablishmentEntity;

import java.time.LocalDateTime;
import java.util.UUID;

public record EstablishmentResponseDTO(
        UUID id,
        UUID ownerId,
        String legalName,
        String name,
        String cnpj,
        String phone,
        String whatsapp,
        String email,
        String businessType,
        String logoUrl,
        AddressResponseDTO address,
        LocalDateTime trialStartDate,
        LocalDateTime trialEndDate,
        boolean trialActive,
        boolean termsAccepted,
        LocalDateTime termsAcceptedAt,
        boolean active,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public EstablishmentResponseDTO(EstablishmentEntity e) {
        this(
                e.getId(),
                e.getOwnerId(),
                e.getLegalName(),
                e.getName(),
                e.getCnpj(),
                e.getPhone(),
                e.getWhatsapp(),
                e.getEmail(),
                e.getBusinessType(),
                e.getLogoUrl(),
                e.getAddress() != null ? new AddressResponseDTO(e.getAddress()) : null,
                e.getTrialStartDate(),
                e.getTrialEndDate(),
                // trialActive calculado dinamicamente
                LocalDateTime.now().isBefore(e.getTrialEndDate()),
                Boolean.TRUE.equals(e.getTermsAccepted()),
                e.getTermsAcceptedAt(),
                Boolean.TRUE.equals(e.getActive()),
                e.getCreatedAt(),
                e.getUpdatedAt()
        );
    }
}
