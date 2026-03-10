#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper functions
print_status()  { echo -e "${GREEN}  $1${NC}"; }
print_warning() { echo -e "${YELLOW}  $1${NC}"; }
print_error()   { echo -e "${RED}  $1${NC}"; }

# Check if running on Linux
if [[ "$OSTYPE" != "linux"* ]]; then
    print_error "This script is designed for Linux only!"
    exit 1
fi

# Detect package manager
if command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
    PKG_INSTALL="sudo dnf install -y"
elif command -v apt-get &>/dev/null; then
    PKG_MGR="apt"
    PKG_INSTALL="sudo apt-get install -y"
elif command -v pacman &>/dev/null; then
    PKG_MGR="pacman"
    PKG_INSTALL="sudo pacman -S --noconfirm"
else
    print_error "No supported package manager found (dnf, apt, pacman)"
    exit 1
fi

# --- Define installable components ---
# Each component has: label, description, install function, and default state (1=selected)

COMPONENTS=(
    "System packages"
    "Oh My Zsh"
    "Zsh config"
    "Git config"
    "Kitty terminal"
    "Oh My Zsh custom files"
    "bat config"
    "Zed editor config"
    "Docker config"
    "SSH config"
    "mise (dev tool manager)"
    "uv (Python package manager)"
    "Set zsh as default shell"
)

DESCRIPTIONS=(
    "bat, curl, docker, fzf, gh, git, gnupg, htop, jq, ripgrep, tree, pipx, pnpm"
    "Framework for managing zsh configuration"
    "Symlink zsh dotfiles to home directory"
    "Symlink git config files to home directory"
    "Install Kitty and symlink its config"
    "Symlink custom Oh My Zsh plugin files"
    "Symlink bat configuration"
    "Symlink Zed editor settings"
    "Symlink Docker daemon config"
    "Copy SSH config and optionally create keys"
    "Polyglot runtime/tool version manager"
    "Fast Python package installer"
    "Change login shell to zsh"
)

# All selected by default
SELECTED=()
for i in "${!COMPONENTS[@]}"; do
    SELECTED+=("1")
done

# --- Interactive selection menu ---
show_menu() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "  Linux Dotfiles Installer"
    echo "  ========================${NC}"
    echo -e "  ${DIM}Dotfiles: ${DOTFILES_DIR}${NC}"
    echo -e "  ${DIM}Package manager: ${PKG_MGR}${NC}"
    echo ""
    echo -e "  Toggle items with their ${BOLD}number${NC}, then press ${BOLD}i${NC} to install."
    echo -e "  ${DIM}a = select all | n = select none | q = quit${NC}"
    echo ""

    for i in "${!COMPONENTS[@]}"; do
        local num=$((i + 1))
        if [[ "${SELECTED[$i]}" == "1" ]]; then
            local marker="${GREEN}[x]${NC}"
        else
            local marker="${DIM}[ ]${NC}"
        fi
        printf "  %s %2d) ${BOLD}%-28s${NC} ${DIM}%s${NC}\n" "$marker" "$num" "${COMPONENTS[$i]}" "${DESCRIPTIONS[$i]}"
    done

    echo ""
}

run_menu() {
    while true; do
        show_menu
        echo -ne "  ${CYAN}>${NC} "
        read -r choice

        case "$choice" in
            [0-9]|[0-9][0-9])
                local idx=$((choice - 1))
                if [[ $idx -ge 0 && $idx -lt ${#COMPONENTS[@]} ]]; then
                    if [[ "${SELECTED[$idx]}" == "1" ]]; then
                        SELECTED[$idx]="0"
                    else
                        SELECTED[$idx]="1"
                    fi
                fi
                ;;
            a|A)
                for i in "${!SELECTED[@]}"; do SELECTED[$i]="1"; done
                ;;
            n|N)
                for i in "${!SELECTED[@]}"; do SELECTED[$i]="0"; done
                ;;
            i|I)
                break
                ;;
            q|Q)
                echo -e "\n  ${DIM}Cancelled.${NC}"
                exit 0
                ;;
        esac
    done
}

