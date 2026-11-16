#!/usr/bin/env bash
# Test snippets are single-quoted on purpose: succeeds/fails eval them later
# in a subshell. Settings like MEMINFO are read by the sourced script.
# shellcheck disable=SC2016,SC2034,SC2319
# Unit tests for ./stack's helpers. No Docker or root needed.
# Run: bash tests/unit.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
export STACK_ENV_FILE="$WORK/.env"
# shellcheck source=stack
source "$ROOT/stack"
set +e
GENERATED_DIR="$WORK/generated"

passed=0 failed=0
check() { # description, expected, actual
  if [[ "$2" == "$3" ]]; then passed=$((passed + 1)); else failed=$((failed + 1)); printf 'FAIL: %s\n  expected: %q\n  actual:   %q\n' "$1" "$2" "$3"; fi
}
succeeds() { if (eval "$2") >/dev/null 2>&1; then check "$1" ok ok; else check "$1" ok failed; fi; }
fails() { if (eval "$2") >/dev/null 2>&1; then check "$1" failed ok; else check "$1" failed failed; fi; }

# --- swap sizing --------------------------------------------------------------
check "2 GB server without swap gets 4 GiB" 4 "$(swap_plan_gib 1950 0)"
check "2 GB server with 1 GiB swap gets 3 more" 3 "$(swap_plan_gib 1950 1024)"
check "2 GB server with 4 GiB swap needs none" 0 "$(swap_plan_gib 1950 4096)"
check "6 GB server gets 2 GiB" 2 "$(swap_plan_gib 6000 0)"
check "16 GB server needs no swap" 0 "$(swap_plan_gib 16000 0)"
check "partial GiB rounds up" 1 "$(swap_plan_gib 6000 2000)"
fails "non-numeric RAM is rejected" 'swap_plan_gib lots 0'

# --- memory parsing -----------------------------------------------------------
printf 'MemTotal:        2004060 kB\nMemFree:          100000 kB\nSwapTotal:             0 kB\n' >"$WORK/meminfo"
MEMINFO="$WORK/meminfo"
check "MemTotal in MiB" 1957 "$(ram_mib)"
check "SwapTotal in MiB" 0 "$(swap_mib)"
printf 'MemFree: 1 kB\n' >"$WORK/meminfo-broken"
fails "missing MemTotal is an error, not zero" 'MEMINFO="$WORK/meminfo-broken"; ram_mib'

# --- resource guards ----------------------------------------------------------
check "chat fits on 2 GB" "" "$(profile_ram_problem chat 1957)"
check "automation fits on 2 GB" "" "$(profile_ram_problem automation 1957)"
[[ "$(profile_ram_problem image 1957)" == *"8 GB"* ]]; check "ComfyUI blocked on 2 GB" 0 "$?"
[[ "$(profile_ram_problem openclaw 1957)" == *"16K"* ]]; check "OpenClaw blocked on 2 GB" 0 "$?"
check "ComfyUI allowed on 8 GB" "" "$(profile_ram_problem image 7900)"
fails "unknown part is rejected" 'profile_ram_problem bogus 9999'
printf 'COMPOSE_PROFILES=chat\n' >"$WORK/enable.env"
fails "enable rejects an unknown part" 'STACK_ENV_FILE="$WORK/enable.env" "$ROOT/stack" enable bogus'
check "a rejected part is not saved" "COMPOSE_PROFILES=chat" "$(cat "$WORK/enable.env")"
check "chat maps to open-webui" open-webui "$(profile_service chat)"
fails "openclaw is not a Docker service" 'profile_service openclaw'

# --- profile lists ------------------------------------------------------------
check "add to empty list" chat "$(list_add "" chat)"
check "add keeps order" chat,automation "$(list_add chat automation)"
check "add does not duplicate" chat,automation "$(list_add automation,chat automation)"
check "remove one" automation "$(list_remove chat,automation chat)"
check "remove last leaves empty" "" "$(list_remove chat chat)"
check "remove missing is harmless" chat "$(list_remove chat image)"
succeeds "list_has finds a member" 'list_has chat,automation automation'
fails "list_has rejects partial names" 'list_has chat,automation auto'

# --- model names ----------------------------------------------------------------
for name in qwen2.5-coder:1.5b all-minilm coder hf.co/user/repo:Q4_K_M; do succeeds "valid model $name" "valid_model_name '$name'"; done
for name in "" "bad name" 'x;rm -rf /' ':tag' 'a:b:c'; do fails "invalid model '$name'" "valid_model_name '$name'"; done

