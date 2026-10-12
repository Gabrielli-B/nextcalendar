import { expect, seedAuth, test } from '../fixtures/auth';

/**
 * Vínculos profissional ↔ serviço (backend professional-services).
 * Sem seleção: todos os serviços aparecem. Selecionando um profissional,
 * a lista filtra pelos serviços que ele realiza.
 */
test('vínculos profissional-serviço filtram os chips de serviço', async ({ page, session }) => {
  await seedAuth(page, session);
  await page.goto('/scheduling/buscar-horario');

  // sem seleção: serviços do Gabriel (Platinado, Corte Degradê) visíveis
  await expect(page.getByText('Platinado', { exact: true }).first()).toBeVisible({ timeout: 30_000 });
  await expect(page.getByText('Corte Degradê', { exact: true }).first()).toBeVisible();

  // Bárbara selecionada: ela não realiza Platinado nem Corte Degradê (V3)
  await page.getByText('Bárbara', { exact: true }).first().click();
  await expect(page.getByText('Platinado', { exact: true })).toHaveCount(0);
  await expect(page.getByText('Corte Degradê', { exact: true })).toHaveCount(0);

  // Gabriel selecionado: os dois voltam (ele realiza os dois)
  await page.getByText('Gabriel', { exact: true }).first().click();
  await expect(page.getByText('Platinado', { exact: true }).first()).toBeVisible();
  await expect(page.getByText('Corte Degradê', { exact: true }).first()).toBeVisible();
});
