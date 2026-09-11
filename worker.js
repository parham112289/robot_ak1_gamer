const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json; charset=UTF-8", ...corsHeaders },
  });
}

async function callOpenRouter(env, messages, maxTokens = 1024) {
  if (!env.OPENROUTER_API_KEY) throw new Error("OPENROUTER_API_KEY is not configured.");
  const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${env.OPENROUTER_API_KEY}`,
      "HTTP-Referer": "https://robot-ak1-gamer.parhamsadr-s89.workers.dev",
      "X-Title": "AK-1 Robot",
    },
    body: JSON.stringify({ model: "openrouter/free", messages, temperature: 0.4, max_tokens: maxTokens }),
  });
  const raw = await response.text();
  if (!response.ok) throw new Error(`OpenRouter ${response.status}: ${raw.slice(0, 2000)}`);
  let data;
  try { data = JSON.parse(raw); } catch { throw new Error("Invalid response from OpenRouter."); }
  const text = data?.choices?.[0]?.message?.content;
  if (typeof text !== "string") throw new Error("OpenRouter returned no text response.");
  return { text: text.trim(), model: data?.model || "openrouter/free" };
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders });
    if (url.pathname === "/") return new Response("AK-1 Backend is online!", { headers: { "content-type": "text/plain; charset=UTF-8", ...corsHeaders } });

    if (url.pathname === "/v1/status" && request.method === "GET") {
      return json({ device: "AK-1", backend: "online", openrouter: Boolean(env.OPENROUTER_API_KEY), model: "openrouter/free", version: "4.1.0" });
    }

    if (url.pathname === "/v1/ai/command" && request.method === "POST") {
      let body;
      try { body = await request.json(); } catch { return json({ error: "Invalid JSON body." }, 400); }
      const prompt = typeof body?.prompt === "string" ? body.prompt.trim() : "";
      if (!prompt) return json({ error: "prompt is required." }, 400);
      if (prompt.length > 8000) return json({ error: "prompt is too long." }, 413);
      try {
        const result = await callOpenRouter(env, [
          { role: "system", content: "تو مغز هوش مصنوعی ربات AK-1 هستی. فارسی طبیعی، کوتاه و دقیق پاسخ بده. اگر کاربر فرمان ربات می‌دهد، منظور او را واضح و عملی تفسیر کن؛ فقط متن پاسخ بده." },
          { role: "user", content: prompt },
        ]);
        return json({ ok: true, model: result.model, text: result.text });
      } catch (e) {
        return json({ error: "OpenRouter request failed.", details: String(e?.message || e) }, 502);
      }
    }

    if (url.pathname === "/v1/ai/vision" && request.method === "POST") {
      let body;
      try { body = await request.json(); } catch { return json({ error: "Invalid JSON body." }, 400); }
      const prompt = typeof body?.prompt === "string" && body.prompt.trim() ? body.prompt.trim() : "این تصویر را به فارسی تحلیل کن و مهم‌ترین چیزهایی که می‌بینی را کوتاه و واضح بگو.";
      const imageBase64 = typeof body?.image_base64 === "string" ? body.image_base64.trim() : "";
      if (!imageBase64) return json({ error: "image_base64 is required." }, 400);
      if (imageBase64.length > 8_000_000) return json({ error: "Image is too large." }, 413);
      try {
        const result = await callOpenRouter(env, [
          { role: "system", content: "تو بینایی و هوش مصنوعی ربات AK-1 هستی. تصویر را دقیق و به فارسی تحلیل کن و از حدس بی‌دلیل خودداری کن." },
          { role: "user", content: [
            { type: "text", text: prompt },
            { type: "image_url", image_url: { url: `data:image/jpeg;base64,${imageBase64}` } },
          ] },
        ]);
        return json({ ok: true, model: result.model, text: result.text });
      } catch (e) {
        return json({ error: "OpenRouter vision request failed.", details: String(e?.message || e) }, 502);
      }
    }

    return json({ error: "Not Found", service: "AK-1 Backend" }, 404);
  },
};
