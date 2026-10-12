import { beforeAll, describe, expect, it } from 'vitest';
import {
  criarServico,
  atualizarServico,
  excluirServico,
  listarServicos,
} from '../../src/services/serviceServices';
import { ESTABLISHMENT_ID, loginAsManager, unique } from './helpers';

describe('services (catálogo do Studio Vision)', () => {
  let serviceId = '';
  const name = unique('Serviço Vitest');

  beforeAll(async () => {
    // serviceServices usa fetch "cru" (sem Authorization) — se o backend um dia
    // exigir token aqui, este teste é o primeiro a acusar.
    await loginAsManager();
  });

  it('listarServicos traz os seeds (Corte Degradê etc.)', async () => {
    const services = await listarServicos(ESTABLISHMENT_ID);
    expect(services.length).toBeGreaterThanOrEqual(3);
    expect(services.some((s) => s.name === 'Corte Degradê')).toBe(true);
  });

  it('criar → atualizar → excluir roundtrip', async () => {
    const created = await criarServico(ESTABLISHMENT_ID, {
      name,
      price: 55.5,
      duration: 30,
      category: 'Cabelo',
    });
    serviceId = created.id;
    expect(created.price).toBe(55.5);

    const updated = await atualizarServico(ESTABLISHMENT_ID, serviceId, {
      name,
      price: 60,
      duration: 30,
      category: 'Cabelo',
    });
    expect(updated.price).toBe(60);

    await excluirServico(ESTABLISHMENT_ID, serviceId);
    const after = await listarServicos(ESTABLISHMENT_ID);
    expect(after.some((s) => s.id === serviceId)).toBe(false);
  });
});
