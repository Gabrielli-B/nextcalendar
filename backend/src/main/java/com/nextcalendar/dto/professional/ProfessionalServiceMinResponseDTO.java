package com.nextcalendar.dto.professional;

import com.nextcalendar.entity.ProfessionalServiceEntity;

import java.util.UUID;

/**
 * Vínculo profissional ↔ serviço. Profissional sem vínculos atende todos os serviços;
 * serviço sem vínculos aceita todos os profissionais.
 */
public record ProfessionalServiceMinResponseDTO(UUID professionalId, UUID serviceId) {

	public ProfessionalServiceMinResponseDTO(ProfessionalServiceEntity entity) {
		this(entity.getId().getProfessionalId(), entity.getId().getServiceId());
	}

}
