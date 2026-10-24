import { API, expect, fillField, seedAuth, test } from '../fixtures/auth';

test('criar serviço pela UI e vê-lo na lista', async ({ page, session }) => {
  const request = page.context().request;
  const stamp = Date.now();
  const name = `PW Corte ${stamp}`;

  await seedAuth(page, session);
  await page.goto('/servicos');
  await expect(page.getByText('Corte Degradê')).toBeVisible();

  await page.getByText('Adicionar', { exact: true }).click();
  await fillField(page.getByPlaceholder('Ex: Corte Degradê'), name);
  await fillField(page.getByPlaceholder('Ex: Cabelo, Barba, Combo'), 'Combo');
  // máscara BRL: dígitos viram centavos ("8990" → "89,90")
  await fillField(page.getByPlaceholder('0,00'), '8990');
  await page.locator('select').first().selectOption('30');
  await page.getByText('Cadastrar Serviço').click();

  await expect(page.getByText(name)).toBeVisible();

  // limpeza via API (o modal de edição usa Alert.confirm, não confiável na web)
  const list = await request.get(`${API}/establishments/99999999-9999-9999-9999-999999999999/services?size=100`);
  const body = await list.json();
  const created = (body.content ?? body).find((s: { name: string }) => s.name === name);
  if (created) {
    await request.delete(
      `${API}/establishments/99999999-9999-9999-9999-999999999999/services/${created.id}`,
      { headers: { Authorization: `Bearer ${session.token}` } }
    );
  }
});
