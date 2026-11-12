import { describe, expect, it } from 'vitest';
import worker from '../../src/worker';

const env = {
  APP_ENV: 'test',
  RELEASE_VERSION: 'v1.2.3',
  ASSETS: { fetch: async () => new Response('asset') },
};

describe('worker', () => {
  it('reports the environment and release on /api/health', async () => {
    const response = await worker.fetch(new Request('https://example.test/api/health'), env);
    expect(response.headers.get('Cache-Control')).toBe('no-store');
    expect(await response.json()).toEqual({ ok: true, environment: 'test', version: 'v1.2.3' });
  });

  it('reports an unreleased build when there is no release version', async () => {
    const response = await worker.fetch(new Request('https://example.test/api/health'), {
      ...env,
      RELEASE_VERSION: undefined,
    });
    expect(await response.json()).toMatchObject({ version: 'unreleased' });
  });

  it('serves everything else from the static assets', async () => {
    const response = await worker.fetch(new Request('https://example.test/'), env);
    expect(await response.text()).toBe('asset');
  });
});
