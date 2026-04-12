#!/bin/bash
set -e

# ── Start NGINX in the foreground ───────────────────────────────────────────────
# "daemon off" keeps NGINX in the foreground so Docker can manage it as PID 1.
# Without this, NGINX would fork to background and the container would exit.
exec nginx -g "daemon off;"