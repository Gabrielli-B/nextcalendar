package com.nextcalendar.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "professional_services")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProfessionalServiceEntity {

	@EmbeddedId
	private ProfessionalServiceId id;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "professional_id", insertable = false, updatable = false)
	private ProfessionalEntity professional;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "service_id", insertable = false, updatable = false)
	private ServiceEntity service;

	public ProfessionalServiceEntity(ProfessionalEntity professional, ServiceEntity service) {
		this.id = new ProfessionalServiceId(professional.getId(), service.getId());
		this.professional = professional;
		this.service = service;
	}

}
