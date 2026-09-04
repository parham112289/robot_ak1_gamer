# AK-1 Robot Agent

Protocol contract for the robot-side connection.

The robot should maintain safety-critical control locally. Cloud/phone commands must be allowlisted and authenticated.

Suggested messages:
- `hello`
- `status`
- `camera_offer`
- `audio_offer`
- `command`
- `stop`

Do not expose unrestricted shell/OS control through the robot connection.
