package com.nextcalendar.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "establishments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EstablishmentEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    // Referência ao usuário dono (FK futura para UserEntity)
    @Column(nullable = false)
    private UUID ownerId;

    // --- Dados da empresa (UC01 / tela Empresa) ---

    @Column(nullable = false)
    private String legalName;       // Razão social

    @Column(nullable = false)
    private String name;            // Nome fantasia

    @Column(nullable = false, unique = true)
    private String cnpj;            // 14 dígitos normalizados (sem pontuação)

    @Column(nullable = false)
    private String phone;           // Celular

    private String whatsapp;

    @Column(nullable = false, unique = true)
    private String email;

    private String businessType;    // Tipo de negócio (Barbearia, Salão, etc.)

    private String logoUrl;

    // --- Endereço (UC01 passo 4–8) ---

    @Embedded
    private AddressEmbeddable address;

    // --- Trial (UC01 passo 3: 30 dias) ---

    @Column(nullable = false)
    private LocalDateTime trialStartDate;

    @Column(nullable = false)
    private LocalDateTime trialEndDate;

    // --- Termos de uso ---

    @Column(nullable = false)
    private Boolean termsAccepted = false;

    private LocalDateTime termsAcceptedAt;

    // --- Controle ---

    @Column(nullable = false)
    private Boolean active = true;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
}
