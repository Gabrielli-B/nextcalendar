package com.nextcalendar.controller;

import com.nextcalendar.controller.openapi.ProfessionalServiceApi;
import com.nextcalendar.dto.professional.ProfessionalServiceMinResponseDTO;
import com.nextcalendar.service.ProfessionalService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/establishments/{establishmentId}/professional-services")
public class ProfessionalServiceController implements ProfessionalServiceApi {

	private final ProfessionalService professionalService;

	public ProfessionalServiceController(ProfessionalService professionalService) {
		this.professionalService = professionalService;
	}

	@Override
	@GetMapping
	public List<ProfessionalServiceMinResponseDTO> findServiceLinks(@PathVariable UUID establishmentId) {
		return professionalService.findServiceLinks(establishmentId);
	}

	@Override
	@PutMapping("/{professionalId}")
	public List<ProfessionalServiceMinResponseDTO> replaceServiceLinks(@PathVariable UUID establishmentId,
			@PathVariable UUID professionalId, @RequestBody(required = false) List<UUID> serviceIds) {
		return professionalService.replaceServiceLinks(establishmentId, professionalId, serviceIds);
	}

}
