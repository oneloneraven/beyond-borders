interface Env {
  ASSETS: { fetch: (request: Request) => Promise<Response> };
  APP_ENV: string;
  RELEASE_VERSION?: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const { pathname } = new URL(request.url);
    if (pathname === '/api/health') {
      return Response.json(
        { ok: true, environment: env.APP_ENV, version: env.RELEASE_VERSION ?? 'unreleased' },
        { headers: { 'Cache-Control': 'no-store' } },
      );
    }
    return env.ASSETS.fetch(request);
  },
};
