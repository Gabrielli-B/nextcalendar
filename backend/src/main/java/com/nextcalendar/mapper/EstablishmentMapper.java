package com.nextcalendar.mapper;

import com.nextcalendar.dto.EstablishmentCreateDTO;
import com.nextcalendar.dto.EstablishmentUpdateDTO;
import com.nextcalendar.entity.AddressEmbeddable;
import com.nextcalendar.entity.EstablishmentEntity;

import java.time.LocalDateTime;

public class EstablishmentMapper {

    private EstablishmentMapper() {}

    /**
     * Converte o DTO de criação numa entidade nova (sem trial e sem termos — preenchidos no service).
     */
    public static EstablishmentEntity toEntity(EstablishmentCreateDTO dto) {
        EstablishmentEntity entity = new EstablishmentEntity();
        entity.setOwnerId(dto.ownerId());
        entity.setLegalName(dto.legalName());
        entity.setName(dto.name());
        entity.setPhone(dto.phone());
        entity.setWhatsapp(dto.whatsapp());
        entity.setEmail(dto.email());
        entity.setBusinessType(dto.businessType());
        entity.setActive(true);
        return entity;
    }

    /**
     * Aplica patch parcial da tela Empresa sobre a entidade existente.
     * Apenas campos não-nulos e não-vazios são sobrescritos.
     */
    public static void updateEntity(EstablishmentEntity entity, EstablishmentUpdateDTO dto) {
        if (isNotBlank(dto.legalName()))    entity.setLegalName(dto.legalName());
        if (isNotBlank(dto.name()))         entity.setName(dto.name());
        if (isNotBlank(dto.phone()))        entity.setPhone(dto.phone());
        if (dto.whatsapp() != null)         entity.setWhatsapp(dto.whatsapp());
        if (isNotBlank(dto.email()))        entity.setEmail(dto.email());
        if (dto.businessType() != null)     entity.setBusinessType(dto.businessType());
        if (dto.logoUrl() != null)          entity.setLogoUrl(dto.logoUrl());
    }

    /**
     * Atualiza o endereço embeddable — usado quando o CEP muda na tela Empresa.
     */
    public static void updateAddress(EstablishmentEntity entity, AddressEmbeddable novoEndereco) {
        entity.setAddress(novoEndereco);
    }

    private static boolean isNotBlank(String value) {
        return value != null && !value.isBlank();
    }
}
