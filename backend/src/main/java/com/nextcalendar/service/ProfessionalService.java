package com.nextcalendar.service;

import com.nextcalendar.dto.professional.*;
import com.nextcalendar.entity.EstablishmentEntity;
import com.nextcalendar.entity.ProfessionalEntity;
import com.nextcalendar.exception.BusinessException;
import com.nextcalendar.exception.EntityNotFoundException;
import com.nextcalendar.mapper.ProfessionalMapper;
import com.nextcalendar.repository.EstablishmentRepository;
import com.nextcalendar.repository.ProfessionalRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class ProfessionalService {

    private final ProfessionalRepository professionalRepository;
    private final EstablishmentRepository establishmentRepository;
    private final ProfessionalMapper professionalMapper;

    public ProfessionalService(ProfessionalRepository professionalRepository, EstablishmentRepository establishmentRepository, ProfessionalMapper professionalMapper) {
        this.professionalRepository = professionalRepository;
        this.establishmentRepository = establishmentRepository;
        this.professionalMapper = professionalMapper;
    }

    // Temporário enquanto não há login implementado.
    // Quando houver autenticação, basta utilizar o estabelecimento do usuário autenticado.
    private EstablishmentEntity findEstablishment(UUID establishmentId) {
        return establishmentRepository.findById(establishmentId)
                .orElseThrow(() -> new EntityNotFoundException("Estabelecimento", establishmentId));
    }

    private ProfessionalEntity findProfessional(UUID id) {
        return professionalRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Profissional", id));
    }

    public ProfessionalProfileResponseDTO createProfessional(UUID establishmentId, ProfessionalCreateDTO dto) {

        if (professionalRepository.existsByEmail(dto.email())) {
            throw new BusinessException("O e-mail '" + dto.email() + "' já está cadastrado no sistema.");
        }

        if (professionalRepository.existsByCpf(dto.cpf())) {
            throw new BusinessException("O CPF '" + dto.cpf() + "' já está cadastrado no sistema.");
        }

        EstablishmentEntity establishment = findEstablishment(establishmentId);

        ProfessionalEntity professional = professionalMapper.toEntity(dto, establishment);
        ProfessionalEntity savedProfessional = professionalRepository.save(professional);

        return new ProfessionalProfileResponseDTO(savedProfessional);
    }

    public ProfessionalDetailsResponseDTO updateProfessionalByAdmin(UUID id, ProfessionalAdminUpdateDTO dto) {

        ProfessionalEntity professional = findProfessional(id);

        if (dto.email() != null && !dto.email().isBlank() && !dto.email().equals(professional.getEmail())) {
            if (professionalRepository.existsByEmailAndIdNot(dto.email(), id)) {
                throw new BusinessException("O e-mail '" + dto.email() + "' já está sendo usado por outro profissional.");
            }
        }

        if (dto.cpf() != null && !dto.cpf().isBlank() && !dto.cpf().equals(professional.getCpf())) {
            if (professionalRepository.existsByCpfAndIdNot(dto.cpf(), id)) {
                throw new BusinessException("O CPF '" + dto.cpf() + "' já está sendo usado por outro profissional.");
            }
        }

        professionalMapper.updateEntityFromAdmin(professional, dto);

        ProfessionalEntity updatedProfessional = professionalRepository.save(professional);

        return new ProfessionalDetailsResponseDTO(updatedProfessional);
    }

    public ProfessionalProfileResponseDTO updateProfessionalBySelf(UUID id, ProfessionalSelfUpdateDTO dto) {

        ProfessionalEntity professional = findProfessional(id);

        if (dto.email() != null && !dto.email().isBlank() && !dto.email().equals(professional.getEmail())) {
            if (professionalRepository.existsByEmailAndIdNot(dto.email(), id)) {
                throw new BusinessException("O e-mail '" + dto.email() + "' já está sendo usado por outro profissional.");
            }
        }

        professionalMapper.updateEntityFromSelf(professional, dto);

        ProfessionalEntity updatedProfessional = professionalRepository.save(professional);

        return new ProfessionalProfileResponseDTO(updatedProfessional);
    }

    public ProfessionalDetailsResponseDTO findProfessionalById(UUID id) {
        ProfessionalEntity professional = findProfessional(id);

        return new ProfessionalDetailsResponseDTO(professional);
    }

    public ProfessionalDetailsResponseDTO findProfessionalByIdAndEstablishment(UUID id, UUID establishmentId) {
        findEstablishment(establishmentId);

        ProfessionalEntity professional = professionalRepository
                .findByIdAndEstablishmentId(id, establishmentId)
                .orElseThrow(() -> new EntityNotFoundException("Profissional", id));

        return new ProfessionalDetailsResponseDTO(professional);
    }

    public Page<ProfessionalMinResponseDTO> findByEstablishment(UUID establishmentId, Pageable pageable) {

        findEstablishment(establishmentId);

        return professionalRepository.findByEstablishmentId(establishmentId, pageable)
                .map(ProfessionalMinResponseDTO::new);
    }

    public Page<ProfessionalMinResponseDTO> findActiveByEstablishment(UUID establishmentId, Pageable pageable) {

        findEstablishment(establishmentId);

        return professionalRepository.findByEstablishmentIdAndActiveTrue(establishmentId, pageable)
                .map(ProfessionalMinResponseDTO::new);
    }

    public Page<ProfessionalMinResponseDTO> findByNameAndEstablishment(UUID establishmentId, String name, Pageable pageable) {
        findEstablishment(establishmentId);

        return professionalRepository
                .findByEstablishmentIdAndNameContainingIgnoreCase(establishmentId, name, pageable)
                .map(ProfessionalMinResponseDTO::new);
    }

    public void deleteProfessional(UUID id) {
        ProfessionalEntity professional = findProfessional(id);

        professional.setActive(false);
        professionalRepository.save(professional);
    }
}