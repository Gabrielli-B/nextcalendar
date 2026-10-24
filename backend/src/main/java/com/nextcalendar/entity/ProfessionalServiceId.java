package com.nextcalendar.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProfessionalServiceId implements Serializable {

	@Column(name = "professional_id")
	private UUID professionalId;

	@Column(name = "service_id")
	private UUID serviceId;

	@Override
	public boolean equals(Object o) {
		if (this == o)
			return true;
		if (!(o instanceof ProfessionalServiceId other))
			return false;
		return Objects.equals(professionalId, other.professionalId) && Objects.equals(serviceId, other.serviceId);
	}

	@Override
	public int hashCode() {
		return Objects.hash(professionalId, serviceId);
	}

}
