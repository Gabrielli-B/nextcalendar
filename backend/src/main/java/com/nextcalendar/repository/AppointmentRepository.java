package com.nextcalendar.repository;

import com.nextcalendar.entity.AppointmentEntity;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface AppointmentRepository extends JpaRepository<AppointmentEntity, UUID> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            SELECT a FROM AppointmentEntity a
            WHERE a.professional.id = :professionalId
              AND a.status <> com.nextcalendar.entity.AppointmentStatus.CANCELED
              AND a.startDateTime < :endDateTime
              AND a.endDateTime > :startDateTime
            """)

    List<AppointmentEntity> findOverlapping(
            @Param("professionalId") UUID professionalId,
            @Param("startDateTime") LocalDateTime startDateTime,
            @Param("endDateTime") LocalDateTime endDateTime
    );

    List<AppointmentEntity> findByProfessionalIdAndStartDateTimeBetween(
            UUID professionalId, LocalDateTime start, LocalDateTime end);

    List<AppointmentEntity> findByClientIdOrderByStartDateTimeDesc(UUID clientId);
}
