package com.nextcalendar.controller;

import com.nextcalendar.controller.openapi.ProfessionalApi;
import com.nextcalendar.dto.professional.*;
import com.nextcalendar.service.ProfessionalService;
import jakarta.validation.Valid;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/establishments/{establishmentId}/professionals")
public class ProfessionalController implements ProfessionalApi {

    private final ProfessionalService professionalService;

    public ProfessionalController(ProfessionalService professionalService) {
        this.professionalService = professionalService;
    }

    @Override
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProfessionalProfileResponseDTO createProfessional(@PathVariable UUID establishmentId, @Valid @RequestBody ProfessionalCreateDTO dto) {
        return professionalService.createProfessional(establishmentId, dto);
    }

    @Override
    @PutMapping("/{id}/admin")
    public ProfessionalDetailsResponseDTO updateProfessionalByAdmin(@PathVariable UUID id, @Valid @RequestBody ProfessionalAdminUpdateDTO dto) {
        return professionalService.updateProfessionalByAdmin(id, dto);
    }

    @Override
    @PutMapping("/{id}")
    public ProfessionalProfileResponseDTO updateProfessionalBySelf(@PathVariable UUID id, @Valid @RequestBody ProfessionalSelfUpdateDTO dto) {
        return professionalService.updateProfessionalBySelf(id, dto);
    }

    @Override
    @GetMapping("/{id}")
    public ProfessionalDetailsResponseDTO findProfessionalById(@PathVariable UUID establishmentId, @PathVariable UUID id) {
        return professionalService.findProfessionalByIdAndEstablishment(id, establishmentId);
    }

    @Override
    @GetMapping
    public Page<ProfessionalMinResponseDTO> findByEstablishment(@PathVariable UUID establishmentId, @ParameterObject Pageable pageable) {
        return professionalService.findByEstablishment(establishmentId, pageable);
    }

    @Override
    @GetMapping("/active")
    public Page<ProfessionalMinResponseDTO> findActiveByEstablishment(@PathVariable UUID establishmentId, @ParameterObject Pageable pageable) {
        return professionalService.findActiveByEstablishment(establishmentId, pageable);
    }

    @Override
    @GetMapping("/search")
    public Page<ProfessionalMinResponseDTO> findByNameAndEstablishment(
            @RequestParam(defaultValue = "") String name,
            @PathVariable UUID establishmentId,
            @ParameterObject Pageable pageable) {

        return professionalService.findByNameAndEstablishment(establishmentId, name, pageable);
    }

    @Override
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteProfessional(@PathVariable UUID id) {
        professionalService.deleteProfessional(id);
    }
}
