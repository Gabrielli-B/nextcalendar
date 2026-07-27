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

    Optional<ServiceEntity> findByIdAndActiveTrue(UUID id);

    boolean existsByNameAndEstablishment(String name, EstablishmentEntity establishment);

    boolean existsByNameAndEstablishmentAndIdNot(
            String name,
            EstablishmentEntity establishment,
            UUID id
    );
}