# --- Modelfile rendering ----------------------------------------------------------
printf 'Be careful.\nUse "quotes".\n' >"$WORK/prompt.md"
modelfile="$(render_modelfile qwen2.5-coder:1.5b "$WORK/prompt.md" 0.2 4096)"
check "Modelfile starts with FROM" "FROM qwen2.5-coder:1.5b" "$(head -1 <<<"$modelfile")"
check "Modelfile sets temperature" 1 "$(grep -c '^PARAMETER temperature 0.2$' <<<"$modelfile")"
check "Modelfile sets context" 1 "$(grep -c '^PARAMETER num_ctx 4096$' <<<"$modelfile")"
check "Modelfile keeps the prompt" 1 "$(grep -c '^Use "quotes".$' <<<"$modelfile")"
check "Modelfile closes the system block" '"""' "$(tail -1 <<<"$modelfile")"
printf 'bad """ prompt\n' >"$WORK/triple.md"
fails "triple quotes in a prompt are rejected" 'render_modelfile m "$WORK/triple.md" 0.2 4096'
: >"$WORK/empty.md"
fails "empty prompt is rejected" 'render_modelfile m "$WORK/empty.md" 0.2 4096'
fails "bad temperature is rejected" 'render_modelfile m "$WORK/prompt.md" hot 4096'
fails "tiny context is rejected" 'render_modelfile m "$WORK/prompt.md" 0.2 512'
for entry in "${ASSISTANTS[@]}"; do
  IFS='|' read -r name file temperature <<<"$entry"
  succeeds "shipped $name prompt renders" "render_modelfile qwen2.5-coder:1.5b '$ROOT/$file' $temperature 4096"
done

# --- .env handling ----------------------------------------------------------------
ensure_env >/dev/null
check ".env is private" 600 "$(stat -c %a "$STACK_ENV_FILE")"
first="$(env_get QDRANT_API_KEY)"
[[ "$first" =~ ^[0-9a-f]{64}$ ]]; check "secret is 64 hex characters" 0 "$?"
[[ "$(env_get WEBUI_SECRET_KEY)" != "$first" ]]; check "each secret is different" 0 "$?"
ensure_env >/dev/null
check "rerunning install keeps secrets" "$first" "$(env_get QDRANT_API_KEY)"
check "example values are copied" qwen2.5-coder:1.5b "$(env_get CHAT_MODEL)"
check "values with spaces survive" "Local AI" "$(env_get WEBUI_NAME)"
env_set CHAT_MODEL qwen2.5-coder:0.5b
check "env_set replaces a value" qwen2.5-coder:0.5b "$(env_get CHAT_MODEL)"
check "env_set leaves one line" 1 "$(grep -c '^CHAT_MODEL=' "$STACK_ENV_FILE")"
env_set NEW_SETTING a=b
check "env_set appends values containing =" a=b "$(env_get NEW_SETTING)"
check "env_set keeps the file private" 600 "$(stat -c %a "$STACK_ENV_FILE")"
check "missing setting reads empty" "" "$(env_get NOT_THERE)"
check "setting names do not match by prefix" "" "$(env_get CHAT)"
fails "lowercase setting name is rejected" 'env_set bad_key 1'
fails "line break in a value is rejected" "env_set KEY $'a\nb'"

# --- OS and Node checks ---------------------------------------------------------
printf 'ID=ubuntu\nVERSION_ID="24.04"\nVERSION_CODENAME=noble\n' >"$WORK/os"
succeeds "Ubuntu 24.04 is accepted" 'OS_RELEASE="$WORK/os"; check_os'
printf 'ID=debian\nVERSION_ID="12"\n' >"$WORK/os-debian"
fails "Debian is flagged" 'OS_RELEASE="$WORK/os-debian"; check_os'
for v in 24.16.0 24.22.1 26.1.0 27.0.0; do succeeds "OpenClaw accepts Node $v" "node_version_ok $v"; done
for v in 22.23.4 24.15.9 25.0.0 26.0.5 junk; do fails "OpenClaw rejects Node $v" "node_version_ok $v"; done

# --- command line ---------------------------------------------------------------
succeeds "help works" '"$ROOT/stack" help'
fails "unknown command fails" '"$ROOT/stack" frobnicate'
fails "enable without a name fails" 'main enable'
fails "ask needs a known assistant" 'main ask nobody hi'
if [[ $EUID -ne 0 ]]; then fails "install refuses without root" 'main install --yes'; fi

printf '\n%d passed, %d failed\n' "$passed" "$failed"
((failed == 0))
