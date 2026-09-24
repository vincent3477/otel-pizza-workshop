#!/bin/sh
# Writes the Dash0 browser-monitoring settings into dash0-config.js when the
# container starts, so the token comes from the environment instead of being
# baked into the image. index.html reads window.DASH0_CONFIG and stays off
# entirely when authToken is empty.
set -e

target=/usr/share/nginx/html/dash0-config.js

# Values end up inside a double-quoted JavaScript string.
js_escape() {
    printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr -d '\n\r'
}

{
    printf 'window.DASH0_CONFIG = {\n'
    printf '  endpointUrl: "%s",\n' "$(js_escape "${DASH0_WEB_ENDPOINT:-}")"
    printf '  authToken: "%s",\n' "$(js_escape "${DASH0_WEB_AUTH_TOKEN:-}")"
    printf '  dataset: "%s",\n' "$(js_escape "${DASH0_DATASET:-default}")"
    printf '  environment: "%s",\n' "$(js_escape "${DASH0_ENVIRONMENT:-workshop}")"
    printf '  repositoryUrl: "%s"\n' "$(js_escape "${VCS_REPOSITORY_URL:-}")"
    printf '};\n'
} >"$target"

if [ -n "${DASH0_WEB_AUTH_TOKEN:-}" ]; then
    echo "Dash0: browser monitoring enabled, sending to ${DASH0_WEB_ENDPOINT:-<unset>}"
else
    echo "Dash0: browser monitoring disabled (DASH0_WEB_AUTH_TOKEN is empty)"
fi
