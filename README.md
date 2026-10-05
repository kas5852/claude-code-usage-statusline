# claude-code-usage-statusline

A status line for Claude Code that shows how much of your plan is left.

```
Opus  │  5h ━━━━━━── 72% left · ↻ 2h14m  │  week ━━━━━─── 61% left · ↻ 3d4h  │  ctx 38%
```

- **5h**: the current 5-hour session window, with the time until it resets
- **week**: the 7-day window, with the time until it resets
- **ctx**: how much of the context window is used

The bars go green, then amber under 50%, then red under 20%. Usage shows up after the first reply in a session.

It reads everything from the JSON Claude Code passes to the status line, so it makes no network calls and needs no API key.

## Install

Needs `bash` and `jq`.

```sh
curl -fsSL https://raw.githubusercontent.com/kas5852/claude-code-usage-statusline/main/statusline.sh -o ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

Then add this to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

The status line docs are at https://code.claude.com/docs/en/statusline.
