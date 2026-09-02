# AK-1 Backend

Backend contract for remote AI/data services. The Flutter app and device agents should use authenticated HTTPS/WebSocket connections.

Recommended endpoints:
- `POST /v1/pair` — pair a phone with a device using a one-time code.
- `GET /v1/status` — cloud/device status.
- `POST /v1/command` — send an allowlisted command.
- `WS /v1/events` — realtime status/events.
- `POST /v1/ai/command` — natural-language intent processing.

This folder intentionally contains the contract and a deployment-neutral structure rather than pretending a cloud account has already been configured.
