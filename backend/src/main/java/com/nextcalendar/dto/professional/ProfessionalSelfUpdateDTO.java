package com.nextcalendar.dto.professional;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

public record ProfessionalSelfUpdateDTO(

        @Size(min = 3,max = 100,message = "O nome deve ter entre 3 a 100 caracteres.")
        String name,

        String nickname,

        @Email(message = "E-mail inválido")
        String email,

        String phone,

        String photoUrl

) { }
