import api from './api';
import { listarServicos } from './serviceServices';

export type OrderStatus = 'OPEN' | 'CLOSED' | 'CANCELLED';
export type OrderItemType = 'SERVICE' | 'PRODUCT';
export type PaymentMethod = 'CASH' | 'CREDIT_CARD' | 'DEBIT_CARD' | 'PIX';

export type OrderItem = {
  id: string;
  itemType: OrderItemType;
  name: string;
  unitPrice: number;
  quantity: number;
  subtotal: number;
};

export type Order = {
  id: string;
  appointmentId: string;
  professionalId: string;
  professionalName: string;
  professionalPhotoUrl: string | null;
  clientName: string;
  status: OrderStatus;
  items: OrderItem[];
  subtotal: number;
  discountAmount: number;
  totalAmount: number;
  paymentMethod: PaymentMethod | null;
  createdAt: string;
  closedAt: string | null;
};

export type OrderItemAddInput = {
  itemType: OrderItemType;
  itemId: string;
  quantity: number;
};

export type OrderUpdateInput = {
  discountAmount?: number;
  paymentMethod?: PaymentMethod;
};

export type CatalogService = {
  id: string;
  name: string;
  price: number;
  category?: string;
};

export async function listCatalogServices(establishmentId: string): Promise<CatalogService[]> {
  const services = await listarServicos(establishmentId);
  return services.map((s) => ({ id: s.id, name: s.name, price: s.price, category: s.category }));
}

export async function openOrder(establishmentId: string, appointmentId: string): Promise<Order> {
  const { data } = await api.post<Order>(`/establishments/${establishmentId}/appointments/${appointmentId}/order`);
  return data;
}

export async function getOrder(establishmentId: string, orderId: string): Promise<Order> {
  const { data } = await api.get<Order>(`/establishments/${establishmentId}/orders/${orderId}`);
  return data;
}

export async function addOrderItem(
  establishmentId: string,
  orderId: string,
  input: OrderItemAddInput,
): Promise<Order> {
  const { data } = await api.post<Order>(`/establishments/${establishmentId}/orders/${orderId}/items`, input);
  return data;
}

export async function removeOrderItem(
  establishmentId: string,
  orderId: string,
  itemId: string,
): Promise<Order> {
  const { data } = await api.delete<Order>(`/establishments/${establishmentId}/orders/${orderId}/items/${itemId}`);
  return data;
}

export async function updateOrder(
  establishmentId: string,
  orderId: string,
  input: OrderUpdateInput,
): Promise<Order> {
  const { data } = await api.patch<Order>(`/establishments/${establishmentId}/orders/${orderId}`, input);
  return data;
}

export async function finishOrder(establishmentId: string, orderId: string): Promise<Order> {
  const { data } = await api.post<Order>(`/establishments/${establishmentId}/orders/${orderId}/finish`);
  return data;
}