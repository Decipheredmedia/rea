#!/usr/bin/env bash
# Integration test: runs the real stack in Docker under a separate project
# name and ports, so it never touches a real install on the same server.
#
#   bash tests/integration.sh
#
# By default it downloads the real models from .env.example. To test offline,
# point these at local GGUF files (any chat model and any embedding model):
#   STACK_TEST_CHAT_GGUF=/path/chat.gguf STACK_TEST_EMBED_GGUF=/path/embed.gguf
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
export STACK_PROJECT=local-ai-stack-test
export STACK_ENV_FILE="$WORK/.env"
export STACK_BACKUP_DIR="$WORK/backups"
STACK="$ROOT/stack"
# shellcheck source=stack
source "$STACK"

passed=0
pass() { passed=$((passed + 1)); printf 'ok   %s\n' "$1"; }
die_test() { printf 'FAIL %s\n' "$1" >&2; exit 1; }
cleanup() {
  compose --profile chat --profile automation --profile image down --volumes >/dev/null 2>&1 || true
  rm -rf "$WORK"
}
trap cleanup EXIT

ensure_env >/dev/null
env_set COMPOSE_PROFILES ""
env_set OLLAMA_PORT 21434
env_set QDRANT_PORT 26333
env_set N8N_PORT 25678
"$STACK" up >/dev/null
pass "Ollama and Qdrant start and report healthy"

import_gguf() { # name, file
  local container
  container="$(compose ps -q ollama)"
  docker cp "$2" "$container:/tmp/$1.gguf" >/dev/null
  printf 'FROM /tmp/%s.gguf\n' "$1" | docker exec -i "$container" sh -c "cat > /tmp/$1.Modelfile"
  docker exec "$container" ollama create "$1" -f "/tmp/$1.Modelfile" >/dev/null
}
if [[ -n "${STACK_TEST_CHAT_GGUF:-}" ]]; then
  import_gguf testchat "$STACK_TEST_CHAT_GGUF"
  env_set CHAT_MODEL testchat
fi
if [[ -n "${STACK_TEST_EMBED_GGUF:-}" ]]; then
  import_gguf testembed "$STACK_TEST_EMBED_GGUF"
  env_set EMBED_MODEL testembed
fi

"$STACK" models >/dev/null
"$STACK" models >/dev/null
pass "models command runs twice without errors"

system="$(ollama_cli show coder --system)"
[[ "$system" == *"detail-obsessed software engineer"* ]] || die_test "coder carries the coding prompt"
pass "coder assistant carries the coding prompt"
system="$(ollama_cli show debugger --system)"
[[ "$system" == *"senior debugging engineer"* && "$system" == *"11. **Don't introduce new issues.**"* ]] ||
  die_test "debugger carries the renumbered debugging prompt"
pass "debugger assistant carries the renumbered debugging prompt"
[[ "$(ollama_cli show coder --parameters)" == *"temperature"*"0.2"* ]] || die_test "coder temperature"
pass "coder assistant uses temperature 0.2"

answer="$("$STACK" ask coder "Write hello world in Python")"
[[ -n "$answer" ]] || die_test "ask coder returns text"
pass "ask coder answers"
answer="$(printf 'TypeError: x is undefined\n' | "$STACK" ask debugger)"
[[ -n "$answer" ]] || die_test "ask debugger reads piped input"
pass "ask debugger answers piped input"

# Document memory: Ollama embeds text, Qdrant stores and finds it.
key="$(env_get QDRANT_API_KEY)"
qdrant() { curl -fsS -H "api-key: $key" -H 'Content-Type: application/json' "$@"; }
vector="$(curl -fsS http://127.0.0.1:21434/api/embed -d "{\"model\":\"$(env_get EMBED_MODEL)\",\"input\":\"how do I fix this bug\"}" |
  python3 -c 'import json,sys; print(json.dumps(json.load(sys.stdin)["embeddings"][0]))')"
size="$(python3 -c 'import json,sys; print(len(json.loads(sys.argv[1])))' "$vector")"
((size > 0)) || die_test "embedding has a size"
qdrant -X PUT http://127.0.0.1:26333/collections/test -d "{\"vectors\":{\"size\":$size,\"distance\":\"Cosine\"}}" >/dev/null
qdrant -X PUT 'http://127.0.0.1:26333/collections/test/points?wait=true' \
  -d "{\"points\":[{\"id\":7,\"vector\":$vector,\"payload\":{\"text\":\"fix bugs\"}}]}" >/dev/null
hit="$(qdrant -X POST http://127.0.0.1:26333/collections/test/points/search -d "{\"vector\":$vector,\"limit\":1}" |
  python3 -c 'import json,sys; print(json.load(sys.stdin)["result"][0]["id"])')"
[[ "$hit" == 7 ]] || die_test "Qdrant finds the stored document"
pass "Ollama embeddings are stored in and found by Qdrant"
code="$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:26333/collections)"
[[ "$code" == 401 || "$code" == 403 ]] || die_test "Qdrant requires its API key (got $code)"
pass "Qdrant rejects requests without the API key"

"$STACK" doctor >/dev/null || die_test "doctor passes"
pass "doctor passes"

"$STACK" backup >/dev/null
[[ -s "$(ls "$STACK_BACKUP_DIR"/qdrant-*.tar.gz)" ]] || die_test "backup writes a Qdrant archive"
"$STACK" doctor >/dev/null || die_test "services come back after backup"
pass "backup saves Qdrant and restarts the stack"

printf 'MemTotal: 2004060 kB\nSwapTotal: 4194300 kB\n' >"$WORK/meminfo-2gb"
if STACK_MEMINFO="$WORK/meminfo-2gb" "$STACK" enable image >"$WORK/out" 2>&1; then die_test "ComfyUI is refused on 2 GB"; fi
grep -q "8 GB" "$WORK/out" || die_test "refusal explains the RAM requirement"
[[ -z "$(env_get COMPOSE_PROFILES)" ]] || die_test "refused part is not saved"
pass "ComfyUI is refused on a 2 GB server with an explanation"

STACK_MEMINFO="$WORK/meminfo-2gb" "$STACK" enable automation >/dev/null
[[ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:25678/healthz)" == 200 ]] || die_test "n8n answers"
pass "n8n starts on a 2 GB budget and answers"
"$STACK" disable automation >/dev/null
[[ -z "$(compose ps -q n8n)" ]] || die_test "n8n container removed"
pass "disable removes n8n and keeps the rest running"

printf '\n%d checks passed\n' "$passed"