# --- Component install functions ---

backup_and_link() {
    local source_file="$1"
    local target_file="$2"

    if [[ -f "$target_file" && ! -L "$target_file" ]]; then
        print_warning "Backing up existing $target_file to ${target_file}.backup"
        mv "$target_file" "${target_file}.backup"
    elif [[ -L "$target_file" ]]; then
        rm "$target_file"
    fi

    if [[ -f "$source_file" ]]; then
        ln -s "$source_file" "$target_file"
        print_status "Linked: $target_file -> $source_file"
    else
        print_error "Source file not found: $source_file"
        return 1
    fi
}

install_system_packages() {
    echo -e "\n${BLUE}Installing system packages via ${PKG_MGR}...${NC}"

    # Common package names (work across dnf/apt/pacman with minor differences)
    local -A pkg_map_dnf=(
        [bat]="bat" [curl]="curl" [fzf]="fzf" [gh]="gh"
        [gnupg]="gnupg2" [git]="git" [htop]="htop" [jq]="jq"
        [ripgrep]="ripgrep" [tree]="tree" [pipx]="pipx" [zsh]="zsh"
    )
    local -A pkg_map_apt=(
        [bat]="bat" [curl]="curl" [fzf]="fzf" [gh]="gh"
        [gnupg]="gnupg" [git]="git" [htop]="htop" [jq]="jq"
        [ripgrep]="ripgrep" [tree]="tree" [pipx]="pipx" [zsh]="zsh"
    )
    local -A pkg_map_pacman=(
        [bat]="bat" [curl]="curl" [fzf]="fzf" [gh]="github-cli"
        [gnupg]="gnupg" [git]="git" [htop]="htop" [jq]="jq"
        [ripgrep]="ripgrep" [tree]="tree" [pipx]="python-pipx" [zsh]="zsh"
    )

    local -n pkg_map="pkg_map_${PKG_MGR}"
    local packages=()
    for pkg in "${pkg_map[@]}"; do
        packages+=("$pkg")
    done

    $PKG_INSTALL "${packages[@]}"

    # Install pnpm via corepack or npm (not in most distro repos)
    if ! command -v pnpm &>/dev/null; then
        if command -v corepack &>/dev/null; then
            corepack enable pnpm && print_status "pnpm enabled via corepack"
        elif command -v npm &>/dev/null; then
            npm install -g pnpm && print_status "pnpm installed via npm"
        else
            print_warning "pnpm: install Node.js first, then run 'corepack enable pnpm'"
        fi
    else
        print_status "pnpm already installed"
    fi

    # Docker (Fedora/RHEL uses moby or docker-ce repo)
    if ! command -v docker &>/dev/null; then
        if [[ "$PKG_MGR" == "dnf" ]]; then
            echo -e "${YELLOW}Installing Docker via dnf...${NC}"
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo 2>/dev/null || true
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo systemctl enable --now docker
            sudo usermod -aG docker "$USER"
            print_status "Docker installed (log out and back in for group changes)"
        elif [[ "$PKG_MGR" == "apt" ]]; then
            print_warning "Docker: follow https://docs.docker.com/engine/install/ubuntu/ for your distro"
        elif [[ "$PKG_MGR" == "pacman" ]]; then
            $PKG_INSTALL docker docker-compose docker-buildx
            sudo systemctl enable --now docker
            sudo usermod -aG docker "$USER"
            print_status "Docker installed"
        fi
    else
        print_status "Docker already installed"
    fi

    print_status "System packages done"
}

install_oh_my_zsh() {
    echo -e "\n${BLUE}Installing Oh My Zsh...${NC}"
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_status "Oh My Zsh installed"
    else
        print_status "Oh My Zsh already installed"
    fi
}

install_zsh_config() {
    echo -e "\n${BLUE}Linking zsh configuration...${NC}"
    for file in "$DOTFILES_DIR/zsh"/.z*; do
        if [[ -f "$file" ]]; then
            backup_and_link "$file" "$HOME/$(basename "$file")"
        fi
    done
}

