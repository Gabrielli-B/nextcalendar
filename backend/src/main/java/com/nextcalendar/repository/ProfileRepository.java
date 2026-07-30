package com.nextcalendar.repository;

import com.nextcalendar.entity.ProfileEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ProfileRepository extends JpaRepository<ProfileEntity, UUID> {

    List<ProfileEntity> findByEstablishmentId(UUID establishmentId);

    boolean existsByOwnerIdAndEstablishmentId(UUID ownerId, UUID establishmentId);
}
