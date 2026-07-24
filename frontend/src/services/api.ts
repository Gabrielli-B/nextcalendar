import axios from 'axios';
import { getStorageItemAsync } from '../utils/storage';

/**
 * Instância centralizada do axios.
 * Lê o token JWT do SecureStore e injeta automaticamente no header.
 */
const api = axios.create({
  baseURL: 'http://localhost:8080/api/v1',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor: injeta o Bearer token em toda requisição
api.interceptors.request.use(async (config) => {
  const token = await getStorageItemAsync('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
