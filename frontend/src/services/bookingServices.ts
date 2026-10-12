/**
 * Tipos do fluxo de agendamento do cliente (tela Home / booking-tab).
 *
 * As chamadas antigas para /bookings/* foram removidas: o recurso não existe
 * no backend (é /appointments) e só o tipo era importado. Quem precisa de dados
 * usa appointmentServices.getClientAppointments().
 */
export type Booking = {
  id: string;
  date: string;
  time: string;
  shop: string;
  address: string;
  services: string;
  price: string;
  status: 'upcoming' | 'done' | 'cancelled';
  reminder?: boolean;
  /** ISO 8601 original do agendamento — usado para calcular a janela de remarcação de 2h. */
  startDateTimeRaw?: string;
  /** ID do profissional original — propagado para o fluxo de remarcação. */
  professionalId?: string;
  /** ID do serviço original — propagado para o fluxo de remarcação. */
  serviceId?: string;
};
