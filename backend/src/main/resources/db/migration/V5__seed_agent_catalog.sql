-- ═══════════════════════════════════════════════════════════════════════════
-- V5: Catálogo do agente Lia copiado para o backend + vínculo profissional↔serviço
--
-- Fonte: AgenteBarbearia/AgenteBarbearia.Api/Services/BarbeariaSeed.cs
-- (Mongo do agente: 41 serviços + profissionais Gabriel e Bárbara).
--
-- O que esta migration faz:
--   1. Cria a tabela professional_services (vínculo profissional ↔ serviço).
--   2. Desativa os serviços de teste acumulados (E2E / Vitest / Playwright).
--   3. Cadastra a profissional BÁRBARA (Studio Vision) + horários (seg–sáb).
--   4. Cadastra os 41 serviços do catálogo do agente (Studio Vision).
--   5. Grava os vínculos: Gabriel 16 (13 do agente + 3 do seed V3),
--      Bárbara 33 — exatamente como no Mongo do agente.
--
-- UUIDs FIXOS:
--   profissional Bárbara : 77777777-7777-7777-7777-777777777740
--   horários Bárbara     : 77777777-7777-7777-7777-777777777741..7746
--   serviços do agente   : 88888888-8888-8888-8888-888888880001..0041
--
-- Regra de compatibilidade dos vínculos (aplicada no backend, em
-- AppointmentService): profissional SEM vínculos atende todos os serviços e
-- serviço SEM vínculos aceita todos os profissionais — assim os
-- estabelecimentos de teste (sem vínculos) continuam funcionando.
--
-- Idempotente: ON CONFLICT DO NOTHING em todos os INSERTs. Não altera o
-- checksum das V1–V4.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── 1. Tabela de vínculo profissional ↔ serviço ─────────────────────────────
CREATE TABLE professional_services (
    professional_id uuid NOT NULL,
    service_id uuid NOT NULL,
    CONSTRAINT professional_services_pkey PRIMARY KEY (professional_id, service_id),
    CONSTRAINT fk_professional_services_professional FOREIGN KEY (professional_id)
        REFERENCES professionals (id),
    CONSTRAINT fk_professional_services_service FOREIGN KEY (service_id)
        REFERENCES services (id)
);

-- ── 2. Desativa serviços de teste acumulados ────────────────────────────────
UPDATE services
   SET active = FALSE,
       updated_at = CURRENT_TIMESTAMP
 WHERE active
   AND (name LIKE 'E2E-Servico-%'
        OR name LIKE 'Serviço Vitest-%'
        OR name LIKE 'PW Corte-%');

