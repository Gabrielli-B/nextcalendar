package com.nextcalendar.service;

import com.nextcalendar.dto.professional.*;
import com.nextcalendar.entity.EstablishmentEntity;
import com.nextcalendar.entity.ProfessionalEntity;
import com.nextcalendar.entity.ProfessionalServiceEntity;
import com.nextcalendar.entity.ServiceEntity;
import com.nextcalendar.entity.UserEntity;
import com.nextcalendar.entity.UserRole;
import com.nextcalendar.exception.BusinessException;
import com.nextcalendar.exception.EntityNotFoundException;
import com.nextcalendar.mapper.ProfessionalMapper;
import com.nextcalendar.repository.EstablishmentRepository;
import com.nextcalendar.repository.ProfessionalRepository;
import com.nextcalendar.repository.ProfessionalServiceRepository;
import com.nextcalendar.repository.ServiceRepository;
import com.nextcalendar.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class ProfessionalService {

	private final ProfessionalRepository professionalRepository;

	private final EstablishmentRepository establishmentRepository;

	private final UserRepository userRepository;

	private final ProfessionalMapper professionalMapper;

	private final PasswordEncoder passwordEncoder;

	private final ServiceRepository serviceRepository;

	private final ProfessionalServiceRepository professionalServiceRepository;

	public ProfessionalService(ProfessionalRepository professionalRepository,
			EstablishmentRepository establishmentRepository, UserRepository userRepository,
			ProfessionalMapper professionalMapper, PasswordEncoder passwordEncoder, ServiceRepository serviceRepository,
			ProfessionalServiceRepository professionalServiceRepository) {
		this.professionalRepository = professionalRepository;
		this.establishmentRepository = establishmentRepository;
		this.userRepository = userRepository;
		this.professionalMapper = professionalMapper;
		this.passwordEncoder = passwordEncoder;
		this.serviceRepository = serviceRepository;
		this.professionalServiceRepository = professionalServiceRepository;
	}

	private EstablishmentEntity findEstablishment(UUID establishmentId) {
		return establishmentRepository.findById(establishmentId)
			.orElseThrow(() -> new EntityNotFoundException("Estabelecimento", establishmentId));
	}

	private ProfessionalEntity findProfessional(UUID id) {
		return professionalRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Profissional", id));
	}

	// ─── Alfabeto seguro: sem 0/O (ambíguo) e 1/l (ambíguo) ─────────────────
	private static final String TEMP_PWD_ALPHABET = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789";

	private static final int TEMP_PWD_LENGTH = 10;

	private static final SecureRandom SECURE_RANDOM = new SecureRandom();

	/**
	 * Gera uma senha temporária de {@value TEMP_PWD_LENGTH} caracteres com SecureRandom.
	 */
	private String generateTemporaryPassword() {
		StringBuilder sb = new StringBuilder(TEMP_PWD_LENGTH);
		for (int i = 0; i < TEMP_PWD_LENGTH; i++) {
			sb.append(TEMP_PWD_ALPHABET.charAt(SECURE_RANDOM.nextInt(TEMP_PWD_ALPHABET.length())));
		}
		return sb.toString();
	}

	@Transactional(readOnly = true)
	public ProfessionalMeResponseDTO getMe() {
		com.nextcalendar.entity.UserEntity user = com.nextcalendar.config.SecurityUtils.getRequiredAuthenticatedUser();
		ProfessionalEntity professional = professionalRepository.findByUserId(user.getId())
			.orElseThrow(() -> new EntityNotFoundException("Profissional não encontrado para o usuário logado.",
					user.getId()));
		return new ProfessionalMeResponseDTO(professional);
	}

	@Transactional(readOnly = true)
	public ProfessionalMeResponseDTO findByUserId(UUID userId) {
		ProfessionalEntity professional = professionalRepository.findByUserId(userId)
			.orElseThrow(() -> new EntityNotFoundException("Profissional não encontrado para o usuário.", userId));
		return new ProfessionalMeResponseDTO(professional);
	}

	@Transactional(readOnly = true)
	public ProfessionalMeResponseDTO getMyProfile(UUID userId) {
		return findByUserId(userId);
	}

	@Transactional
	public ProfessionalProfileResponseDTO createProfessional(UUID establishmentId, ProfessionalCreateDTO dto) {
		com.nextcalendar.config.SecurityUtils.getAuthenticatedUser().ifPresent(u -> {
			if (u.getRole() == UserRole.PROFESSIONAL) {
				throw new org.springframework.security.access.AccessDeniedException(
						"Profissionais não têm permissão para cadastrar novos profissionais.");
			}
		});

		if (userRepository.existsByEmail(dto.email()) || professionalRepository.existsByEmail(dto.email())) {
			throw new BusinessException("O e-mail '" + dto.email() + "' já está cadastrado no sistema.");
		}

		if (professionalRepository.existsByCpf(dto.cpf())) {
			throw new BusinessException("O CPF '" + dto.cpf() + "' já está cadastrado no sistema.");
		}

		EstablishmentEntity establishment = findEstablishment(establishmentId);

		// Gera senha temporária — o hash vai para o banco, o texto puro volta só na
		// resposta
		String temporaryPassword = generateTemporaryPassword();

		UserEntity user = new UserEntity();
		user.setName(dto.name());
		user.setEmail(dto.email());
		user.setPasswordHash(passwordEncoder.encode(temporaryPassword));
		user.setRole(UserRole.PROFESSIONAL);
		user.setActive(true);
		user.setMustChangePassword(true); // força troca no primeiro login

		UserEntity savedUser = userRepository.save(user);

		ProfessionalEntity professional = professionalMapper.toEntity(dto, establishment);
		professional.setUser(savedUser);

		ProfessionalEntity savedProfessional = professionalRepository.save(professional);

		// Devolve a senha temporária em texto puro SOMENTE aqui — nunca em GET
		return new ProfessionalProfileResponseDTO(savedProfessional.getName(), savedProfessional.getNickname(),
				savedProfessional.getCpf(), savedProfessional.getEmail(), savedProfessional.getPhone(),
				savedProfessional.getGender(), savedProfessional.getPhotoUrl(), savedProfessional.getCommission(),
				temporaryPassword);
	}

	@Transactional
	public ProfessionalDetailsResponseDTO updateProfessionalByAdmin(UUID id, ProfessionalAdminUpdateDTO dto) {
		com.nextcalendar.config.SecurityUtils.getAuthenticatedUser().ifPresent(u -> {
			if (u.getRole() == UserRole.PROFESSIONAL) {
				throw new org.springframework.security.access.AccessDeniedException(
						"Profissionais não têm permissão para editar outros profissionais.");
			}
		});

		ProfessionalEntity professional = findProfessional(id);

		if (dto.email() != null && !dto.email().isBlank() && !dto.email().equals(professional.getEmail())) {
			boolean emailExistsInUsers = userRepository.findByEmail(dto.email())
				.filter(u -> professional.getUser() == null || !u.getId().equals(professional.getUser().getId()))
				.isPresent();

			if (emailExistsInUsers || professionalRepository.existsByEmailAndIdNot(dto.email(), id)) {
				throw new BusinessException("O e-mail '" + dto.email() + "' já está sendo usado no sistema.");
			}
		}

		if (dto.cpf() != null && !dto.cpf().isBlank() && !dto.cpf().equals(professional.getCpf())) {
			if (professionalRepository.existsByCpfAndIdNot(dto.cpf(), id)) {
				throw new BusinessException("O CPF '" + dto.cpf() + "' já está sendo usado por outro profissional.");
			}
		}
		professionalMapper.updateEntityFromAdmin(professional, dto);

		if (professional.getUser() != null) {
			if (dto.name() != null && !dto.name().isBlank()) {
				professional.getUser().setName(dto.name());
			}
			if (dto.email() != null && !dto.email().isBlank()) {
				professional.getUser().setEmail(dto.email());
			}
			if (dto.active() != null) {
				professional.getUser().setActive(dto.active());
			}
		}

		ProfessionalEntity updatedProfessional = professionalRepository.save(professional);

		return new ProfessionalDetailsResponseDTO(updatedProfessional);
	}

	@Transactional
	public ProfessionalProfileResponseDTO updateProfessionalBySelf(UUID id, ProfessionalSelfUpdateDTO dto) {

		ProfessionalEntity professional = findProfessional(id);

		if (dto.email() != null && !dto.email().isBlank() && !dto.email().equals(professional.getEmail())) {

			boolean emailExistsInUsers = userRepository.findByEmail(dto.email())
				.filter(u -> professional.getUser() == null || !u.getId().equals(professional.getUser().getId()))
				.isPresent();

			if (emailExistsInUsers || professionalRepository.existsByEmailAndIdNot(dto.email(), id)) {
				throw new BusinessException("O e-mail '" + dto.email() + "' já está sendo usado no sistema.");
			}
		}

		professionalMapper.updateEntityFromSelf(professional, dto);

		if (professional.getUser() != null) {
			if (dto.name() != null && !dto.name().isBlank()) {
				professional.getUser().setName(dto.name());
			}
			if (dto.email() != null && !dto.email().isBlank()) {
				professional.getUser().setEmail(dto.email());
			}
		}

		ProfessionalEntity updatedProfessional = professionalRepository.save(professional);

		return new ProfessionalProfileResponseDTO(updatedProfessional);
	}

	@Transactional(readOnly = true)
	public ProfessionalDetailsResponseDTO findProfessionalById(UUID id) {
		ProfessionalEntity professional = findProfessional(id);

		return new ProfessionalDetailsResponseDTO(professional);
	}

	@Transactional(readOnly = true)
	public ProfessionalDetailsResponseDTO findProfessionalByIdAndEstablishment(UUID id, UUID establishmentId) {
		findEstablishment(establishmentId);

		ProfessionalEntity professional = professionalRepository.findByIdAndEstablishmentId(id, establishmentId)
			.orElseThrow(() -> new EntityNotFoundException("Profissional", id));

		return new ProfessionalDetailsResponseDTO(professional);
	}

	@Transactional(readOnly = true)
	public Page<ProfessionalMinResponseDTO> findByEstablishment(UUID establishmentId, Pageable pageable) {

		findEstablishment(establishmentId);

		return professionalRepository.findByEstablishmentId(establishmentId, pageable)
			.map(ProfessionalMinResponseDTO::new);
	}

	@Transactional(readOnly = true)
	public Page<ProfessionalMinResponseDTO> findActiveByEstablishment(UUID establishmentId, Pageable pageable) {

		findEstablishment(establishmentId);

		return professionalRepository.findByEstablishmentIdAndActiveTrue(establishmentId, pageable)
			.map(ProfessionalMinResponseDTO::new);
	}

	@Transactional(readOnly = true)
	public Page<ProfessionalMinResponseDTO> findByNameAndEstablishment(UUID establishmentId, String name,
			Pageable pageable) {
		findEstablishment(establishmentId);

		return professionalRepository.findByEstablishmentIdAndNameContainingIgnoreCase(establishmentId, name, pageable)
			.map(ProfessionalMinResponseDTO::new);
	}

	@Transactional
	public void deleteProfessional(UUID id) {
		com.nextcalendar.config.SecurityUtils.getAuthenticatedUser().ifPresent(u -> {
			if (u.getRole() == UserRole.PROFESSIONAL) {
				throw new org.springframework.security.access.AccessDeniedException(
						"Profissionais não têm permissão para desativar profissionais.");
			}
		});
		ProfessionalEntity professional = findProfessional(id);

		professional.setActive(false);

		if (professional.getUser() != null) {
			professional.getUser().setActive(false);
		}

		professionalRepository.save(professional);
	}

	// ─── Vínculo profissional ↔ serviço ────────────────────────────────────

	@Transactional(readOnly = true)
	public List<ProfessionalServiceMinResponseDTO> findServiceLinks(UUID establishmentId) {
		findEstablishment(establishmentId);

		return professionalServiceRepository.findByProfessional_Establishment_Id(establishmentId)
			.stream()
			.map(ProfessionalServiceMinResponseDTO::new)
			.toList();
	}

	@Transactional
	public List<ProfessionalServiceMinResponseDTO> replaceServiceLinks(UUID establishmentId, UUID professionalId,
			List<UUID> serviceIds) {
		EstablishmentEntity establishment = findEstablishment(establishmentId);

		ProfessionalEntity professional = professionalRepository
			.findByIdAndEstablishmentId(professionalId, establishmentId)
			.orElseThrow(() -> new EntityNotFoundException("Profissional", professionalId));

		Set<UUID> unicos = new LinkedHashSet<>(serviceIds == null ? List.<UUID>of() : serviceIds);

		List<ServiceEntity> services = new ArrayList<>(unicos.size());
		for (UUID serviceId : unicos) {
			services.add(serviceRepository.findByIdAndEstablishmentAndActiveTrue(serviceId, establishment)
				.orElseThrow(() -> new EntityNotFoundException("Serviço", serviceId)));
		}

		professionalServiceRepository.deleteAllByProfessionalId(professionalId);

		List<ProfessionalServiceEntity> novos = services.stream()
			.map(service -> new ProfessionalServiceEntity(professional, service))
			.toList();
		professionalServiceRepository.saveAll(novos);

		return novos.stream().map(ProfessionalServiceMinResponseDTO::new).toList();
	}

	@Transactional(readOnly = true)
	public void validarVinculoProfissionalServico(ProfessionalEntity professional, ServiceEntity service) {
		if (professionalServiceRepository.countById_ProfessionalId(professional.getId()) == 0) {
			return;
		}
		if (professionalServiceRepository.countById_ServiceId(service.getId()) == 0) {
			return;
		}
		if (!professionalServiceRepository.existsById_ProfessionalIdAndIdServiceId(professional.getId(),
				service.getId())) {
			throw new BusinessException(professional.getName() + " não realiza o serviço " + service.getName() + ".");
		}
	}

}