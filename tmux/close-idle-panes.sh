#!/bin/bash
# Close only shells tracked from startup and never used or typed into.
set -euo pipefail

window=${1:?window ID required}
original_active=${2:?active pane ID required}
closed=0

while IFS= read -r pane; do
    # Recheck each pane immediately before closing it. Keep both the original
    # active pane and whichever pane is active now if focus changed meanwhile.
    [[ "$pane" != "$original_active" ]] || continue
    info=$(tmux display-message -p -t "$pane" \
        $'#{window_id}\t#{pane_active}\t#{pane_pid}\t#{pane_current_command}\t#{@unused_shell}\t#{@unused_shell_pid}') || continue
    IFS=$'\t' read -r pane_window active pid command unused tracked_pid <<< "$info"
    [[ "$pane_window" == "$window" && "$active" == 0 ]] || continue
    [[ "$command" == zsh && "$unused" == 1 && "$tracked_pid" == "$pid" ]] || continue
    # Background jobs also count as work, even when the shell has the foreground.
    if pgrep -P "$pid" >/dev/null; then
        continue
    else
        status=$?
        [[ "$status" == 1 ]] || continue
    fi
    if tmux kill-pane -t "$pane"; then
        closed=$((closed + 1))
    fi
done < <(tmux list-panes -t "$window" -F '#{pane_id}')

tmux display-message -t "$original_active" "Closed $closed untouched pane(s); active and untracked panes are kept."
