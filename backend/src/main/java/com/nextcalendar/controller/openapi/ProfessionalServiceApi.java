package com.nextcalendar.controller.openapi;

import com.nextcalendar.dto.professional.ProfessionalServiceMinResponseDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

import java.util.List;
import java.util.UUID;

@Tag(name = "Vínculos profissional-serviço",
		description = "Endpoints para gerenciar quais serviços cada profissional do estabelecimento realiza")
public interface ProfessionalServiceApi {

	@Operation(summary = "Listar vínculos profissional-serviço",
			description = "Retorna todos os pares (profissional, serviço) do estabelecimento. Profissional sem "
					+ "vínculos atende todos os serviços; serviço sem vínculos aceita todos os profissionais.")
	@ApiResponse(responseCode = "200", description = "Lista retornada com sucesso")
	List<ProfessionalServiceMinResponseDTO> findServiceLinks(UUID establishmentId);

	@Operation(summary = "Substituir vínculos de um profissional",
			description = "Substitui todos os serviços do profissional pela lista informada. Uma lista vazia (ou "
					+ "ausente) remove todos os vínculos, fazendo o profissional atender a todos os serviços.")
	@ApiResponses({ @ApiResponse(responseCode = "200", description = "Vínculos substituídos com sucesso"),
			@ApiResponse(responseCode = "404", description = "Estabelecimento, profissional ou serviço não encontrado"),
			@ApiResponse(responseCode = "422", description = "Corpo inválido") })
	List<ProfessionalServiceMinResponseDTO> replaceServiceLinks(UUID establishmentId, UUID professionalId,
			List<UUID> serviceIds);

}
