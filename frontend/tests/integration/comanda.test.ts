import { beforeAll, describe, expect, it } from 'vitest';
import {
  addOrderItem,
  finishOrder,
  getOrder,
  openOrder,
  removeOrderItem,
  updateOrder,
} from '../../src/services/comandaServices';
import { createAppointment } from '../../src/services/appointmentServices';
import {
  ESTABLISHMENT_ID,
  PROFESSIONAL_ID,
  SEED_PRODUCT_ID,
  SEED_SERVICE_ID,
  loginAsManager,
  nextWeekday,
} from './helpers';
import { getAvailableSlots } from '../../src/services/appointmentServices';

describe('comanda (abrir → itens → pagamento → fechar)', () => {
  let orderId = '';

  beforeAll(async () => {
    await loginAsManager();
    const date = nextWeekday(21); // outra data que a de appointments.test
    const slots = await getAvailableSlots(ESTABLISHMENT_ID, PROFESSIONAL_ID, SEED_SERVICE_ID, date);
    const appointment = await createAppointment(ESTABLISHMENT_ID, {
      professionalId: PROFESSIONAL_ID,
      serviceId: SEED_SERVICE_ID,
      clientNameFallback: 'Cliente Comanda',
      clientPhoneFallback: '51999990004',
      startDateTime: `${date}T${slots.slots[0]}`,
    });
    const order = await openOrder(ESTABLISHMENT_ID, appointment.id);
    orderId = order.id;
    expect(order.status).toBe('OPEN');
    // openOrder pré-popula a comanda com o serviço do agendamento (R$ 75)
    expect(order.items).toHaveLength(1);
    expect(order.items[0].unitPrice).toBe(75);
    expect(order.subtotal).toBe(75);
  });

  it('addItem de produto seed (Pomada, R$ 55) e subtotal 130', async () => {
    const order = await addOrderItem(ESTABLISHMENT_ID, orderId, {
      itemType: 'PRODUCT',
      itemId: SEED_PRODUCT_ID,
      quantity: 1,
    });
    expect(order.items).toHaveLength(2);
    expect(order.subtotal).toBe(130);
  });

  it('removeItem do produto volta pra 1 item', async () => {
    const before = await getOrder(ESTABLISHMENT_ID, orderId);
    const product = before.items.find((i) => i.itemType === 'PRODUCT');
    expect(product).toBeDefined();

    const order = await removeOrderItem(ESTABLISHMENT_ID, orderId, product!.id);
    expect(order.items).toHaveLength(1);
  });

  it('updateOrder aplica desconto e forma de pagamento (total 65)', async () => {
    const order = await updateOrder(ESTABLISHMENT_ID, orderId, {
      discountAmount: 10,
      paymentMethod: 'PIX',
    });
    expect(order.discountAmount).toBe(10);
    expect(order.paymentMethod).toBe('PIX');
    expect(order.totalAmount).toBe(65);
  });

  it('finishOrder fecha a comanda', async () => {
    const closed = await finishOrder(ESTABLISHMENT_ID, orderId);
    expect(closed.status).toBe('CLOSED');
    expect(closed.closedAt).toBeTruthy();
  });
});
