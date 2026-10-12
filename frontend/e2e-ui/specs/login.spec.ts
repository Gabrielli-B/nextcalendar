import { expect, fillField, test, MANAGER } from '../fixtures/auth';

test('senha errada mostra mensagem de erro', async ({ page }) => {
  await page.goto('/login');
  await fillField(page.getByPlaceholder('Digite seu E-mail'), MANAGER.email);
  await fillField(page.getByPlaceholder('Digite sua senha'), 'senha-errada');
  await page.getByText('Entrar', { exact: true }).click();
  await expect(page.getByText(/Email ou senha/i)).toBeVisible();
});

test('login válido leva ao home do gestor', async ({ page }) => {
  await page.goto('/login');
  await fillField(page.getByPlaceholder('Digite seu E-mail'), MANAGER.email);
  await fillField(page.getByPlaceholder('Digite sua senha'), MANAGER.password);
  await page.getByText('Entrar', { exact: true }).click();
  await page.waitForURL('**/homeEmpresa');
  await expect(page).toHaveURL(/homeEmpresa/);
});
