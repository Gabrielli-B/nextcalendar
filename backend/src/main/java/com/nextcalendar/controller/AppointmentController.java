package com.nextcalendar.controller;

import com.nextcalendar.dto.appointment.AvailableSlotsResponseDTO;
import com.nextcalendar.service.AppointmentService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/establishments/{establishmentId}/appointments")
public class AppointmentController {

    private final AppointmentService appointmentService;

    public AppointmentController(AppointmentService appointmentService) {
        this.appointmentService = appointmentService;
    }

    @GetMapping("/available-slots")
    public AvailableSlotsResponseDTO getAvailableSlots(
            @PathVariable UUID establishmentId,
            @RequestParam UUID professionalId,
            @RequestParam UUID serviceId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {return appointmentService.findAvailableSlots(establishmentId, professionalId, serviceId, date);}


}

