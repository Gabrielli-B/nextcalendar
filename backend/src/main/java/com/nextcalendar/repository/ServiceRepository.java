package com.nextcalendar.repository;

import com.nextcalendar.entity.EstablishmentEntity;
import com.nextcalendar.entity.ServiceEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface ServiceRepository extends JpaRepository<ServiceEntity, UUID> {
    Page<ServiceEntity> findByEstablishmentAndActiveTrue(EstablishmentEntity establishment, Pageable pageable);

    Page<ServiceEntity> findByEstablishmentAndNameContainingIgnoreCaseAndActiveTrue(
            EstablishmentEntity establishment,
            String name,
            Pageable pageable
    );

    Optional<ServiceEntity> findByIdAndEstablishmentAndActiveTrue(UUID id, EstablishmentEntity establishment);

    Optional<ServiceEntity> findByIdAndActiveTrue(UUID id);

    Optional<ServiceEntity> findByNameAndEstablishmentAndActiveFalse(
            String name,
            EstablishmentEntity establishment
    );

    boolean existsByNameAndEstablishmentAndActiveTrue(String name, EstablishmentEntity establishment);

    boolean existsByNameAndEstablishmentAndActiveTrueAndIdNot(String name,EstablishmentEntity establishment,UUID idService);

}
