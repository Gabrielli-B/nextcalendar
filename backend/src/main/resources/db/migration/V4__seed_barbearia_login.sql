-- ═══════════════════════════════════════════════════════════════════════════
-- V4: Seed de LOGIN para o contexto BARBEARIA DEV (complementa a V2)
--
-- Problema: a V2 cria o estabelecimento 11111111-1111-1111-1111-111111111111
-- com owner_id = 00000000-0000-0000-0000-000000000001, mas NÃO cria a linha
-- correspondente em `users` (e establishments.owner_id não tem FK na V1),
-- então POST /api/v1/auth/login falhava com "Email ou senha inválidos".
-- Idem para o profissional João (professionals.user_id NULL) e a cliente
-- Maria (clients.user_id NULL).
--
-- Logins resultantes (senha única: senha1234, must_change_password = FALSE):
--   gestor       dev@barbearia.com         → MANAGER      (owner da Barbearia Dev)
--   profissional joao.barbeiro@teste.com   → PROFESSIONAL (aaaaaaaa-...-aaaaaaaaaaaa)
--   cliente      maria.cliente@teste.com   → CUSTOMER     (44444444-...-444444444444)
--
-- UUIDs FIXOS:
--   usuário gestor : 00000000-0000-0000-0000-000000000001 (já referenciado pelo V2)
--   profile GESTOR : 00000000-0000-0000-0000-000000000002
--   usuário João   : 00000000-0000-0000-0000-000000000003
--   usuário Maria  : 00000000-0000-0000-0000-000000000004
--
-- Idempotente: ON CONFLICT DO NOTHING nos INSERTs; UPDATEs só quando o vínculo
-- ainda é NULL. Não altera V1/V2/V3 (checksums do Flyway intactos).
-- Hash BCrypt = mesmo da V3 (verificado: corresponde a "senha1234").
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Usuário gestor (proprietário da Barbearia Dev) ──────────────────────────
INSERT INTO users (
    id, active, created_at, email, must_change_password, name, password_hash, role, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    TRUE,
    CURRENT_TIMESTAMP,
    'dev@barbearia.com',
    FALSE,
    'Barbearia Dev',
    '$2a$10$sDYZarICG7vc70t/.Nz1f.8025WlHpLlG0rIqjl9CI1F1nsGBSQoa',
    'MANAGER',
    CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

-- ── Profile GESTOR (consistência com EstablishmentService.create) ────────────
INSERT INTO profiles (id, created_at, owner_id, role, establishment_id)
VALUES (
    '00000000-0000-0000-0000-000000000002',
    CURRENT_TIMESTAMP,
    '00000000-0000-0000-0000-000000000001',
    'GESTOR',
    '11111111-1111-1111-1111-111111111111'
) ON CONFLICT DO NOTHING;

-- ── Usuário do profissional João ─────────────────────────────────────────────
INSERT INTO users (
    id, active, created_at, email, must_change_password, name, password_hash, role, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000003',
    TRUE,
    CURRENT_TIMESTAMP,
    'joao.barbeiro@teste.com',
    FALSE,
    'João Barbeiro',
    '$2a$10$sDYZarICG7vc70t/.Nz1f.8025WlHpLlG0rIqjl9CI1F1nsGBSQoa',
    'PROFESSIONAL',
    CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

UPDATE professionals
   SET user_id = (SELECT id FROM users WHERE email = 'joao.barbeiro@teste.com'),
       updated_at = CURRENT_TIMESTAMP
 WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
   AND user_id IS NULL
   AND EXISTS (SELECT 1 FROM users WHERE email = 'joao.barbeiro@teste.com');

-- ── Usuário da cliente Maria ─────────────────────────────────────────────────
INSERT INTO users (
    id, active, created_at, email, must_change_password, name, password_hash, role, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000004',
    TRUE,
    CURRENT_TIMESTAMP,
    'maria.cliente@teste.com',
    FALSE,
    'Maria Cliente',
    '$2a$10$sDYZarICG7vc70t/.Nz1f.8025WlHpLlG0rIqjl9CI1F1nsGBSQoa',
    'CUSTOMER',
    CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

UPDATE clients
   SET user_id = (SELECT id FROM users WHERE email = 'maria.cliente@teste.com'),
       updated_at = CURRENT_TIMESTAMP
 WHERE id = '44444444-4444-4444-4444-444444444444'
   AND user_id IS NULL
   AND EXISTS (SELECT 1 FROM users WHERE email = 'maria.cliente@teste.com');
