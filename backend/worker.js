const DEFAULT_MODEL = 'openrouter/free';

function cors() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
    'Content-Type': 'application/json; charset=utf-8',
  };
}
function json(data, status = 200) { return new Response(JSON.stringify(data), {status, headers: cors()}); }

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') return new Response(null, {headers: cors()});
    const url = new URL(request.url);
    if (url.pathname === '/' || url.pathname === '/v1/status') return json({ok:true, service:'AK-1 backend'});

    if (url.pathname === '/v1/robot/status' && request.method === 'GET') {
      return json({online:true, battery_voltage:0, camera_url: env.CAMERA_SNAPSHOT_URL || ''});
    }

    if (url.pathname === '/v1/robot/command' && request.method === 'POST') {
      // This endpoint is intentionally a safe API stub. Connect it to your ESP32 transport later.
      const body = await request.json().catch(() => ({}));
      const allowed = new Set(['LEFT','RIGHT','STOP']);
      const action = String(body.action || '').toUpperCase();
      if (!allowed.has(action)) return json({error:'unsupported action'}, 400);
      return json({ok:true, action});
    }

    if (url.pathname === '/v1/ai/command' && request.method === 'POST') {
      if (!env.OPENROUTER_API_KEY) return json({error:'OPENROUTER_API_KEY is not configured'}, 500);
      const body = await request.json().catch(() => ({}));
      const command = String(body.command || '').trim();
      const mode = String(body.mode || 'general');
      if (!command) return json({error:'command is required'}, 400);
      const system = `You are the AI brain of AK-1, a study and game helper. Mode: ${mode}. Answer in Persian when the user speaks Persian. Be concise, useful, and do not claim hardware actions were completed unless the robot API confirms them.`;
      const r = await fetch('https://openrouter.ai/api/v1/chat/completions', {
        method:'POST',
        headers:{'Authorization':`Bearer ${env.OPENROUTER_API_KEY}`,'Content-Type':'application/json','HTTP-Referer':url.origin,'X-Title':'AK-1'},
        body:JSON.stringify({model:env.OPENROUTER_MODEL || DEFAULT_MODEL,messages:[{role:'system',content:system},{role:'user',content:command}]})
      });
      const data = await r.json().catch(() => ({}));
      if (!r.ok) return json({error:'OpenRouter request failed', details:data}, r.status);
      const reply = data?.choices?.[0]?.message?.content ?? 'پاسخی دریافت نشد.';
      return json({ok:true, reply});
    }

    return json({error:'not found'},404);
  }
};
