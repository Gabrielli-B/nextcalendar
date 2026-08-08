package com.nextcalendar.controller;

import com.nextcalendar.controller.openapi.ServiceApi;
import com.nextcalendar.dto.services.ServiceCreateDTO;
import com.nextcalendar.dto.services.ServiceMinResponseDTO;
import com.nextcalendar.dto.services.ServiceUpdateDTO;
import com.nextcalendar.service.ServiceService;
import jakarta.validation.Valid;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/establishments/{establishmentId}/services")

public class ServiceController implements ServiceApi {

    private final ServiceService serviceService;

    public ServiceController(ServiceService serviceService) {
        this.serviceService = serviceService;
    }


    @Override
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ServiceMinResponseDTO createService(@Valid @RequestBody ServiceCreateDTO serviceDTO,@PathVariable UUID establishmentId){
        return serviceService.createService(establishmentId,serviceDTO);
    }

    @Override
    @PutMapping("/{id}")
    public ServiceMinResponseDTO updateService(@PathVariable UUID establishmentId, @PathVariable("id") UUID idService, @Valid @RequestBody ServiceUpdateDTO serviceDTO){
        return serviceService.updateService(establishmentId,idService,serviceDTO);
    }

    @Override
    @GetMapping("/search")
    public Page<ServiceMinResponseDTO> findServicesByName(@RequestParam (defaultValue = "") String name, @PathVariable UUID establishmentId, @ParameterObject Pageable pageable){
        return serviceService.findServicesByName(name,establishmentId,pageable);
    }

    @Override
    @GetMapping
    public Page<ServiceMinResponseDTO> findAllServices(@PathVariable UUID establishmentId, @ParameterObject Pageable pageable) {
        return serviceService.findAllServices(establishmentId, pageable);
    }

    @Override
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteService(@PathVariable UUID id){serviceService.deleteService(id);}
}
