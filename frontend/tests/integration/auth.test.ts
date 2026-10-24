import { describe, expect, it } from 'vitest';
import { isAxiosError } from 'axios';
import { login, register } from '../../src/services/authServices';
import { unique, uniquePhone, loginAsManager } from './helpers';

describe('auth (services reais → backend)', () => {
  it('login do gestor seed retorna token e usuário', async () => {
    const res = await loginAsManager();
    expect(res.token).toBeTruthy();
    expect(res.user.email).toBe('gabriel@studiovision.com');
    expect(res.user.role).toBe('MANAGER');
    expect(res.user.mustChangePassword).toBe(false);
  });

  it('senha errada → 400 com mensagem (sem vazar qual campo)', async () => {
    const err = await login('gabriel@studiovision.com', 'senha-errada').then(
      () => null,
      (e) => e
    );
    expect(isAxiosError(err)).toBe(true);
    expect(err.response?.status).toBe(400);
    expect(String(err.response?.data)).toContain('Email ou senha');
  });

  it('register de CUSTOMER roundtrip (email único por execução)', async () => {
    const email = `${unique('cliente')}@e2e.test`;
    const res = await register('Cliente Vitest', email, 'Senha1234', 'CUSTOMER', uniquePhone());
    expect(res.token).toBeTruthy();
    expect(res.user.email).toBe(email);
    expect(res.user.role).toBe('CUSTOMER');

    const again = await login(email, 'Senha1234');
    expect(again.user.id).toBe(res.user.id);
  });
});
