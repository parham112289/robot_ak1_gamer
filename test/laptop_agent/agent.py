#!/usr/bin/env python3
"""AK-1 visible LAN Laptop Agent.

Run manually on a laptop you own/control. This agent exposes only a small
allowlist of safe demo operations and status information. It does not expose
an arbitrary shell, credentials, or hidden persistence.
"""
import json
import os
import platform
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOST = os.environ.get("AK1_HOST", "0.0.0.0")
PORT = int(os.environ.get("AK1_PORT", "8765"))
PAIR_CODE = os.environ.get("AK1_PAIR_CODE", "")

ALLOWED_ACTIONS = {
    "open_demo": "درخواست باز کردن برنامه مجاز دریافت شد؛ نگاشت برنامه باید در تنظیمات Agent تعریف شود.",
    "close_demo": "درخواست بستن برنامه مجاز دریافت شد؛ نگاشت برنامه باید در تنظیمات Agent تعریف شود.",
    "file_list_demo": "مدیریت فایل فقط در مسیرهای allowlist شده قابل فعال‌سازی است.",
    "install_request": "نصب برنامه نیازمند تأیید محلی کاربر است.",
    "uninstall_request": "حذف برنامه نیازمند تأیید محلی کاربر است.",
    "screen_start": "درخواست استریم صفحه دریافت شد؛ screen-capture adapter باید فعال باشد.",
    "screen_stop": "درخواست توقف استریم صفحه دریافت شد.",
}


def auth_ok(handler):
    if not PAIR_CODE:
        return True
    return handler.headers.get("X-AK1-Pair-Code", "") == PAIR_CODE


class Handler(BaseHTTPRequestHandler):
    def _json(self, code, payload):
        raw = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(raw)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, X-AK1-Pair-Code")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.end_headers()

    def do_GET(self):
        if not auth_ok(self):
            return self._json(401, {"ok": False, "error": "pairing_required"})
        if self.path == "/health":
            return self._json(200, {"ok": True, "name": "AK-1 Laptop Agent", "version": "2.0"})
        if self.path == "/status":
            return self._json(200, {
                "ok": True,
                "hostname": socket.gethostname(),
                "platform": platform.system(),
                "platform_version": platform.version(),
                "python": platform.python_version(),
                "capabilities": ["status", "allowlisted_commands", "screen_adapter_ready"],
            })
        return self._json(404, {"ok": False, "error": "not_found"})

    def do_POST(self):
        if not auth_ok(self):
            return self._json(401, {"ok": False, "error": "pairing_required"})
        if self.path != "/command":
            return self._json(404, {"ok": False, "error": "not_found"})
        try:
            length = int(self.headers.get("Content-Length", "0"))
            data = json.loads(self.rfile.read(length) or b"{}")
            action = data.get("action")
        except Exception:
            return self._json(400, {"ok": False, "error": "invalid_json"})
        if action not in ALLOWED_ACTIONS:
            return self._json(403, {"ok": False, "error": "action_not_allowed"})
        return self._json(200, {"ok": True, "action": action, "message": ALLOWED_ACTIONS[action]})

    def log_message(self, fmt, *args):
        print("[AK-1]", fmt % args)


if __name__ == "__main__":
    print(f"AK-1 Laptop Agent listening on http://{HOST}:{PORT}")
    print("Visible/manual mode. Set AK1_PAIR_CODE for pairing protection.")
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
