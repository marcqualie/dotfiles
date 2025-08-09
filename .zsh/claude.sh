#!/bin/sh

claude() {
  for file in ~/.envrc/claude.*; do
    if [ -f "$file" ]; then
      echo "sourcing $file"
      # shellcheck source=/dev/null
      . "$file"
    fi
  done
  if [ "$CLAUDE_CODE_ENABLE_TELEMETRY" = "1" ]; then
    echo "Running Claude with Open Telemetry ($OTEL_EXPORTER_OTLP_ENDPOINT)"
  fi

  # shellcheck disable=SC2068
  /Users/marc/.nodenv/shims/claude $@
}
