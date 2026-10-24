import { API, expect, fillField, seedAuth, test } from '../fixtures/auth';

test('busca de clientes encontra cliente cadastrado via API', async ({ page, session }) => {
  const request = page.context().request;
  const stamp = Date.now();
  const name = `E2E Playwright ${stamp}`;
  const created = await request.post(`${API}/clients`, {
    headers: { Authorization: `Bearer ${session.token}` },
    data: {
      name,
      phone: `519${stamp.toString().slice(-8)}`,
      email: `e2e-pw-${stamp}@e2e.test`,
      password: 'Senha1234',
      dateOfBirth: '1990-01-01',
    },
  });
  expect(created.ok(), `POST /clients → ${created.status()}`).toBeTruthy();

  await seedAuth(page, session);
  await page.goto('/clientes');
  await fillField(page.getByPlaceholder('Buscar cliente'), name);
  await expect(page.getByText(name).first()).toBeVisible();
});
