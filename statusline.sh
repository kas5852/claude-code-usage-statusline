#!/bin/bash
# Status line: plan usage left (5-hour + weekly), reset countdowns, context use.
# Fed JSON on stdin by Claude Code; see https://code.claude.com/docs/en/statusline

IFS=$'\t' read -r model h5 h5r d7 d7r ctx < <(jq -r '[
  (.model.display_name // "Claude"),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.rate_limits.seven_day.resets_at // ""),
  (.context_window.used_percentage // "")
] | @tsv')

DIM=$'\e[38;5;244m'; RST=$'\e[0m'; BOLD=$'\e[1m'
SEP="${DIM}  │  ${RST}"
now=$(date +%s)

color() {  # remaining % -> green / amber / red
  if   (( $1 >= 50 )); then printf '\e[38;5;114m'
  elif (( $1 >= 20 )); then printf '\e[38;5;179m'
  else                       printf '\e[38;5;167m'; fi
}

bar() {  # 8-cell bar of remaining %
  local left=$1 cells=8 fill=$(( ($1 * 8 + 50) / 100 )) i out=""
  (( left > 0 && fill == 0 )) && fill=1
  for ((i = 0; i < cells; i++)); do
    (( i < fill )) && out+="━" || out+="${DIM}─"
  done
  printf '%s%s%s' "$(color "$left")" "$out" "$RST"
}

until_reset() {  # epoch -> "2h14m" / "3d4h" / "41m"
  local s=$(( $1 - now )); (( s < 0 )) && s=0
  local d=$(( s / 86400 )) h=$(( s % 86400 / 3600 )) m=$(( s % 3600 / 60 ))
  if   (( d > 0 )); then printf '%dd%dh' "$d" "$h"
  elif (( h > 0 )); then printf '%dh%02dm' "$h" "$m"
  else                   printf '%dm' "$m"; fi
}

window() {  # label used% resets_at
  [[ -z $2 ]] && return 1
  local left=$(( 100 - ${2%.*} )); (( left < 0 )) && left=0
  local out="${DIM}$1${RST} $(bar "$left") $(color "$left")${left}%${RST}${DIM} left"
  [[ -n $3 ]] && out+=" · ↻ $(until_reset "$3")"
  printf '%s%s' "$out" "$RST"
}

line="${BOLD}${model}${RST}"
if w=$(window "5h" "$h5" "$h5r"); then line+="${SEP}${w}"; fi
if w=$(window "week" "$d7" "$d7r"); then line+="${SEP}${w}"; fi
[[ -z $h5 && -z $d7 ]] && line+="${SEP}${DIM}usage appears after the first reply${RST}"
[[ -n $ctx ]] && line+="${SEP}${DIM}ctx ${ctx%.*}%${RST}"

printf '%s\n' "$line"
