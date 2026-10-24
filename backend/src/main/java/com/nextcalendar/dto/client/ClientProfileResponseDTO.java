package com.nextcalendar.dto.client;

import com.nextcalendar.entity.ClientEntity;
import java.time.LocalDate;
import java.util.UUID;

/**
 * Perfil do cliente devolvido em POST/PUT /clients. O id é obrigatório: o frontend
 * (clientServices.createClient/updateClient) usa o id retornado para abrir o perfil logo
 * após salvar.
 */
public record ClientProfileResponseDTO(UUID id, String name, String phone, String email, LocalDate dateOfBirth,
		String photoUrl, String notes) {

	public ClientProfileResponseDTO(ClientEntity client) {
		this(client.getId(), client.getName(), client.getPhone(), client.getEmail(), client.getDateOfBirth(),
				client.getPhotoUrl(), client.getNotes());
	}
}
