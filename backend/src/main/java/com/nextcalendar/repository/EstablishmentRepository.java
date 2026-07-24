package com.nextcalendar.repository;

import com.nextcalendar.entity.EstablishmentEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface EstablishmentRepository extends JpaRepository<EstablishmentEntity, UUID> {

    boolean existsByCnpj(String cnpj);

    boolean existsByCnpjAndIdNot(String cnpj, UUID id);

    boolean existsByEmail(String email);

    // UC03 — buscar establishment pelo dono
    Optional<EstablishmentEntity> findFirstByOwnerIdAndActiveTrue(UUID ownerId);

    // UC05 — scheduler: trial expirando em breve (aviso <= 7 dias)
    List<EstablishmentEntity> findByTrialEndDateBetweenAndActiveTrue(LocalDateTime start, LocalDateTime end);

    // UC05 — scheduler: trial já expirado
    List<EstablishmentEntity> findByTrialEndDateBeforeAndActiveTrue(LocalDateTime threshold);
}
