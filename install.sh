#!/bin/bash

# Dotfiles Installation Script
# This script sets up dotfiles configuration on a fresh Mac

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only!"
    exit 1
fi

# Require an interactive TTY so the confirmation prompt and lazy.nvim bootstrap work.
if [[ ! -t 0 ]]; then
    print_error "This installer must be run from an interactive terminal (don't pipe into it)."
    print_error "  Instead of:  curl ... | bash"
    print_error "  Do:          curl ... -o install.sh && bash install.sh"
    exit 1
fi

print_info "Starting dotfiles installation..."

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
print_info "Dotfiles directory: $DOTFILES_DIR"

# Function to backup existing file/directory
backup_if_exists() {
    local target=$1
    if [[ -e "$target" && ! -L "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    elif [[ -L "$target" ]]; then
        print_info "Removing existing symlink: $target"
        rm "$target"
    fi
}

# Function to create symlink
create_symlink() {
    local source=$1
    local target=$2
    local target_dir
    target_dir=$(dirname "$target")

    print_info "Creating symlink: $target -> $source"

    # Create target directory if it doesn't exist
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        print_info "Created directory: $target_dir"
    fi

    # Backup existing file/directory
    backup_if_exists "$target"

    # Create symlink
    ln -s "$source" "$target"
    print_success "Created symlink: $target"
}

# Check for required tools and install if needed
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_success "Homebrew installed"
    else
        print_info "Homebrew already installed"
    fi
}

install_dependencies() {
    print_info "Installing dependencies..."

    # Install Homebrew if not present
    install_homebrew

    # Prefer a declarative Brewfile when present, falling back to the explicit
    # package list so the installer still works if brew bundle is unavailable.
    if [[ -f "$DOTFILES_DIR/Brewfile" ]] && brew help bundle &> /dev/null; then
        print_info "Installing from Brewfile..."
        brew bundle --file="$DOTFILES_DIR/Brewfile" || print_warning "Some Brewfile entries failed to install"
        return
    fi

    # Fallback: install each package individually.
    local packages=(
        "neovim"
        "tmux"
        "yabai"
        "skhd"
        "starship"
        "cliclick"
        "jq"
        # pass + gpg are required by bin/passc
        "gnupg"
        "pinentry-mac"
        "pass"
    )

    for package in "${packages[@]}"; do
        if ! brew list "$package" &> /dev/null; then
            print_info "Installing $package..."
            brew install "$package"
            print_success "$package installed"
        else
            print_info "$package already installed"
        fi
    done
}

# Create symlinks for all configurations
setup_symlinks() {
    print_info "Setting up configuration symlinks..."

    # Neovim
    if [[ -d "$DOTFILES_DIR/nvim" ]]; then
        create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    fi

    # Tmux
    if [[ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]]; then
        create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    fi

    # Yabai
    if [[ -d "$DOTFILES_DIR/yabai" ]]; then
        create_symlink "$DOTFILES_DIR/yabai" "$HOME/.config/yabai"
    fi

    # SKHD
    if [[ -d "$DOTFILES_DIR/skhd" ]]; then
        create_symlink "$DOTFILES_DIR/skhd" "$HOME/.config/skhd"
    fi

    # Starship
    if [[ -f "$DOTFILES_DIR/starship.toml" ]]; then
        create_symlink "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
    fi

    # Ghostty
    if [[ -f "$DOTFILES_DIR/ghostty/config" ]]; then
        create_symlink "$DOTFILES_DIR/ghostty/config" \
            "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
    fi

    # Pi coding agent (safe config only; auth/sessions stay local)
    if [[ -f "$DOTFILES_DIR/pi/keybindings.json" ]]; then
        create_symlink "$DOTFILES_DIR/pi/keybindings.json" "$HOME/.pi/agent/keybindings.json"
    fi
    if [[ -f "$DOTFILES_DIR/pi/settings.json" ]]; then
        create_symlink "$DOTFILES_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
    fi
    if [[ -f "$DOTFILES_DIR/pi/models.json" ]]; then
        create_symlink "$DOTFILES_DIR/pi/models.json" "$HOME/.pi/agent/models.json"
    fi
}

# Build the `tc` Swift helper (transient pasteboard copy) and symlink `passc`
# into ~/.local/bin. See bin/README.md for the rationale.
setup_pass_tools() {
    local bin_dir="$DOTFILES_DIR/bin"
    [[ -d "$bin_dir" ]] || return 0

    # Ensure ~/.local/bin exists and is on PATH. Some macOS shells don't
    # include it by default.
    mkdir -p "$HOME/.local/bin"
    if ! [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
        print_warning "~/.local/bin is not on PATH. Add it to your shell rc:"
        print_warning "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi

    # Xcode Command Line Tools are required to compile the Swift helper.
    if ! command -v swiftc &>/dev/null; then
        print_warning "swiftc not found. Install Xcode CLT with: xcode-select --install"
        print_warning "    (then re-run install.sh to build tc)"
        return 0
    fi

    # Compile `tc` if source present and binary missing. Swift sources are
    # committed; the compiled binary is gitignored and per-arch, so we
    # always rebuild rather than symlink a foreign-arch binary.
    if [[ -f "$bin_dir/tc.swift" && ! -x "$bin_dir/tc" ]]; then
        print_info "Compiling tc (transient pasteboard helper)..."
        if (cd "$bin_dir" && swiftc tc.swift -o tc); then
            print_success "Compiled $bin_dir/tc"
        else
            print_warning "Failed to compile tc — passc will not work until you build it manually."
            return 0
        fi
    fi

    # Symlink the wrapper script + the Swift binary so `passc` is on PATH
    # and can find `tc` next to it.
    if [[ -f "$bin_dir/passc" ]]; then
        create_symlink "$bin_dir/passc" "$HOME/.local/bin/passc"
    fi
    if [[ -x "$bin_dir/tc" ]]; then
        create_symlink "$bin_dir/tc" "$HOME/.local/bin/tc"
    fi
}

# Setup tmux plugin manager
setup_tmux() {
    print_info "Setting up tmux..."

    # Install TPM (Tmux Plugin Manager) if not present
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        print_success "TPM installed"
        print_info "Run 'tmux source ~/.tmux.conf' and press 'Ctrl-a I' to install tmux plugins"
    else
        print_info "TPM already installed"
    fi
}

# Setup yabai and skhd services via brew services (handles launchd plists)
setup_window_management() {
    print_info "Setting up window management services..."

    if command -v yabai &> /dev/null; then
        print_info "Starting yabai service via brew services..."
        brew services start yabai || print_warning "Could not start yabai. Start manually with: brew services start yabai"
    fi

    if command -v skhd &> /dev/null; then
        print_info "Starting skhd service via brew services..."
        brew services start skhd || print_warning "Could not start skhd. Start manually with: brew services start skhd"
    fi

    print_info "Note: yabai/skhd require Accessibility (and yabai needs Screen Recording) permissions."
    print_info "      System Settings -> Privacy & Security -> Accessibility / Screen Recording"
}

# Main installation process
main() {
    print_info "========================================"
    print_info "       Dotfiles Installation"
    print_info "========================================"

    # Ask for confirmation
    read -p "This will install/update your dotfiles configuration. Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi

    # Install dependencies
    install_dependencies

    # Setup symlinks
    setup_symlinks

    # Setup additional tools
    setup_tmux
    setup_window_management
    setup_pass_tools

    print_success "========================================"
    print_success "   Dotfiles installation complete!"
    print_success "========================================"

    print_info "Next steps:"
    print_info "1. Restart your terminal or run 'source ~/.zshrc'"
    print_info "2. Open tmux and install plugins with 'Ctrl-a I'"
    print_info "3. Open Neovim and let lazy.nvim install plugins"
    print_info "4. Configure yabai/skhd permissions in System Settings if needed"
}

# Run main function
main "$@"
