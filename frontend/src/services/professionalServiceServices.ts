import api from './api';

// ─── Tipos ────────────────────────────────────────────────────────────────────

/** Vínculo profissional ↔ serviço (pares do estabelecimento). */
export type ProfessionalServiceLink = {
  professionalId: string;
  serviceId: string;
};

// ─── GET /api/v1/establishments/{establishmentId}/professional-services ──────
// Regra do backend: profissional sem vínculos atende todos os serviços;
// serviço sem vínculos aceita todos os profissionais; caso contrário, o par
// precisa existir.

export async function getProfessionalServiceLinks(
  establishmentId: string
): Promise<ProfessionalServiceLink[]> {
  const { data } = await api.get<ProfessionalServiceLink[]>(
    `/establishments/${establishmentId}/professional-services`
  );
  return data;
}

// ─── PUT /api/v1/establishments/{establishmentId}/professional-services/{id} ─
// Substitui todos os serviços do profissional pela lista informada.

export async function replaceProfessionalServiceLinks(
  establishmentId: string,
  professionalId: string,
  serviceIds: string[]
): Promise<ProfessionalServiceLink[]> {
  const { data } = await api.put<ProfessionalServiceLink[]>(
    `/establishments/${establishmentId}/professional-services/${professionalId}`,
    serviceIds
  );
  return data;
}
