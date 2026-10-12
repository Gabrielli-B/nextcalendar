import { defineConfig } from '@playwright/test';

/**
 * E2E de UI: Expo web (Metro) + backend real em http://localhost:8080.
 * O webServer sobe o Expo sozinho; o backend precisa estar no ar antes
 * (make backend-run).
 */
export default defineConfig({
  testDir: '.',
  timeout: 60_000,
  expect: { timeout: 15_000 },
  fullyParallel: false,
  workers: 1,
  retries: 0,
  reporter: [['list'], ['html', { outputFolder: 'report', open: 'never' }]],
  use: {
    baseURL: 'http://localhost:8090',
    trace: 'retain-on-failure',
  },
  webServer: {
    command: 'npx expo start --web --port 8090',
    cwd: '..',
    url: 'http://localhost:8090',
    reuseExistingServer: !process.env.CI,
    timeout: 240_000,
    env: { CI: '1', EXPO_NO_TELEMETRY: '1' },
  },
});
