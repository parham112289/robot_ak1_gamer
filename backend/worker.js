const MOTOR_ACTIONS = new Set(["LEFT", "RIGHT", "STOP"]);

function response(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "access-control-allow-origin": "*",
      "access-control-allow-headers": "content-type, authorization",
      "access-control-allow-methods": "GET, POST, OPTIONS"
    }
  });
}

async function ai(env, message, mode) {
  if (!env.OPENROUTER_API_KEY) throw new Error("OPENROUTER_API_KEY is missing");

  const r = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${env.OPENROUTER_API_KEY}`,
      "Content-Type": "application/json",
      "HTTP-Referer": "https://github.com/",
      "X-Title": "AK-1"
    },
    body: JSON.stringify({
      model: "openrouter/free",
      messages: [
        {
          role: "system",
          content:
            "You are AK-1, a concise Persian-speaking AI study and gaming helper. " +
            "Study mode explains step by step. Game mode answers general gaming questions. " +
            "Never claim a hardware action happened unless the hardware API confirms it. " +
            `Current mode: ${mode}.`
        },
        { role: "user", content: message }
      ]
    })
  });

  const data = await r.json();
  if (!r.ok) throw new Error(data?.error?.message || `OpenRouter ${r.status}`);
  return data?.choices?.[0]?.message?.content || "پاسخی دریافت نشد.";
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") return response({ ok: true });

    const url = new URL(request.url);

    if (url.pathname === "/v1/status") {
      return response({ ok: true, service: "AK-1", ai: "OpenRouter" });
    }

    if (url.pathname === "/v1/ai/command" && request.method === "POST") {
      try {
        const body = await request.json();
        const message = String(body.message || "").trim();
        const mode = String(body.mode || "AI");
        if (!message) return response({ error: "message is required" }, 400);
        return response({ answer: await ai(env, message, mode) });
      } catch (e) {
        return response({ error: e.message || "AI error" }, 500);
      }
    }

    return response({ error: "Not found" }, 404);
  }
};
