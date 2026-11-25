#!/usr/bin/env bash
# Sync a Claude Code auto-memory directory with its git remote.
#   memory-sync.sh pull  <dir>   # SessionStart: fast-forward from the remote
#   memory-sync.sh push  <dir>   # Stop: commit any changes and push
# Silent and non-fatal on every failure path so a flaky network never blocks a
# session; set MEMORY_SYNC_DEBUG=1 to see what it did.
set -u
mode="${1:?pull|push}"; dir="${2:?memory dir}"
log() { [ -n "${MEMORY_SYNC_DEBUG:-}" ] && echo "memory-sync[$mode]: $*" >&2; return 0; }
[ -d "$dir/.git" ] || { log "not a git repo, skipping"; exit 0; }
cd "$dir" || exit 0
git remote get-url origin >/dev/null 2>&1 || { log "no origin remote, skipping"; exit 0; }
branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo main)
case "$mode" in
  pull)
    # Never clobber local edits: commit them first so pull can merge/ff.
    if [ -n "$(git status --porcelain)" ]; then
      git add -A && git commit -q -m "memory: local changes before pull ($(hostname))" || true
    fi
    if git pull -q --rebase --autostash origin "$branch" 2>/dev/null; then
      log "pulled"
    else
      git rebase --abort >/dev/null 2>&1 || true
      log "pull failed (offline or conflict) — left as is"
    fi
    ;;
  push)
    if [ -n "$(git status --porcelain)" ]; then
      git add -A && git commit -q -m "memory: $(date -u +%Y-%m-%dT%H:%MZ) ($(hostname))" || true
    fi
    if [ -n "$(git log origin/"$branch"..HEAD 2>/dev/null)" ] || ! git rev-parse origin/"$branch" >/dev/null 2>&1; then
      git push -q -u origin "$branch" 2>/dev/null && log "pushed" || log "push failed (offline?) — will retry next time"
    else
      log "nothing to push"
    fi
    ;;
esac
exit 0
