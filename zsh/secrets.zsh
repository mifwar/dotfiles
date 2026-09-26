# Load the key only when needed, so a slow password store cannot block every
# new terminal. Decrypt the existing pass file directly to avoid pass invoking
# Homebrew just to locate gnu-getopt.
secrets-unlock() {
  export DEEPSEEK_API_KEY="$(gpg --quiet --decrypt "$HOME/.password-store/deepseek/api-key/hermes.gpg" 2>/dev/null | head -1)"
  [ -n "$DEEPSEEK_API_KEY" ] && echo "secrets loaded" || echo "failed" >&2
}