-- ── 3. Profissional Bárbara (Studio Vision) ─────────────────────────────────
INSERT INTO professionals (
    id, establishment_id, user_id, name, nickname, cpf, email, password,
    phone, gender, photo_url, commission, specialty, active, created_at, updated_at
) VALUES (
    '77777777-7777-7777-7777-777777777740',
    '99999999-9999-9999-9999-999999999999',
    NULL,
    'Bárbara',
    'Bárbara',
    '33445566770',
    'barbara@studiovision.com',
    NULL,
    '(51) 99999-7777',
    'F',
    'https://i.pravatar.cc/150?img=47',
    40,
    'Cabeleireira',
    TRUE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

-- ── 4. Horários da Bárbara (seg–sáb, 09h–19h, almoço 12h–13h, como o Gabriel) ─
INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777741', '77777777-7777-7777-7777-777777777740', 'MONDAY',   '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777742', '77777777-7777-7777-7777-777777777740', 'TUESDAY',  '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777743', '77777777-7777-7777-7777-777777777740', 'WEDNESDAY', '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777744', '77777777-7777-7777-7777-777777777740', 'THURSDAY', '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777745', '77777777-7777-7777-7777-777777777740', 'FRIDAY',   '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777746', '77777777-7777-7777-7777-777777777740', 'SATURDAY', '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

-- ── 5. Serviços do catálogo do agente (41) ──────────────────────────────────
INSERT INTO services (id, active, category, created_at, duration, name, price, updated_at, establishment_id)
VALUES
    ('88888888-8888-8888-8888-888888880001', TRUE, 'Adicional',  CURRENT_TIMESTAMP,  30, 'Adicional cabelo com mega hair',         35.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880002', TRUE, 'Adicional',  CURRENT_TIMESTAMP,  30, 'Adicional de serviço',                   50.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880003', TRUE, 'Barba',      CURRENT_TIMESTAMP,  30, 'Barba',                                  55.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880004', TRUE, 'Tratamentos', CURRENT_TIMESTAMP,  90, 'Blindagem',                              220.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880005', TRUE, 'Tratamentos', CURRENT_TIMESTAMP,  60, 'Blindagem / selagem',                    750.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880006', TRUE, 'Estética',   CURRENT_TIMESTAMP,  15, 'Buço',                                   25.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880007', TRUE, 'Escova',     CURRENT_TIMESTAMP,  30, 'Chapinha',                               50.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880008', TRUE, 'Coloração',  CURRENT_TIMESTAMP, 120, 'Coloração pessoal',                      390.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880009', TRUE, 'Combo',      CURRENT_TIMESTAMP,  60, 'Combo Corte Com Hidratação e Escova',     160.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880010', TRUE, 'Combo',      CURRENT_TIMESTAMP,  60, 'Combo mão e pé',                         85.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880011', TRUE, 'Combo',      CURRENT_TIMESTAMP,  30, 'Combo raspado + barba',                  90.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880012', TRUE, 'Cabelo',     CURRENT_TIMESTAMP,  60, 'Corte com Visagismo',                    250.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880013', TRUE, 'Cabelo',     CURRENT_TIMESTAMP,  30, 'Corte de franja',                        40.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880014', TRUE, 'Combo',      CURRENT_TIMESTAMP,  90, 'Corte e Barba com Visagismo',            400.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880015', TRUE, 'Combo',      CURRENT_TIMESTAMP,  60, 'Corte e barba',                          120.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880016', TRUE, 'Cabelo',     CURRENT_TIMESTAMP,  60, 'Corte feminino',                         95.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880017', TRUE, 'Cabelo',     CURRENT_TIMESTAMP,  30, 'Corte masculino',                        70.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880018', TRUE, 'Cabelo',     CURRENT_TIMESTAMP,  30, 'Corte raspado máquina',                  35.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880019', TRUE, 'Estética',   CURRENT_TIMESTAMP,  30, 'Dep. orelha e nariz',                    0.00,   CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880020', TRUE, 'Escova',     CURRENT_TIMESTAMP,  60, 'Escova Curto com baby liss',             120.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880021', TRUE, 'Escova',     CURRENT_TIMESTAMP,  60, 'Escova Medio/Longo com baby liss',       130.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880022', TRUE, 'Escova',     CURRENT_TIMESTAMP,  60, 'Escova curta',                           75.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880023', TRUE, 'Escova',     CURRENT_TIMESTAMP,  60, 'Escova longa',                           80.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880024', TRUE, 'Escova',     CURRENT_TIMESTAMP,  60, 'Escova media',                           75.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880025', TRUE, 'Unhas',      CURRENT_TIMESTAMP,  60, 'Esmaltação em Gel mão',                  90.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880026', TRUE, 'Unhas',      CURRENT_TIMESTAMP,  60, 'Esmaltação em Gel pé',                   100.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880027', TRUE, 'Tratamentos', CURRENT_TIMESTAMP,  60, 'Hidratação com Escova Curto e Medio',     120.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880028', TRUE, 'Tratamentos', CURRENT_TIMESTAMP,  60, 'Hidratação com Escova Longo',            130.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880029', TRUE, 'Escova',     CURRENT_TIMESTAMP,  30, 'Lavado S/ escova',                       30.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880030', TRUE, 'Estética',   CURRENT_TIMESTAMP,  60, 'Maquiagem express',                      130.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880031', TRUE, 'Estética',   CURRENT_TIMESTAMP,  60, 'Maquiagem festa/com cílios',             170.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880032', TRUE, 'Unhas',      CURRENT_TIMESTAMP,  30, 'Mão francesinha',                        42.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880033', TRUE, 'Unhas',      CURRENT_TIMESTAMP,  30, 'Mão simples',                            40.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880034', TRUE, 'Cabelo',     CURRENT_TIMESTAMP,  30, 'Pezinho',                                20.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880035', TRUE, 'Tratamentos', CURRENT_TIMESTAMP,  30, 'Progressiva masculina',                  150.00, CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880036', TRUE, 'Unhas',      CURRENT_TIMESTAMP,  30, 'Pé simples',                             50.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880037', TRUE, 'Tratamentos', CURRENT_TIMESTAMP,  60, 'Remoção Alongamento',                    95.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880038', TRUE, 'Unhas',      CURRENT_TIMESTAMP,  30, 'Remoção de esmaltação em gel',           40.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880039', TRUE, 'Estética',   CURRENT_TIMESTAMP,  30, 'Sobrancelha',                            40.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880040', TRUE, 'Estética',   CURRENT_TIMESTAMP,  15, 'Sobrancelha designer',                   45.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999'),
    ('88888888-8888-8888-8888-888888880041', TRUE, 'Estética',   CURRENT_TIMESTAMP,  15, 'Sobrancelha excesso',                    35.00,  CURRENT_TIMESTAMP, '99999999-9999-9999-9999-999999999999')
ON CONFLICT DO NOTHING;

-- ── 6. Vínculos — Gabriel (13 do agente + 3 serviços do seed V3) ─────────────
INSERT INTO professional_services (professional_id, service_id)
VALUES
    -- 13 serviços do agente (Mongo: BarbeariaSeed)
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880003'), -- Barba
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880011'), -- Combo raspado + barba
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880015'), -- Corte e barba
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880017'), -- Corte masculino
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880018'), -- Corte raspado máquina
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880004'), -- Blindagem
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880005'), -- Blindagem / selagem
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880012'), -- Corte com Visagismo
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880014'), -- Corte e Barba com Visagismo
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880019'), -- Dep. orelha e nariz
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880034'), -- Pezinho
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880035'), -- Progressiva masculina
    ('77777777-7777-7777-7777-777777777702', '88888888-8888-8888-8888-888888880039'), -- Sobrancelha
    -- 3 serviços do seed V3 (já existentes no backend)
    ('77777777-7777-7777-7777-777777777702', '77777777-7777-7777-7777-777777777710'), -- Corte Degradê
    ('77777777-7777-7777-7777-777777777702', '77777777-7777-7777-7777-777777777711'), -- Barba Terapia
    ('77777777-7777-7777-7777-777777777702', '77777777-7777-7777-7777-777777777712')  -- Platinado
ON CONFLICT DO NOTHING;

-- ── 7. Vínculos — Bárbara (33 serviços do agente) ───────────────────────────
INSERT INTO professional_services (professional_id, service_id)
VALUES
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880003'), -- Barba
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880011'), -- Combo raspado + barba
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880015'), -- Corte e barba
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880017'), -- Corte masculino
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880018'), -- Corte raspado máquina
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880001'), -- Adicional cabelo com mega hair
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880002'), -- Adicional de serviço
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880006'), -- Buço
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880007'), -- Chapinha
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880008'), -- Coloração pessoal
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880009'), -- Combo Corte Com Hidratação e Escova
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880010'), -- Combo mão e pé
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880013'), -- Corte de franja
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880016'), -- Corte feminino
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880022'), -- Escova curta
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880020'), -- Escova Curto com baby liss
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880023'), -- Escova longa
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880024'), -- Escova media
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880021'), -- Escova Medio/Longo com baby liss
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880025'), -- Esmaltação em Gel mão
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880026'), -- Esmaltação em Gel pé
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880027'), -- Hidratação com Escova Curto e Medio
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880028'), -- Hidratação com Escova Longo
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880029'), -- Lavado S/ escova
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880032'), -- Mão francesinha
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880033'), -- Mão simples
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880030'), -- Maquiagem express
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880031'), -- Maquiagem festa/com cílios
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880036'), -- Pé simples
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880037'), -- Remoção Alongamento
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880038'), -- Remoção de esmaltação em gel
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880040'), -- Sobrancelha designer
    ('77777777-7777-7777-7777-777777777740', '88888888-8888-8888-8888-888888880041')  -- Sobrancelha excesso
ON CONFLICT DO NOTHING;
