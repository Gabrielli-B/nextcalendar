package com.nextcalendar.service;

import com.nextcalendar.dto.services.ServiceCreateDTO;
import com.nextcalendar.dto.services.ServiceMinResponseDTO;
import com.nextcalendar.dto.services.ServiceUpdateDTO;
import com.nextcalendar.entity.EstablishmentEntity;
import com.nextcalendar.entity.ServiceEntity;
import com.nextcalendar.exception.BusinessException;
import com.nextcalendar.exception.EntityNotFoundException;
import com.nextcalendar.mapper.ServiceMapper;
import com.nextcalendar.repository.EstablishmentRepository;
import com.nextcalendar.repository.ServiceRepository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class ServiceService {
    private final ServiceRepository serviceRepository;

    //temporário enquanto não há login implentado, para cadastrar serviço precisa do ID do estabelecimento
    //quando tiver login apenas substituir pelo establichmentEntity pelo usuário autenticado.
    private final EstablishmentRepository establishmentRepository;

    private final ServiceMapper serviceMapper;

    public ServiceService(ServiceRepository serviceRepository, ServiceMapper serviceMapper,EstablishmentRepository establishmentRepository) {
        this.serviceRepository = serviceRepository;
        this.establishmentRepository = establishmentRepository;
        this.serviceMapper = serviceMapper;
    }

    public ServiceMinResponseDTO createService(UUID establishmentId, ServiceCreateDTO serviceDTO){
        //temporário enquanto não há login
        EstablishmentEntity establishment = establishmentRepository.findById(establishmentId).orElseThrow(()->new EntityNotFoundException("Estabelecimento",establishmentId));

        if(serviceRepository.existsByNameAndEstablishment(serviceDTO.name(),establishment)){
            throw new BusinessException("Já existe um serviço com o nome "+serviceDTO.name()+" neste estabelecimento.");
        }

        ServiceEntity service = serviceMapper.toEntity(serviceDTO,establishment);
        ServiceEntity savedService = serviceRepository.save(service);

        return new ServiceMinResponseDTO(savedService);
    }

    public ServiceMinResponseDTO updateService(UUID establishmentId, UUID idService, ServiceUpdateDTO serviceDTO){
        EstablishmentEntity establishment = establishmentRepository.findById(establishmentId).orElseThrow(()->new EntityNotFoundException("Estabelecimento",establishmentId));

        ServiceEntity serviceEntity = serviceRepository.findByIdAndEstablishmentAndActiveTrue(idService,establishment).orElseThrow(()->new EntityNotFoundException("Servico",idService));

        if(serviceRepository.existsByNameAndEstablishmentAndIdNot(serviceDTO.name(),establishment,idService)){
            throw new BusinessException( "Já existe um serviço com esse nome neste estabelecimento.");
        }

        serviceMapper.updateEntity(serviceEntity, serviceDTO);

        ServiceEntity updatedService = serviceRepository.save(serviceEntity);

        return new ServiceMinResponseDTO(updatedService);
    }

    public Page<ServiceMinResponseDTO> findServicesByName(String searchName, UUID establishmentId, Pageable pageable){

        EstablishmentEntity establishment = establishmentRepository.findById(establishmentId).orElseThrow(()->new EntityNotFoundException("Estabelecimento",establishmentId));

        return serviceRepository.findByEstablishmentAndNameContainingIgnoreCaseAndActiveTrue(establishment,searchName,pageable)
                .map(ServiceMinResponseDTO::new);
    }

    
}

