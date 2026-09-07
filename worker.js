const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "content-type": "application/json; charset=UTF-8",
      ...corsHeaders,
    },
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    if (url.pathname === "/") {
      return new Response("AK-1 Backend is online!", {
        headers: { "content-type": "text/plain; charset=UTF-8", ...corsHeaders },
      });
    }

    if (url.pathname === "/v1/status" && request.method === "GET") {
      return json({
        device: "AK-1",
        backend: "online",
        gemini: Boolean(env.GEMINI_API_KEY),
        version: "1.1.1",
      });
    }

    if (url.pathname === "/v1/ai/vision" && request.method === "POST") {
      if (!env.GEMINI_API_KEY) return json({ error: "GEMINI_API_KEY is not configured." }, 500);
      let body;
      try { body = await request.json(); } catch { return json({ error: "Invalid JSON body." }, 400); }
      const prompt = typeof body?.prompt === "string" && body.prompt.trim()
        ? body.prompt.trim()
        : "این تصویر را به فارسی تحلیل کن و مهم‌ترین چیزهایی که می‌بینی را کوتاه و واضح بگو.";
      const imageBase64 = typeof body?.image_base64 === "string" ? body.image_base64.trim() : "";
      if (!imageBase64) return json({ error: "image_base64 is required." }, 400);
      if (imageBase64.length > 6_000_000) return json({ error: "Image is too large." }, 413);

      const model = "gemini-2.5-flash";
      const endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/" +
        model + ":generateContent?key=" + encodeURIComponent(env.GEMINI_API_KEY);
      const geminiResponse = await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ role: "user", parts: [
            { text: prompt },
            { inline_data: { mime_type: "image/jpeg", data: imageBase64 } },
          ] }],
          generationConfig: { temperature: 0.4, maxOutputTokens: 1024 },
        }),
      });
      const raw = await geminiResponse.text();
      if (!geminiResponse.ok) return json({ error: "Gemini vision request failed.", status: geminiResponse.status, details: raw.slice(0, 2000) }, 502);
      let data;
      try { data = JSON.parse(raw); } catch { return json({ error: "Invalid response from Gemini." }, 502); }
      const text = data?.candidates?.[0]?.content?.parts?.map((part) => part?.text || "").join("").trim() || "";
      return json({ ok: true, model, text });
    }

    if (url.pathname === "/v1/ai/command" && request.method === "POST") {
      if (!env.GEMINI_API_KEY) {
        return json({ error: "GEMINI_API_KEY is not configured." }, 500);
      }

      let body;
      try {
        body = await request.json();
      } catch {
        return json({ error: "Invalid JSON body." }, 400);
      }

      const prompt = typeof body?.prompt === "string" ? body.prompt.trim() : "";
      if (!prompt) return json({ error: "prompt is required." }, 400);
      if (prompt.length > 8000) return json({ error: "prompt is too long." }, 413);

      const model = "gemini-2.5-flash";
      const endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/" +
        model +
        ":generateContent?key=" +
        encodeURIComponent(env.GEMINI_API_KEY);

      const geminiResponse = await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ role: "user", parts: [{ text: prompt }] }],
          generationConfig: { temperature: 0.7, maxOutputTokens: 1024 },
        }),
      });

      const raw = await geminiResponse.text();
      if (!geminiResponse.ok) {
        return json({
          error: "Gemini request failed.",
          status: geminiResponse.status,
          details: raw.slice(0, 2000),
        }, 502);
      }

      let data;
      try { data = JSON.parse(raw); }
      catch { return json({ error: "Invalid response from Gemini." }, 502); }

      const text = data?.candidates?.[0]?.content?.parts
        ?.map((part) => part?.text || "")
        .join("")
        .trim() || "";

      return json({ ok: true, model, text });
    }

    return json({ error: "Not Found", service: "AK-1 Backend" }, 404);
  },
};
