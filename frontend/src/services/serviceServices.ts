import api from './api';

// ─── Tipos ────────────────────────────────────────────────────────────────────

export type ServiceResponse = {
  id: string;
  name: string;
  price: number;
  duration: number; // em minutos
  category: string;
};

export type ServiceCreatePayload = {
  name: string;
  price: number;
  duration: number;
  category: string;
};

export type ServiceUpdatePayload = {
  name: string;
  price: number;
  duration: number;
};

// Resposta paginada do Spring (Page<ServiceMinResponseDTO>)
export type PageResponse<T> = {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;   // página atual (0-indexed)
  size: number;
};

// ─── GET /api/v1/establishments/{establishmentId}/services ────────────────────
// Lista todos os serviços de um estabelecimento (paginado)

export async function getServices(
  establishmentId: string,
  page = 0,
  size = 20
): Promise<PageResponse<ServiceResponse>> {
  const { data } = await api.get<PageResponse<ServiceResponse>>(
    `/establishments/${establishmentId}/services`,
    { params: { page, size } }
  );
  return data;
}

// ─── GET /api/v1/establishments/{establishmentId}/services/search ─────────────
// Busca serviços por nome

export async function searchServices(
  establishmentId: string,
  name: string,
  page = 0,
  size = 20
): Promise<PageResponse<ServiceResponse>> {
  const { data } = await api.get<PageResponse<ServiceResponse>>(
    `/establishments/${establishmentId}/services/search`,
    { params: { name, page, size } }
  );
  return data;
}

// ─── POST /api/v1/establishments/{establishmentId}/services ───────────────────
// Cria um novo serviço

export async function createService(
  establishmentId: string,
  payload: ServiceCreatePayload
): Promise<ServiceResponse> {
  const { data } = await api.post<ServiceResponse>(
    `/establishments/${establishmentId}/services`,
    payload
  );
  return data;
}

// ─── PUT /api/v1/establishments/{establishmentId}/services/{id} ───────────────
// Atualiza um serviço existente

export async function updateService(
  establishmentId: string,
  serviceId: string,
  payload: ServiceUpdatePayload
): Promise<ServiceResponse> {
  const { data } = await api.put<ServiceResponse>(
    `/establishments/${establishmentId}/services/${serviceId}`,
    payload
  );
  return data;
}

// ─── DELETE /api/v1/establishments/{establishmentId}/services/{id} ────────────
// Exclui um serviço

export async function deleteService(
  establishmentId: string,
  serviceId: string
): Promise<void> {
  await api.delete(`/establishments/${establishmentId}/services/${serviceId}`);
}
