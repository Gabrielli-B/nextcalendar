package com.nextcalendar.service;

import com.nextcalendar.dto.appointment.AvailableSlotsResponseDTO;
import com.nextcalendar.entity.*;
import com.nextcalendar.exception.BusinessException;
import com.nextcalendar.exception.EntityNotFoundException;
import com.nextcalendar.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class AppointmentService {

    private static final int SLOT_STEP_MINUTES = 15;

    private final AppointmentRepository appointmentRepository;
    private final WorkingHoursRepository workingHoursRepository;
    private final BlockedTimeRepository blockedTimeRepository;
    private final ProfessionalRepository professionalRepository;
    private final ServiceRepository serviceRepository;

    public AppointmentService(AppointmentRepository appointmentRepository,
                              WorkingHoursRepository workingHoursRepository,
                              BlockedTimeRepository blockedTimeRepository,
                              ProfessionalRepository professionalRepository,
                              ServiceRepository serviceRepository) {
        this.appointmentRepository = appointmentRepository;
        this.workingHoursRepository = workingHoursRepository;
        this.blockedTimeRepository = blockedTimeRepository;
        this.professionalRepository = professionalRepository;
        this.serviceRepository = serviceRepository;
    }

    @Transactional(readOnly = true)
    public AvailableSlotsResponseDTO findAvailableSlots(UUID establishmentId, UUID professionalId, UUID serviceId, LocalDate date) {
        ProfessionalEntity professional = professionalRepository.findByIdAndEstablishmentId(professionalId, establishmentId)
                .orElseThrow(() -> new EntityNotFoundException("Profissional", professionalId));

        ServiceEntity service = serviceRepository.findByIdAndEstablishmentAndActiveTrue(serviceId, professional.getEstablishment())
                .orElseThrow(() -> new EntityNotFoundException("Serviço", serviceId));

        WorkingHoursEntity workingHours = workingHoursRepository.findByProfessionalIdAndDayOfWeekAndActiveTrue(professionalId, date.getDayOfWeek())
                .orElseThrow(() -> new BusinessException("O profissional não atende neste dia da semana."));

        int durationMinutes = service.getDuration();

        LocalDateTime dayStart = date.atStartOfDay();
        LocalDateTime dayEnd = date.plusDays(1).atStartOfDay();

        List<AppointmentEntity> existingAppointments = appointmentRepository.findByProfessionalIdAndStartDateTimeBetween(professionalId, dayStart, dayEnd);

        List<BlockedTimeEntity> blockedTimes = blockedTimeRepository.findByProfessionalIdAndStartDateTimeLessThanAndEndDateTimeGreaterThan(professionalId, dayEnd, dayStart);
        List<LocalTime> slots = new ArrayList<>();
        LocalTime cursor = workingHours.getStartTime();

        while (!cursor.plusMinutes(durationMinutes).isAfter(workingHours.getEndTime())) {

            LocalTime slotEnd = cursor.plusMinutes(durationMinutes);
            LocalDateTime slotStartDT = date.atTime(cursor);
            LocalDateTime slotEndDT = date.atTime(slotEnd);

            boolean duringLunch = workingHours.getBreakStart() != null
                    && cursor.isBefore(workingHours.getBreakEnd())
                    && slotEnd.isAfter(workingHours.getBreakStart());


            boolean conflictsWithAppointment = existingAppointments.stream().anyMatch(a ->
                    a.getStatus() != AppointmentStatus.CANCELLED
                            && slotStartDT.isBefore(a.getEndDateTime())
                            && slotEndDT.isAfter(a.getStartDateTime()));

            boolean conflictsWithBlock = blockedTimes.stream().anyMatch(b ->
                    slotStartDT.isBefore(b.getEndDateTime()) && slotEndDT.isAfter(b.getStartDateTime()));

            if (!duringLunch && !conflictsWithAppointment && !conflictsWithBlock) {
                slots.add(cursor);
            }

            cursor = cursor.plusMinutes(SLOT_STEP_MINUTES);
        }

        return new AvailableSlotsResponseDTO(
                service.getId(),
                service.getName(),
                service.getPrice(),
                service.getDuration(),
                date,
                slots
        );
    }
}
