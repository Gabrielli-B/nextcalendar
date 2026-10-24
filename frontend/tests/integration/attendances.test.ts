import { beforeAll, describe, expect, it } from 'vitest';
import { isAxiosError } from 'axios';
import {
  getClientAttendances,
  getEstablishmentAttendances,
} from '../../src/services/attendanceServices';
import { loginAsManager, unique } from './helpers';

describe('attendances (consultas agregadas)', () => {
  beforeAll(async () => {
    await loginAsManager();
  });

  it('gestor lista atendimentos do estabelecimento (página Spring)', async () => {
    const page = await getEstablishmentAttendances({ page: 0, size: 5 });
    expect(Array.isArray(page.content)).toBe(true);
    expect(typeof page.totalElements).toBe('number');
  });

  it('cliente inexistente → 404 (não 200 vazio)', async () => {
    const missing = '00000000-0000-4000-8000-000000000000';
    const err = await getClientAttendances(missing).then(
      () => null,
      (e) => e
    );
    expect(isAxiosError(err)).toBe(true);
    expect(err.response?.status).toBe(404);
  });

  it('cliente existente sem atendimentos → lista vazia', async () => {
    // cria um cliente pela API e consulta o histórico dele
    const { createClient } = await import('../../src/services/clientServices');
    const client = await createClient({
      name: `Hist ${unique('att')}`,
      phone: '51999990005',
      email: `${unique('att')}@e2e.test`,
      password: 'Senha1234',
      dateOfBirth: '1995-05-05',
    });
    const list = await getClientAttendances(client.id);
    expect(Array.isArray(list)).toBe(true);
    expect(list).toHaveLength(0);
  });
});
