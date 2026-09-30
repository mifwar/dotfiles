# Source only during initial interactive .zshrc startup, never in an old shell.
[[ -n ${TMUX_PANE:-} ]] || return
[[ $(tmux display-message -p -t "$TMUX_PANE" '#{pane_pid}') == $$ ]] || return
[[ -z ${_tmux_unused_tracking_loaded:-} ]] || return
typeset -g _tmux_unused_tracking_loaded=1

# Existing metadata survives re-sourcing; a used pane never becomes unused again.
if [[ -z $(tmux show-option -pqv -t "$TMUX_PANE" @unused_shell_pid) ]]; then
    tmux set-option -p -t "$TMUX_PANE" @unused_shell_pid "$$"
    tmux set-option -p -t "$TMUX_PANE" @unused_shell 1
fi
typeset -g _tmux_unused_shell=$(tmux show-option -pqv -t "$TMUX_PANE" @unused_shell)

_tmux_mark_pane_used() {
    if [[ $_tmux_unused_shell == 1 ]]; then
        typeset -g _tmux_unused_shell=0
        tmux set-option -p -t "$TMUX_PANE" @unused_shell 0
    fi
    return 0
}

_tmux_mark_pane_input() {
    # Keep panes with unfinished input too, even if nothing was executed.
    [[ -z $BUFFER ]] || _tmux_mark_pane_used
    return 0
}

autoload -Uz add-zsh-hook add-zle-hook-widget
add-zsh-hook preexec _tmux_mark_pane_used
add-zle-hook-widget line-pre-redraw _tmux_mark_pane_input
