import { DEFAULT_ESTABLISHMENT_ID } from '../constants/establishment';
import {
  cancelAppointment as cancelAppointmentApi,
  createAppointment as createAppointmentApi,
  getEstablishmentAppointments,
} from './appointmentServices';
import { createBlockedTime, listBlockedTimes } from './blockedTimesServices';
import { getActiveProfessionals, getProfessionalMe } from './professionalServices';
import { listarServicos } from './serviceServices';

export type SlotStatus = 'confirmed' | 'encaixe' | 'blocked' | 'free';

export type AgendaSlot = {
  /** Chave estável do slot: "${date}T${HH:mm}" (ex.: "2026-10-13T09:30"). */
  id: string;
  /** "HH:mm" — horário de início do slot no grid da tela. */
  time: string;
  status: SlotStatus;
  clientName?: string;
  service?: string;
  /** Profissional dono do slot — usado para bloquear/criar agendamento. */
  professionalId: string;
  /** Presente quando o slot tem agendamento (confirmed/encaixe). */
  appointmentId?: string;
};

export type CreateAppointmentInput = {
  slot: AgendaSlot;
  clientName: string;
  /** Nome exato (case-insensitive) de um serviço do catálogo do estabelecimento. */
  serviceName: string;
  isEncaixe: boolean;
};

const GRID_START_HOUR = 8;
const GRID_END_HOUR = 18;
const STEP_MINUTES = 30;

/** Resolve o profissional da agenda: o informado, o do usuário logado, ou o primeiro ativo. */
async function resolveProfessionalId(professionalId?: string): Promise<string> {
  if (professionalId) return professionalId;
  try {
    const me = await getProfessionalMe();
    return me.id;
  } catch {
    const page = await getActiveProfessionals(DEFAULT_ESTABLISHMENT_ID, 0, 50);
    const first = page.content[0];
    if (!first) throw new Error('Nenhum profissional ativo no estabelecimento.');
    return first.id;
  }
}

function minutesOf(iso: string): number {
  const d = new Date(iso);
  return d.getHours() * 60 + d.getMinutes();
}

function overlaps(aStart: number, aEnd: number, bStart: number, bEnd: number): boolean {
  return aStart < bEnd && bStart < aEnd;
}

function pad(n: number): string {
  return String(n).padStart(2, '0');
}

/**
 * Agenda do profissional num dia (grid 08:00–18:00, slots de 30min):
 * agendamentos reais (confirmed/encaixe), bloqueios reais (blocked) e o resto livre.
 */
export async function getAgendaByDate(
  date: string,
  professionalId?: string
): Promise<AgendaSlot[]> {
  const profId = await resolveProfessionalId(professionalId);
  const [appointments, blockedTimes] = await Promise.all([
    getEstablishmentAppointments(DEFAULT_ESTABLISHMENT_ID, date, profId),
    listBlockedTimes(DEFAULT_ESTABLISHMENT_ID, profId),
  ]);

  const dayStart = new Date(`${date}T00:00:00`).getTime();
  const dayEnd = dayStart + 24 * 60 * 60 * 1000;
  const appts = appointments.filter((a) => a.status !== 'CANCELLED');
  const blocks = blockedTimes.filter((b) => {
    const start = new Date(b.startDateTime).getTime();
    return start >= dayStart && start < dayEnd;
  });

  const slots: AgendaSlot[] = [];
  for (let m = GRID_START_HOUR * 60; m < GRID_END_HOUR * 60; m += STEP_MINUTES) {
    const slotEnd = m + STEP_MINUTES;
    const time = `${pad(Math.floor(m / 60))}:${pad(m % 60)}`;
    const id = `${date}T${time}`;

    const appt = appts.find((a) =>
      overlaps(minutesOf(a.startDateTime), minutesOf(a.endDateTime), m, slotEnd)
    );
    const block = blocks.find((b) =>
      overlaps(minutesOf(b.startDateTime), minutesOf(b.endDateTime), m, slotEnd)
    );

    if (appt) {
      slots.push({
        id,
        time,
        status: appt.isFitIn ? 'encaixe' : 'confirmed',
        clientName: appt.clientName,
        service: appt.serviceName,
        professionalId: profId,
        appointmentId: appt.id,
      });
    } else if (block) {
      slots.push({ id, time, status: 'blocked', professionalId: profId });
    } else {
      slots.push({ id, time, status: 'free', professionalId: profId });
    }
  }
  return slots;
}

/** Bloqueia o slot (30min) no backend via blocked-times. */
export async function blockSlot(slot: AgendaSlot): Promise<void> {
  const [h, m] = slot.time.split(':').map(Number);
  const date = slot.id.slice(0, 10);
  const endMinutes = h * 60 + m + STEP_MINUTES;
  await createBlockedTime(DEFAULT_ESTABLISHMENT_ID, slot.professionalId, {
    startDateTime: `${date}T${slot.time}:00`,
    endDateTime: `${date}T${pad(Math.floor(endMinutes / 60))}:${pad(endMinutes % 60)}:00`,
    reason: 'Bloqueado pela agenda',
  });
}

/** Cancela o agendamento do slot (exige antecedência mínima do backend). */
export async function cancelAppointment(slot: AgendaSlot): Promise<void> {
  if (!slot.appointmentId) {
    throw new Error('Este horário não tem agendamento para cancelar.');
  }
  await cancelAppointmentApi(DEFAULT_ESTABLISHMENT_ID, slot.appointmentId);
}

/** Cria agendamento no slot com cliente avulso (walk-in) e serviço do catálogo. */
export async function createAppointment(input: CreateAppointmentInput): Promise<void> {
  const { slot, clientName, serviceName, isEncaixe } = input;
  const name = serviceName.trim();
  const services = await listarServicos(DEFAULT_ESTABLISHMENT_ID);
  const service = services.find((s) => s.name.toLowerCase() === name.toLowerCase());
  if (!service) {
    throw new Error(`Serviço "${name}" não encontrado no catálogo.`);
  }
  await createAppointmentApi(DEFAULT_ESTABLISHMENT_ID, {
    professionalId: slot.professionalId,
    serviceId: service.id,
    clientNameFallback: clientName.trim(),
    startDateTime: `${slot.id.slice(0, 10)}T${slot.time}:00`,
    isFitIn: isEncaixe,
  });
}
