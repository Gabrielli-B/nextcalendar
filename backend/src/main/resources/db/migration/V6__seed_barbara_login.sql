-- ═══════════════════════════════════════════════════════════════════════════
-- V6: Seed de LOGIN para a profissional BÁRBARA (complementa a V5)
--
-- A V5 cria a profissional Bárbara (77777777-7777-7777-7777-777777777740) no
-- Studio Vision, mas sem linha em `users` (professionals.user_id NULL),
-- então não havia login para acessar a área do profissional.
--
-- Login resultante (senha: senha1234, must_change_password = FALSE):
--   profissional barbara@studiovision.com → PROFESSIONAL (...-...-...-7740)
--
-- UUIDs FIXOS:
--   usuário Bárbara: 77777777-7777-7777-7777-777777777741
--
-- Idempotente: ON CONFLICT DO NOTHING no INSERT; UPDATE só quando o vínculo
-- ainda é NULL. Não altera V1..V5 (checksums do Flyway intactos).
-- Hash BCrypt = mesmo da V3/V4 (corresponde a "senha1234").
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Usuário da profissional Bárbara ─────────────────────────────────────────
INSERT INTO users (
    id, active, created_at, email, must_change_password, name, password_hash, role, updated_at
) VALUES (
    '77777777-7777-7777-7777-777777777741',
    TRUE,
    CURRENT_TIMESTAMP,
    'barbara@studiovision.com',
    FALSE,
    'Bárbara',
    '$2a$10$sDYZarICG7vc70t/.Nz1f.8025WlHpLlG0rIqjl9CI1F1nsGBSQoa',
    'PROFESSIONAL',
    CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

-- ── Vincula a profissional ao usuário ───────────────────────────────────────
UPDATE professionals
   SET user_id = (SELECT id FROM users WHERE email = 'barbara@studiovision.com'),
       updated_at = CURRENT_TIMESTAMP
 WHERE id = '77777777-7777-7777-7777-777777777740'
   AND user_id IS NULL
   AND EXISTS (SELECT 1 FROM users WHERE email = 'barbara@studiovision.com');
