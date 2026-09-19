# Architecture

Phone app = UI, microphone, AI requests, local robot control.

Cloudflare Worker = secure OpenRouter proxy. The OpenRouter API key stays server-side.

ESP32-CAM = camera + local hardware interface.

L298N = motor driver for the single yellow gearmotor used to rotate the robot.

DFPlayer Mini + PAM8403 = audio hardware; audio firmware integration can be added after the physical serial wiring is finalized.
