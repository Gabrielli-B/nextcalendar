import { setStorageItemAsync } from '../../src/utils/storage';
import { login, type LoginResponse } from '../../src/services/authServices';

/** Seed V3 (Studio Vision) — ver backend/src/main/resources/db/migration/V3__seed_studio_vision.sql */
export const ESTABLISHMENT_ID = '99999999-9999-9999-9999-999999999999';
export const PROFESSIONAL_ID = '77777777-7777-7777-7777-777777777702';
export const SEED_SERVICE_ID = '77777777-7777-7777-7777-777777777710'; // Corte Degradê, 40min
export const SEED_PRODUCT_ID = '77777777-7777-7777-7777-777777777720'; // Pomada Modeladora

const MANAGER = { email: 'gabriel@studiovision.com', password: 'senha1234' };

/** Sufixo único por execução — evita duplicidade de email/CPF em reexecuções. */
export function unique(suffix: string): string {
  return `${suffix}-${Date.now()}-${Math.floor(Math.random() * 1e6)}`;
}

/** Telefone BR único por execução (o backend exige telefone único em register). */
export function uniquePhone(): string {
  return `519${Date.now().toString().slice(-8)}`;
}

/** Loga como gestor seed e grava o token no storage (interceptor do axios lê daí). */
export async function loginAsManager(): Promise<LoginResponse> {
  const res = await login(MANAGER.email, MANAGER.password);
  await setStorageItemAsync('authToken', res.token);
  return res;
}

/**
 * Dia útil futuro (seg–sáb, como o expediente do seed), offsetDays a partir de
 * hoje. Formato YYYY-MM-DD, no fuso local — igual ao que a suíte E2E envia.
 */
export function nextWeekday(offsetDays = 14): string {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  while (d.getDay() === 0) d.setDate(d.getDate() + 1); // pula domingo
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}