install_git_config() {
    echo -e "\n${BLUE}Linking git configuration...${NC}"
    for file in "$DOTFILES_DIR/git"/.git*; do
        if [[ -f "$file" ]]; then
            backup_and_link "$file" "$HOME/$(basename "$file")"
        fi
    done
}

install_kitty() {
    echo -e "\n${BLUE}Setting up Kitty terminal...${NC}"

    # Install kitty if not present
    if ! command -v kitty &>/dev/null; then
        echo -e "${YELLOW}Installing Kitty...${NC}"
        if [[ "$PKG_MGR" == "dnf" ]]; then
            $PKG_INSTALL kitty
        elif [[ "$PKG_MGR" == "apt" ]]; then
            $PKG_INSTALL kitty
        elif [[ "$PKG_MGR" == "pacman" ]]; then
            $PKG_INSTALL kitty
        fi
    else
        print_status "Kitty already installed"
    fi

    # Symlink config
    mkdir -p "$HOME/.config/kitty"
    if [[ -f "$DOTFILES_DIR/kitty/kitty.conf" ]]; then
        backup_and_link "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    else
        print_warning "Kitty config not found at $DOTFILES_DIR/kitty/kitty.conf"
    fi

    # Theme
    if [[ ! -f "$HOME/.config/kitty/current-theme.conf" ]]; then
        if command -v kitten &>/dev/null; then
            kitten themes --reload-in=all Catppuccin-Frappe
            print_status "Kitty theme installed"
        else
            print_warning "kitten not found; run 'kitten themes Catppuccin-Frappe' after Kitty is available"
        fi
    else
        print_status "Kitty theme already installed"
    fi
}

