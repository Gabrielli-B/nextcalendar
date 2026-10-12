import { beforeAll, describe, expect, it } from 'vitest';
import { isAxiosError } from 'axios';
import {
  createClient,
  deleteClient,
  getClientById,
  searchClients,
  updateClient,
} from '../../src/services/clientServices';
import { loginAsManager, unique } from './helpers';

describe('clients (CRUD via service do frontend)', () => {
  let clientId = '';
  const email = `${unique('client-crud')}@e2e.test`;

  beforeAll(async () => {
    await loginAsManager();
    const created = await createClient({
      name: 'Cliente CRUD',
      phone: '51999990002',
      email,
      password: 'Senha1234',
      dateOfBirth: '1990-01-01',
    });
    clientId = created.id;
  });

  it('create retorna id e dados espelhados', async () => {
    const details = await getClientById(clientId);
    expect(details.id).toBe(clientId);
    expect(details.email).toBe(email);
    expect(details.active).toBe(true);
  });

  it('search encontra pelo nome único', async () => {
    const page = await searchClients('Cliente CRUD', 0, 50);
    expect(page.content.some((c) => c.id === clientId)).toBe(true);
  });

  it('update altera observação', async () => {
    const updated = await updateClient(clientId, { notes: 'editado pelo vitest' });
    expect(updated.id).toBe(clientId);
    const details = await getClientById(clientId);
    expect(details.notes).toBe('editado pelo vitest');
  });

  it('delete remove o acesso ao cliente', async () => {
    await deleteClient(clientId);
    const err = await getClientById(clientId).then(
      () => null,
      (e) => e
    );
    // soft delete: ou some (404) ou volta marcado como inativo
    if (isAxiosError(err)) {
      expect(err.response?.status).toBe(404);
    } else {
      const after = await getClientById(clientId);
      expect(after.active).toBe(false);
    }
  });
});
