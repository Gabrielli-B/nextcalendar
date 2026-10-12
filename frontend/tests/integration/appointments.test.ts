import { beforeAll, describe, expect, it } from 'vitest';
import {
  cancelAppointment,
  createAppointment,
  getAvailableSlots,
  getEstablishmentAppointments,
} from '../../src/services/appointmentServices';
import {
  ESTABLISHMENT_ID,
  PROFESSIONAL_ID,
  SEED_SERVICE_ID,
  loginAsManager,
  nextWeekday,
} from './helpers';

describe('appointments (slots → create → cancel)', () => {
  const date = nextWeekday();

  beforeAll(async () => {
    await loginAsManager();
  });

  it('available-slots devolve horários num dia útil do profissional seed', async () => {
    const res = await getAvailableSlots(ESTABLISHMENT_ID, PROFESSIONAL_ID, SEED_SERVICE_ID, date);
    expect(res.serviceId).toBe(SEED_SERVICE_ID);
    expect(Array.isArray(res.slots)).toBe(true);
    expect(res.slots.length).toBeGreaterThan(0);
  });

  it('create + cancel de agendamento com cliente avulso', async () => {
    const slots = await getAvailableSlots(ESTABLISHMENT_ID, PROFESSIONAL_ID, SEED_SERVICE_ID, date);
    const appointment = await createAppointment(ESTABLISHMENT_ID, {
      professionalId: PROFESSIONAL_ID,
      serviceId: SEED_SERVICE_ID,
      clientNameFallback: 'Avulso Vitest',
      clientPhoneFallback: '51999990003',
      // slots vêm como "HH:mm:ss" e o backend espera data local sem timezone
      startDateTime: `${date}T${slots.slots[0]}`,
    });
    expect(appointment.id).toBeTruthy();
    expect(appointment.status).toBe('SCHEDULED');

    const cancelled = await cancelAppointment(ESTABLISHMENT_ID, appointment.id);
    expect(cancelled.status).toBe('CANCELLED');

    // o slot cancelado voltou a estar livre
    const after = await getAvailableSlots(ESTABLISHMENT_ID, PROFESSIONAL_ID, SEED_SERVICE_ID, date);
    expect(after.slots).toContain(slots.slots[0]);
  });

  it('listagem do estabelecimento por dia devolve array', async () => {
    const list = await getEstablishmentAppointments(ESTABLISHMENT_ID, date);
    expect(Array.isArray(list)).toBe(true);
  });
});
