import { expect, test as base, type APIRequestContext, type Locator, type Page } from '@playwright/test';

const API = 'http://localhost:8080/api/v1';

/** Gestor seed — migration V3 (Studio Vision). */
export const MANAGER = { email: 'gabriel@studiovision.com', password: 'senha1234' };

export type Session = { token: string; user: { id: string; name: string; role: string } };

/** Login via API (mesmo caminho que o app usa). */
export async function apiLogin(
  request: APIRequestContext,
  creds: { email: string; password: string } = MANAGER
): Promise<Session> {
  const res = await request.post(`${API}/auth/login`, { data: creds });
  expect(res.ok(), `login ${creds.email} falhou: ${res.status()}`).toBeTruthy();
  return res.json();
}

/** Grava token+user no localStorage ANTES do app carregar (caminho web do storage). */
export async function seedAuth(page: Page, session: Session): Promise<void> {
  await page.addInitScript((s) => {
    window.localStorage.setItem('authToken', s.token);
    window.localStorage.setItem('authUser', JSON.stringify(s.user));
  }, session);
}

/**
 * Preenche um campo do app.
 *
 * O `fill()` do Playwright não atualiza o estado do React no `TextInput`
 * do react-native-web (o valor some no re-render seguinte). Digitar tecla a
 * tecla dispara os eventos nativos que o `onChangeText` espera.
 */
export async function fillField(locator: Locator, text: string): Promise<void> {
  await locator.click();
  await locator.press(process.platform === 'darwin' ? 'Meta+a' : 'Control+a');
  await locator.press('Delete');
  await locator.pressSequentially(text, { delay: 10 });
}

/** Navega já autenticado como gestor. */
export async function gotoAsManager(page: Page, path: string): Promise<Session> {
  const session = await apiLogin(await page.context().request);
  await seedAuth(page, session);
  await page.goto(path);
  return session;
}

export const test = base.extend<{ session: Session }>({
  session: async ({ request }, use) => {
    await use(await apiLogin(request));
  },
});

export const auth = test;

export { expect, API };
