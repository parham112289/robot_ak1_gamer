export default {
  async fetch(request) {
    const url = new URL(request.url);

    if (url.pathname === "/") {
      return new Response("AK-1 Backend is online!", {
        headers: {
          "content-type": "text/plain; charset=UTF-8"
        }
      });
    }

    if (url.pathname === "/v1/status") {
      return Response.json({
        device: "AK-1",
        backend: "online",
        version: "1.0.0"
      });
    }

    return Response.json(
      {
        error: "Not Found",
        service: "AK-1 Backend"
      },
      { status: 404 }
    );
  }
};
