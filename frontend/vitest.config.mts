import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vitest/config';

const dir = (p: string) => fileURLToPath(new URL(p, import.meta.url));

export default defineConfig({
  resolve: {
    alias: {
      // Os services importam react-native/expo-secure-store via src/utils/storage;
      // fora do Metro usamos stubs em memória (o caminho "native" usa SecureStore).
      'react-native': dir('./tests/integration/stubs/react-native.ts'),
      'expo-secure-store': dir('./tests/integration/stubs/expo-secure-store.ts'),
    },
  },
  test: {
    environment: 'node',
    include: ['tests/integration/**/*.test.ts'],
    env: {
      EXPO_PUBLIC_API_URL: 'http://localhost:8080/api/v1',
    },
    testTimeout: 20000,
    hookTimeout: 20000,
  },
});
