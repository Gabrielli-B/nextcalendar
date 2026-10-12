import { expect, seedAuth, test } from '../fixtures/auth';

test('agenda do profissional carrega slots reais (sem mock)', async ({ page, session }) => {
  await seedAuth(page, session);
  await page.goto('/scheduling/agenda-do-profissional');

  await expect(page.getByText('Agenda', { exact: true })).toBeVisible();
  // grid 08:00–18:00 montado a partir de /appointments + blocked-times
  await expect(page.getByText('08:00')).toBeVisible();
  await expect(page.getByText('Livre').first()).toBeVisible();
  // legenda
  await expect(page.getByText('Confirmado')).toBeVisible();
  await expect(page.getByText('Bloqueado').first()).toBeVisible();
});
