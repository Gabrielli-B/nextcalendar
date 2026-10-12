import { expect, seedAuth, test } from '../fixtures/auth';

test('busca de horario abre sem loop de re-render', async ({ page, session }) => {
  const errors: string[] = [];
  page.on('pageerror', (e) => errors.push(e.message));

  await seedAuth(page, session);
  await page.goto('/scheduling/buscar-horario');
  await expect(page.getByText(/Buscar hor/).first()).toBeVisible({ timeout: 30_000 });
  await page.waitForTimeout(3000);

  console.log('pageerrors:', errors);
  expect(errors).toEqual([]);
  await expect(page.locator('body')).not.toContainText('Too many re-renders');
});
