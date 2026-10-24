import api from './api';

export type ProductResponse = {
  id: string;
  name: string;
  category: string;
  price: number;
  stockQuantity: number;
};

export type ProductPayload = {
  name: string;
  category: string;
  price: number;
  stockQuantity: number;
};

export async function listProducts(establishmentId: string): Promise<ProductResponse[]> {
  // O backend devolve Page<ProductMinResponseDTO> — pegamos só o content.
  const { data } = await api.get(`/establishments/${establishmentId}/products`, {
    params: { size: 100 },
  });
  return data.content ?? data;
}

export async function createProduct(
  establishmentId: string,
  payload: ProductPayload,
): Promise<ProductResponse> {
  const { data } = await api.post<ProductResponse>(`/establishments/${establishmentId}/products`, payload);
  return data;
}

export async function updateProduct(
  establishmentId: string,
  productId: string,
  payload: ProductPayload,
): Promise<ProductResponse> {
  const { data } = await api.put<ProductResponse>(
    `/establishments/${establishmentId}/products/${productId}`,
    payload,
  );
  return data;
}

export async function deleteProduct(establishmentId: string, productId: string): Promise<void> {
  await api.delete(`/establishments/${establishmentId}/products/${productId}`);
}
