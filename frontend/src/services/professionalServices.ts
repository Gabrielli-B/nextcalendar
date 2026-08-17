import api from './api';

// ─── Tipos ────────────────────────────────────────────────────────────────────

export type ProfessionalMin = {
  id: string;
  name: string;
  phone?: string;
  email?: string;
  photoUrl?: string | null;
  specialty?: string;
  active?: boolean;
};

export type PageResponse<T> = {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
};

// ─── GET /api/v1/establishments/{establishmentId}/professionals/active ────────

export async function getActiveProfessionals(
  establishmentId: string,
  page = 0,
  size = 20
): Promise<PageResponse<ProfessionalMin>> {
  const { data } = await api.get<PageResponse<ProfessionalMin>>(
    `/establishments/${establishmentId}/professionals/active`,
    { params: { page, size } }
  );
  return data;
}
