# Persisting the Agnes API Key

This file contains the deep-dive material for persisting `AGNES_API_KEY`
across terminal sessions. The runtime contract is summarised in
`SKILL.md` -> `Base URL And Auth`; consult this file only when the user
explicitly asks to remember a key.

## When To Persist

If the user explicitly gives you an Agnes key and wants it remembered,
persist it for future terminal sessions instead of keeping it only in the
current process.

## Rules

- Save it as `AGNES_API_KEY`
- Detect the shell and write to the matching rc file:
  - zsh -> `~/.zshrc`
  - bash -> `~/.bashrc`
  - fallback -> `~/.profile`
- Update an existing `export AGNES_API_KEY=...` line if present
- Otherwise append a new export line
- Also export it in the current session immediately
- Do not echo the full key back after saving
- Tell the user which rc file you changed

## Reliable Shell Snippet

Use a non-interactive shell flow like this when saving a provided key:

```bash
AGNES_API_KEY_VALUE='USER_PROVIDED_KEY'
shell_name="$(basename "${SHELL:-}")"
case "$shell_name" in
  zsh) rc_file="$HOME/.zshrc" ;;
  bash) rc_file="$HOME/.bashrc" ;;
  *) rc_file="$HOME/.profile" ;;
esac

touch "$rc_file"
tmp_file="$(mktemp)"
grep -v '^export AGNES_API_KEY=' "$rc_file" > "$tmp_file" || true
printf '\nexport AGNES_API_KEY=%q\n' "$AGNES_API_KEY_VALUE" >> "$tmp_file"
mv "$tmp_file" "$rc_file"
export AGNES_API_KEY="$AGNES_API_KEY_VALUE"
unset AGNES_API_KEY_VALUE
```

After saving, continue using `AGNES_API_KEY` for the current task.

## Verify The Persisted Key

```bash
grep '^export AGNES_API_KEY=' "$HOME/.${shell_name}rc"
```

This should print exactly one line and the value must start with the
expected prefix. Never echo the full key back to the user.

## Cleanup

If the user asks to remove the key:

```bash
tmp_file="$(mktemp)"
grep -v '^export AGNES_API_KEY=' "$rc_file" > "$tmp_file" || true
mv "$tmp_file" "$rc_file"
unset AGNES_API_KEY
```

Always unset in the current session and confirm the rc file no longer
contains the export line.