install_omz_custom() {
    echo -e "\n${BLUE}Linking Oh My Zsh custom files...${NC}"
    local omz_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    for file in "$DOTFILES_DIR/omz"/*.zsh; do
        if [[ -f "$file" ]]; then
            backup_and_link "$file" "$omz_custom/$(basename "$file")"
        fi
    done
}

install_bat_config() {
    echo -e "\n${BLUE}Linking bat configuration...${NC}"
    if [[ -f "$DOTFILES_DIR/bat/config" ]]; then
        mkdir -p "$HOME/.config/bat"
        backup_and_link "$DOTFILES_DIR/bat/config" "$HOME/.config/bat/config"
    else
        print_warning "bat config not found at $DOTFILES_DIR/bat/config"
    fi
}

install_zed_config() {
    echo -e "\n${BLUE}Linking Zed configuration...${NC}"
    if [[ -f "$DOTFILES_DIR/zed/settings.json" ]]; then
        mkdir -p "$HOME/.config/zed"
        backup_and_link "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
    else
        print_warning "Zed settings file not found at $DOTFILES_DIR/zed/settings.json"
    fi
}

install_docker_config() {
    echo -e "\n${BLUE}Linking Docker configuration...${NC}"
    # On Linux we don't use Colima, so use a plain daemon config or skip if none exists
    if [[ -f "$DOTFILES_DIR/docker/linux.config.json" ]]; then
        mkdir -p "$HOME/.docker"
        backup_and_link "$DOTFILES_DIR/docker/linux.config.json" "$HOME/.docker/config.json"
    elif [[ -f "$DOTFILES_DIR/docker/macos.config.json" ]]; then
        print_warning "Only macOS Docker config found; skipping (create docker/linux.config.json if needed)"
    else
        print_warning "No Docker config found in $DOTFILES_DIR/docker/"
    fi
}

install_ssh_config() {
    echo -e "\n${BLUE}Setting up SSH configuration...${NC}"
    if [[ ! -f "$DOTFILES_DIR/ssh/config" ]]; then
        print_warning "SSH config file not found at $DOTFILES_DIR/ssh/config"
        return
    fi

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    if [[ -f "$HOME/.ssh/config" && ! -L "$HOME/.ssh/config" ]]; then
        print_warning "Backing up existing ~/.ssh/config to ~/.ssh/config.backup"
        cp "$HOME/.ssh/config" "$HOME/.ssh/config.backup"
    elif [[ -L "$HOME/.ssh/config" ]]; then
        rm "$HOME/.ssh/config"
    fi

    # Adapt SSH config for Linux: remove UseKeychain (macOS-only directive)
    sed 's/UseKeychain yes/# UseKeychain yes  # macOS only/' \
        "$DOTFILES_DIR/ssh/config" > "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    print_status "SSH config installed (UseKeychain disabled for Linux)"

    # Prompt for SSH key creation
    echo -e "${BLUE}Checking for SSH keys specified in config...${NC}"
    local identity_files
    identity_files=$(grep "IdentityFile" "$DOTFILES_DIR/ssh/config" | awk '{print $2}' | sed "s|~|$HOME|g")

    for key_file in $identity_files; do
        if [[ ! -f "$key_file" ]]; then
            echo -e "${YELLOW}SSH key not found: $key_file${NC}"
            read -p "  Create this SSH key? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                read -p "  Email for the key: " email
                ssh-keygen -t ed25519 -C "$email" -f "$key_file"
                print_status "Created SSH key: $key_file"
                echo -e "${BLUE}Public key (add to your Git provider):${NC}"
                cat "${key_file}.pub"
                echo
            else
                print_warning "Skipped creating SSH key: $key_file"
            fi
        else
            print_status "SSH key already exists: $key_file"
        fi
    done
}

install_mise() {
    echo -e "\n${BLUE}Installing mise...${NC}"
    if ! command -v mise &>/dev/null; then
        curl https://mise.run | sh
        print_status "mise installed"
    else
        print_status "mise already installed"
    fi

    if [[ -f "$DOTFILES_DIR/mise/config.toml" ]]; then
        mkdir -p "$HOME/.config/mise"
        backup_and_link "$DOTFILES_DIR/mise/config.toml" "$HOME/.config/mise/config.toml"
    fi
}

install_uv() {
    echo -e "\n${BLUE}Installing uv...${NC}"
    if ! command -v uv &>/dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        print_status "uv installed"
    else
        print_status "uv already installed"
    fi
}

set_default_shell() {
    echo -e "\n${BLUE}Setting zsh as default shell...${NC}"
    if [[ "$SHELL" != *"zsh"* ]]; then
        local zsh_path
        zsh_path="$(which zsh)"
        # Ensure zsh is in /etc/shells
        if ! grep -q "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        fi
        chsh -s "$zsh_path"
        print_status "Default shell set to zsh (takes effect on next login)"
    else
        print_status "zsh is already the default shell"
    fi
}

# --- Map component indices to install functions ---
INSTALL_FUNCTIONS=(
    install_system_packages
    install_oh_my_zsh
    install_zsh_config
    install_git_config
    install_kitty
    install_omz_custom
    install_bat_config
    install_zed_config
    install_docker_config
    install_ssh_config
    install_mise
    install_uv
    set_default_shell
)

# --- Parse CLI arguments ---
ALL_YES=false
HELP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            ALL_YES=true
            shift
            ;;
        -h|--help)
            HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

if [[ "$HELP" == "true" ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -y, --yes    Install all components without prompting"
    echo "  -h, --help   Show this help message"
    exit 0
fi

# --- Main ---
if [[ "$ALL_YES" == "false" ]]; then
    run_menu
fi

# Count selected
selected_count=0
for s in "${SELECTED[@]}"; do
    [[ "$s" == "1" ]] && ((selected_count++))
done

if [[ $selected_count -eq 0 ]]; then
    echo -e "\n  ${DIM}Nothing selected. Exiting.${NC}"
    exit 0
fi

echo ""
echo -e "${BOLD}${BLUE}  Installing ${selected_count} component(s)...${NC}"
echo ""

for i in "${!COMPONENTS[@]}"; do
    if [[ "${SELECTED[$i]}" == "1" ]]; then
        ${INSTALL_FUNCTIONS[$i]}
    fi
done

echo ""
echo -e "${GREEN}${BOLD}  Setup complete!${NC}"
echo -e "${BLUE}  Restart your terminal or run 'source ~/.zshrc' to apply changes.${NC}"
