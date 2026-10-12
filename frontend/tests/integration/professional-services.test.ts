import { isAxiosError } from 'axios';
import { beforeAll, describe, expect, it } from 'vitest';
import { createAppointment, getAvailableSlots } from '../../src/services/appointmentServices';
import {
  getProfessionalServiceLinks,
  replaceProfessionalServiceLinks,
} from '../../src/services/professionalServiceServices';
import { ESTABLISHMENT_ID, PROFESSIONAL_ID, SEED_SERVICE_ID, loginAsManager, nextWeekday } from './helpers';

/** Bárbara (seed V5) — não realiza Corte Degradê (V3, só Gabriel). */
const BARBARA_ID = '77777777-7777-7777-7777-777777777740';

/** Serviço do agente que só a Bárbara realiza (Gabriel não). */
const AGENT_SERVICE_ID = '88888888-8888-8888-8888-888888880001';

/** Seed V2 (Barbearia Dev) — estabelecimento SEM nenhum vínculo. */
const DEV_EST_ID = '11111111-1111-1111-1111-111111111111';
const DEV_PRO_ID = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const DEV_SERVICE_ID = '22222222-2222-2222-2222-222222222222';

const MISSING_UUID = '00000000-0000-4000-8000-000000000000';

async function expectApiError(p: Promise<unknown>, status: number, contains: string) {
  const err = await p.then(() => null).catch((e: unknown) => e);
  expect(isAxiosError(err)).toBe(true);
  if (isAxiosError(err)) {
    expect(err.response?.status).toBe(status);
    expect(String(err.response?.data)).toContain(contains);
  }
}

describe('professional-services (vínculos profissional ↔ serviço)', () => {
  beforeAll(async () => {
    await loginAsManager();
  });

  it('lista os pares do seed (Gabriel e Bárbara)', async () => {
    const links = await getProfessionalServiceLinks(ESTABLISHMENT_ID);
    expect(Array.isArray(links)).toBe(true);

    const gabriel = links.filter((l) => l.professionalId === PROFESSIONAL_ID);
    expect(gabriel.length).toBeGreaterThanOrEqual(13);
    expect(gabriel.some((l) => l.serviceId === SEED_SERVICE_ID)).toBe(true);

    const barbara = links.filter((l) => l.professionalId === BARBARA_ID);
    expect(barbara.length).toBeGreaterThanOrEqual(1);
    expect(barbara.some((l) => l.serviceId === SEED_SERVICE_ID)).toBe(false);
  });

  it('slots: par inválido → 400; par válido → 200', async () => {
    const date = nextWeekday();

    await expectApiError(
      getAvailableSlots(ESTABLISHMENT_ID, BARBARA_ID, SEED_SERVICE_ID, date),
      400,
      'não realiza o serviço'
    );

    await expectApiError(
      getAvailableSlots(ESTABLISHMENT_ID, PROFESSIONAL_ID, AGENT_SERVICE_ID, date),
      400,
      'não realiza o serviço'
    );

    const ok = await getAvailableSlots(ESTABLISHMENT_ID, PROFESSIONAL_ID, SEED_SERVICE_ID, date);
    expect(ok.slots.length).toBeGreaterThan(0);
  });

  it('slots: estabelecimento sem vínculos atende tudo (wildcard)', async () => {
    const date = nextWeekday();
    const res = await getAvailableSlots(DEV_EST_ID, DEV_PRO_ID, DEV_SERVICE_ID, date);
    expect(res.serviceId).toBe(DEV_SERVICE_ID);
    expect(Array.isArray(res.slots)).toBe(true);
  });

  it('createAppointment com par inválido → 400 e não cria', async () => {
    const date = nextWeekday();
    await expectApiError(
      createAppointment(ESTABLISHMENT_ID, {
        professionalId: BARBARA_ID,
        serviceId: SEED_SERVICE_ID,
        clientNameFallback: 'Vitest Vinculo',
        clientPhoneFallback: '51999990099',
        startDateTime: `${date}T10:00:00`,
      }),
      400,
      'não realiza o serviço'
    );
  });

  it('PUT substitui os vínculos e restaura o seed ao final', async () => {
    const before = (await getProfessionalServiceLinks(ESTABLISHMENT_ID)).filter(
      (l) => l.professionalId === BARBARA_ID
    );
    expect(before.length).toBeGreaterThan(0);

    const subset = [before[0].serviceId];
    try {
      const replaced = await replaceProfessionalServiceLinks(ESTABLISHMENT_ID, BARBARA_ID, subset);
      expect(replaced).toHaveLength(1);
      expect(replaced[0].serviceId).toBe(subset[0]);

      const mid = (await getProfessionalServiceLinks(ESTABLISHMENT_ID)).filter(
        (l) => l.professionalId === BARBARA_ID
      );
      expect(mid).toHaveLength(1);
      expect(mid[0].serviceId).toBe(subset[0]);
    } finally {
      await replaceProfessionalServiceLinks(
        ESTABLISHMENT_ID,
        BARBARA_ID,
        before.map((l) => l.serviceId)
      );
    }

    const after = (await getProfessionalServiceLinks(ESTABLISHMENT_ID)).filter(
      (l) => l.professionalId === BARBARA_ID
    );
    expect(after).toHaveLength(before.length);
  });

  it('PUT com serviço desconhecido → 404 (sem alterar os vínculos)', async () => {
    const before = (await getProfessionalServiceLinks(ESTABLISHMENT_ID)).filter(
      (l) => l.professionalId === BARBARA_ID
    );

    await expectApiError(
      replaceProfessionalServiceLinks(ESTABLISHMENT_ID, BARBARA_ID, [MISSING_UUID]),
      404,
      'não encontrada'
    );

    await expectApiError(
      replaceProfessionalServiceLinks(ESTABLISHMENT_ID, MISSING_UUID, []),
      404,
      'não encontrada'
    );

    const after = (await getProfessionalServiceLinks(ESTABLISHMENT_ID)).filter(
      (l) => l.professionalId === BARBARA_ID
    );
    expect(after).toHaveLength(before.length);
  });
});
