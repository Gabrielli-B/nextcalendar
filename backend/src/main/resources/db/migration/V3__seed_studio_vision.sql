-- ═══════════════════════════════════════════════════════════════════════════
-- V3: Seed do estabelecimento STUDIO VISION e do proprietário GABRIEL
--
-- UUIDs FIXOS (fonte da verdade para frontend/.env):
--   usuário Gabriel : 77777777-7777-7777-7777-777777777701
--   Studio Vision   : 99999999-9999-9999-9999-999999999999
--   profissional    : 77777777-7777-7777-7777-777777777702
--
-- Login: gabriel@studiovision.com / senha1234 (hash BCrypt below)
-- Idempotente: ON CONFLICT DO NOTHING em todos os INSERTs.
-- Não altera o seed V2 (Barbearia Dev) — ambos convivem no mesmo banco.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Usuário Gabriel (proprietário / MANAGER) ────────────────────────────────
INSERT INTO users (
    id, active, created_at, email, must_change_password, name, password_hash, role, updated_at
) VALUES (
    '77777777-7777-7777-7777-777777777701',
    TRUE,
    CURRENT_TIMESTAMP,
    'gabriel@studiovision.com',
    FALSE,
    'Gabriel',
    '$2a$10$sDYZarICG7vc70t/.Nz1f.8025WlHpLlG0rIqjl9CI1F1nsGBSQoa',
    'MANAGER',
    CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

-- ── Estabelecimento Studio Vision ───────────────────────────────────────────
INSERT INTO establishments (
    id, owner_id, legal_name, name, cnpj, phone, whatsapp, email,
    business_type, cep, street, number, neighborhood, city, state, complement,
    trial_start_date, trial_end_date, terms_accepted, terms_accepted_at,
    active, created_at, updated_at
) VALUES (
    '99999999-9999-9999-9999-999999999999',
    '77777777-7777-7777-7777-777777777701',
    'Studio Vision Barbearia LTDA',
    'Studio Vision',
    '12345678000199',
    '(51) 99999-8888',
    '(51) 99999-8888',
    'contato@studiovision.com',
    'Barbearia',
    '90610-010',
    'Rua Voluntários da Pátria',
    '1230',
    'Santana',
    'Porto Alegre',
    'RS',
    'Sala 1',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '30 days',
    TRUE,
    CURRENT_TIMESTAMP,
    TRUE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

-- ── Profile GESTOR do Gabriel (consistência com EstablishmentService) ───────
INSERT INTO profiles (id, created_at, owner_id, role, establishment_id)
VALUES (
    '77777777-7777-7777-7777-777777777703',
    CURRENT_TIMESTAMP,
    '77777777-7777-7777-7777-777777777701',
    'GESTOR',
    '99999999-9999-9999-9999-999999999999'
) ON CONFLICT DO NOTHING;

-- ── Profissional Gabriel (vinculado ao usuário e ao estabelecimento) ────────
INSERT INTO professionals (
    id, establishment_id, user_id, name, nickname, cpf, email, password,
    phone, gender, photo_url, commission, specialty, active, created_at, updated_at
) VALUES (
    '77777777-7777-7777-7777-777777777702',
    '99999999-9999-9999-9999-999999999999',
    '77777777-7777-7777-7777-777777777701',
    'Gabriel',
    'Gabriel',
    '98765432109',
    'gabriel@studiovision.com',
    NULL,
    '(51) 99999-8888',
    'M',
    'https://i.pravatar.cc/150?img=68',
    40,
    'Barbeiro',
    TRUE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

-- ── Horários de trabalho (seg–sáb, 09h–19h, almoço 12h–13h) ────────────────
INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777704', '77777777-7777-7777-7777-777777777702', 'MONDAY',   '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777705', '77777777-7777-7777-7777-777777777702', 'TUESDAY',  '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777706', '77777777-7777-7777-7777-777777777702', 'WEDNESDAY', '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777707', '77777777-7777-7777-7777-777777777702', 'THURSDAY', '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777708', '77777777-7777-7777-7777-777777777702', 'FRIDAY',   '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO working_hours (id, professional_id, day_of_week, start_time, end_time, break_start, break_end, active)
VALUES ('77777777-7777-7777-7777-777777777709', '77777777-7777-7777-7777-777777777702', 'SATURDAY', '09:00:00', '19:00:00', '12:00:00', '13:00:00', TRUE)
ON CONFLICT DO NOTHING;

-- ── Serviços ────────────────────────────────────────────────────────────────
INSERT INTO services (id, establishment_id, name, price, duration, category, active, created_at, updated_at)
VALUES ('77777777-7777-7777-7777-777777777710', '99999999-9999-9999-9999-999999999999', 'Corte Degradê', 75.00, 40, 'Cabelo', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

INSERT INTO services (id, establishment_id, name, price, duration, category, active, created_at, updated_at)
VALUES ('77777777-7777-7777-7777-777777777711', '99999999-9999-9999-9999-999999999999', 'Barba Terapia', 45.00, 25, 'Barba', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

INSERT INTO services (id, establishment_id, name, price, duration, category, active, created_at, updated_at)
VALUES ('77777777-7777-7777-7777-777777777712', '99999999-9999-9999-9999-999999999999', 'Platinado', 220.00, 120, 'Cabelo', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- ── Produtos ────────────────────────────────────────────────────────────────
INSERT INTO products (id, establishment_id, name, category, price, stock_quantity, active, created_at, updated_at)
VALUES ('77777777-7777-7777-7777-777777777720', '99999999-9999-9999-9999-999999999999', 'Pomada Modeladora', 'Finalizador', 55.00, 25, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

INSERT INTO products (id, establishment_id, name, category, price, stock_quantity, active, created_at, updated_at)
VALUES ('77777777-7777-7777-7777-777777777721', '99999999-9999-9999-9999-999999999999', 'Óleo para Barba', 'Barba', 49.00, 18, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;
