const ALLOWED = new Set(['LEFT', 'RIGHT', 'STOP']);
const json = (data, status = 200) => new Response(JSON.stringify(data), {
  status,
  headers: {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  },
});

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') return json({ ok: true });
    const url = new URL(request.url);

    if (url.pathname === '/' || url.pathname === '/v1/status') return json({ ok: true, service: 'AK-1 backend' });

    if (url.pathname === '/v1/ai/command' && request.method === 'POST') {
      try {
        if (!env.OPENROUTER_API_KEY) return json({ error: 'OPENROUTER_API_KEY is not configured' }, 500);
        const body = await request.json().catch(() => ({}));
        const message = String(body.message || body.command || '').trim();
        const mode = String(body.mode || 'AI');
        if (!message) return json({ error: 'message is required' }, 400);
        const system = `You are AK-1, a Persian-speaking AI study and game helper. Mode: ${mode}. Be concise, clear and safe. Never claim a physical action happened unless the robot API confirms it.`;
        const r = await fetch('https://openrouter.ai/api/v1/chat/completions', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${env.OPENROUTER_API_KEY}`,
            'Content-Type': 'application/json',
            'HTTP-Referer': url.origin,
            'X-Title': 'AK-1',
          },
          body: JSON.stringify({
            model: env.OPENROUTER_MODEL || 'openrouter/free',
            messages: [{ role: 'system', content: system }, { role: 'user', content: message }],
          }),
        });
        const data = await r.json().catch(() => ({}));
        if (!r.ok) return json({ error: data?.error?.message || 'OpenRouter request failed' }, r.status);
        return json({ ok: true, answer: data?.choices?.[0]?.message?.content || 'پاسخی دریافت نشد.' });
      } catch (e) {
        return json({ error: e?.message || 'server error' }, 500);
      }
    }

    // Hardware stays on the phone's local network. These endpoints are only compatibility/status APIs.
    if (url.pathname === '/v1/robot/status') return json({ online: false, battery_voltage: null });
    if (url.pathname === '/v1/robot/command' && request.method === 'POST') {
      const body = await request.json().catch(() => ({}));
      const action = String(body.action || '').toUpperCase();
      if (!ALLOWED.has(action)) return json({ error: 'unsupported action' }, 400);
      return json({ ok: false, action, message: 'Send hardware commands directly to ESP32-CAM from the app.' }, 503);
    }
    return json({ error: 'not found' }, 404);
  },
};
