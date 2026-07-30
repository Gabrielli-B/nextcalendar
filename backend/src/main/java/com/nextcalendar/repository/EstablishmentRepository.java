package com.nextcalendar.repository;

import com.nextcalendar.entity.EstablishmentEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface EstablishmentRepository extends JpaRepository<EstablishmentEntity, UUID> {

}
