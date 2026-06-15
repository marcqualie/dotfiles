#!/bin/bash

input=$(cat)

# --- Model ---
MODEL=$(echo "$input" | jq -r '.model.display_name')

# --- Usage limits ---
FIVE_H=$(echo "$input"     | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEK=$(echo "$input"       | jq -r '.rate_limits.seven_day.used_percentage // empty')
WEEK_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# --- Session cost (estimated at API rates, even on subscription) ---
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

# Window lengths (seconds)
FIVE_WINDOW=18000     # 5h
WEEK_WINDOW=604800    # 7d

# ANSI styles
RESET=$'\033[0m'
DIM=$'\033[2m'
MARK=$'\033[96m'      # bright cyan: "you are here" in the time window

NOW=$(date +%s)

# marker_idx RESETS_AT WINDOW WIDTH -> cell index (0..width-1) for time elapsed, or -1
marker_idx() {
  local resets=$1 window=$2 width=$3 remaining elapsed idx
  case "$resets" in (''|*[!0-9]*) echo -1; return;; esac
  remaining=$(( resets - NOW ))
  [ "$remaining" -lt 0 ] && remaining=0
  [ "$remaining" -gt "$window" ] && remaining=$window
  elapsed=$(( window - remaining ))
  idx=$(( elapsed * width / window ))
  [ "$idx" -ge "$width" ] && idx=$(( width - 1 ))
  echo "$idx"
}

# bar PCT MARKER -> coloured fill (usage) with a cyan line at MARKER (time elapsed)
bar() {
  local pct=$1 marker=$2 width=10 p filled color out="" i=0
  p=$(printf '%.0f' "$pct")
  filled=$(( (p * width + 50) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0

  if   [ "$p" -ge 80 ]; then color=$'\033[31m'   # red
  elif [ "$p" -ge 50 ]; then color=$'\033[33m'   # yellow
  else                       color=$'\033[32m'   # green
  fi

  while [ "$i" -lt "$width" ]; do
    if [ "$i" -eq "$marker" ]; then
      out="${out}${MARK}│${RESET}"
    elif [ "$i" -lt "$filled" ]; then
      out="${out}${color}█${RESET}"
    else
      out="${out}${DIM}░${RESET}"
    fi
    i=$(( i + 1 ))
  done

  printf '%s %s%s%%%s' "$out" "$color" "$p" "$RESET"
}

# cost_str USD -> " $1.23" (more precision when small; empty if no/invalid value)
cost_str() {
  local usd=$1 fmt
  case "$usd" in (''|*[!0-9.]*) return;; esac
  fmt=$(awk -v c="$usd" 'BEGIN {
    if (c >= 1)      printf "$%.2f", c
    else if (c >= 0.01) printf "$%.2f", c
    else if (c > 0)  printf "$%.3f", c
    else             printf "$0.00"
  }')
  printf '%s' "  ${DIM}${fmt}${RESET}"
}

# reset_str EPOCH FORMAT -> dim " 22:30" (empty if no/invalid timestamp)
reset_str() {
  local epoch=$1 fmt=$2 when
  case "$epoch" in (''|*[!0-9]*) return;; esac
  when=$(date -r "$epoch" "+$fmt" 2>/dev/null | tr '[:upper:]' '[:lower:]')
  [ -n "$when" ] && printf '%s' " ${DIM}${when}${RESET}"
}

# --- Assemble ---
OUT="[$MODEL]"
if [ -n "$FIVE_H" ]; then
  M=$(marker_idx "$FIVE_RESET" "$FIVE_WINDOW" 10)
  OUT="$OUT  ${DIM}5h${RESET} $(bar "$FIVE_H" "$M")$(reset_str "$FIVE_RESET" '%H:%M')"
fi
if [ -n "$WEEK" ]; then
  M=$(marker_idx "$WEEK_RESET" "$WEEK_WINDOW" 10)
  OUT="$OUT  ${DIM}7d${RESET} $(bar "$WEEK" "$M")$(reset_str "$WEEK_RESET" '%a %H:%M')"
fi

OUT="$OUT$(cost_str "$COST")"

echo "$OUT"
