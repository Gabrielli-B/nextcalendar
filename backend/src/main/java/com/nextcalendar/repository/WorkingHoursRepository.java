package com.nextcalendar.repository;

import com.nextcalendar.entity.WorkingHoursEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.DayOfWeek;
import java.util.Optional;
import java.util.UUID;

public interface WorkingHoursRepository extends JpaRepository<WorkingHoursEntity, UUID> {

    Optional<WorkingHoursEntity> findByProfessionalIdAndDayOfWeekAndActiveTrue(UUID professionalId, DayOfWeek dayOfWeek);
}
