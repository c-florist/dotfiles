#!/bin/bash

set -e  # Exit on any error

# Parse command line arguments
SKIP_BREW=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-brew)
            SKIP_BREW=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --skip-brew    Skip Brewfile package installation"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 Starting macOS dotfiles setup...${NC}"
echo -e "${BLUE}Dotfiles directory: ${DOTFILES_DIR}${NC}"
if [[ "$SKIP_BREW" == "true" ]]; then
    echo -e "${YELLOW}⚠️  Skipping Brewfile installation${NC}"
fi

# Function to print status messages
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only!"
    exit 1
fi

# Install Xcode Command Line Tools if not already installed
if ! xcode-select -p &>/dev/null; then
    echo -e "${YELLOW}Installing Xcode Command Line Tools...${NC}"
    xcode-select --install
    echo "Please complete the Xcode Command Line Tools installation and run this script again."
    exit 1
else
    print_status "Xcode Command Line Tools already installed"
fi

# Install Homebrew if not already installed
if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    eval "$(/opt/homebrew/bin/brew shellenv)"
    print_status "Homebrew installed successfully"
else
    print_status "Homebrew already installed"
fi

# Install Oh My Zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo -e "${YELLOW}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_status "Oh My Zsh installed successfully"
else
    print_status "Oh My Zsh already installed"
fi

# Install Homebrew packages from Brewfile
if [[ "$SKIP_BREW" == "true" ]]; then
    print_warning "Skipping Brewfile installation as requested"
elif [[ -f "$DOTFILES_DIR/homebrew/Brewfile" ]]; then
    echo -e "${YELLOW}Installing Homebrew packages from Brewfile...${NC}"
    
    # Check if all packages are already installed
    if brew bundle check --file="$DOTFILES_DIR/homebrew/Brewfile" &>/dev/null; then
        print_status "All Brewfile packages already installed"
    else
        print_warning "Installing missing packages (without upgrading existing ones)..."
        # Use --no-upgrade to avoid unnecessary upgrades that can cause issues
        brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile" --no-upgrade || {
            print_warning "Some packages failed to install, but continuing..."
            # Don't exit on error for brew bundle since some packages might fail
            set +e
        }
        set -e
    fi
    
    print_status "Homebrew packages processed successfully"
else
    print_warning "Brewfile not found at $DOTFILES_DIR/homebrew/Brewfile"
fi

# Create symlinks for zsh configuration files
echo -e "${YELLOW}Creating symlinks for zsh configuration files...${NC}"

# Backup existing files if they exist and are not symlinks
backup_and_link() {
    local source_file="$1"
    local target_file="$2"
    
    if [[ -f "$target_file" && ! -L "$target_file" ]]; then
        print_warning "Backing up existing $target_file to ${target_file}.backup"
        mv "$target_file" "${target_file}.backup"
    elif [[ -L "$target_file" ]]; then
        print_warning "Removing existing symlink $target_file"
        rm "$target_file"
    fi
    
    if [[ -f "$source_file" ]]; then
        ln -s "$source_file" "$target_file"
        print_status "Created symlink: $target_file -> $source_file"
    else
        print_error "Source file not found: $source_file"
        return 1
    fi
}

# Create symlinks for each file in ./zsh directory
for file in "$DOTFILES_DIR/zsh"/.z*; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        backup_and_link "$file" "$HOME/$filename"
    fi
done

# Create symlinks for git configuration files
echo -e "${YELLOW}Creating symlinks for git configuration files...${NC}"
for file in "$DOTFILES_DIR/git"/.git*; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        backup_and_link "$file" "$HOME/$filename"
    fi
done

# Install mise-en-place if not already installed
if ! command -v mise &>/dev/null; then
    echo -e "${YELLOW}Installing mise...${NC}"
    curl https://mise.run | sh
    print_status "mise installed successfully"
else
    print_status "mise already installed"
fi

# Create symlink for mise config file
echo -e "${YELLOW}Creating symlink for mise configuration...${NC}"
if [[ -f "$DOTFILES_DIR/mise/config.toml" ]]; then
    backup_and_link "$DOTFILES_DIR/mise/config.toml" "$HOME/.config/mise/config.toml"
else
    print_warning "mise config file not found at $DOTFILES_DIR/mise/config.toml"
fi

# Create symlinks for Kitty configuration
echo -e "${YELLOW}Creating symlinks for Kitty configuration...${NC}"
mkdir -p "$HOME/.config/kitty"
if [[ -f "$DOTFILES_DIR/kitty/kitty.conf" ]]; then
    backup_and_link "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
else
    print_warning "Kitty config not found at $DOTFILES_DIR/kitty/kitty.conf"
fi

# Install Kitty theme if not already present
if [[ ! -f "$HOME/.config/kitty/current-theme.conf" ]]; then
    if command -v kitten &>/dev/null; then
        echo -e "${YELLOW}Installing Kitty theme (Catppuccin-Frappe)...${NC}"
        kitten themes --reload-in=all Catppuccin-Frappe
        print_status "Kitty theme installed"
    else
        print_warning "kitten not found, install Kitty first then run: kitten themes Catppuccin-Frappe"
    fi
else
    print_status "Kitty theme already installed"
fi

# Create symlinks for Oh My Zsh custom files
echo -e "${YELLOW}Setting up Oh My Zsh custom files...${NC}"
OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for file in "$DOTFILES_DIR/omz"/*.zsh; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        backup_and_link "$file" "$OMZ_CUSTOM/$filename"
    fi
done

# Create symlink for bat config
echo -e "${YELLOW}Creating symlink for bat configuration...${NC}"
if [[ -f "$DOTFILES_DIR/bat/config" ]]; then
    mkdir -p "$HOME/.config/bat"
    backup_and_link "$DOTFILES_DIR/bat/config" "$HOME/.config/bat/config"
else
    print_warning "bat config not found at $DOTFILES_DIR/bat/config"
fi

# Create symlink for Zed settings
echo -e "${YELLOW}Creating symlink for Zed configuration...${NC}"
if [[ -f "$DOTFILES_DIR/zed/settings.json" ]]; then
    mkdir -p "$HOME/.config/zed"
    backup_and_link "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
else
    print_warning "Zed settings file not found at $DOTFILES_DIR/zed/settings.json"
fi

# Create symlink for Docker config
echo -e "${YELLOW}Creating symlink for Docker configuration...${NC}"
if [[ -f "$DOTFILES_DIR/docker/macos.config.json" ]]; then
    mkdir -p "$HOME/.docker"
    backup_and_link "$DOTFILES_DIR/docker/macos.config.json" "$HOME/.docker/config.json"
else
    print_warning "Docker config file not found at $DOTFILES_DIR/docker/macos.config.json"
fi

# Setup SSH configuration
echo -e "${YELLOW}Setting up SSH configuration...${NC}"
if [[ -f "$DOTFILES_DIR/ssh/config" ]]; then
    # Create ~/.ssh directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Copy SSH config file (not symlink for security)
    if [[ -f "$HOME/.ssh/config" && ! -L "$HOME/.ssh/config" ]]; then
        print_warning "Backing up existing ~/.ssh/config to ~/.ssh/config.backup"
        cp "$HOME/.ssh/config" "$HOME/.ssh/config.backup"
    elif [[ -L "$HOME/.ssh/config" ]]; then
        print_warning "Removing existing symlink ~/.ssh/config"
        rm "$HOME/.ssh/config"
    fi
    
    cp "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    print_status "SSH config copied to ~/.ssh/config"
    
    # Extract IdentityFile entries and prompt for key creation
    echo -e "${BLUE}Checking for SSH keys specified in config...${NC}"
    identity_files=$(grep "IdentityFile" "$DOTFILES_DIR/ssh/config" | awk '{print $2}' | sed 's|~|'$HOME'|g')
    
    for key_file in $identity_files; do
        if [[ ! -f "$key_file" ]]; then
            echo -e "${YELLOW}SSH key not found: $key_file${NC}"
            read -p "Would you like to create this SSH key? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                read -p "Enter your email for the SSH key: " email
                ssh-keygen -t ed25519 -C "$email" -f "$key_file"
                print_status "Created SSH key: $key_file"
                echo -e "${BLUE}Public key content (add this to your Git provider):${NC}"
                cat "${key_file}.pub"
                echo
            else
                print_warning "Skipped creating SSH key: $key_file"
            fi
        else
            print_status "SSH key already exists: $key_file"
        fi
    done
else
    print_warning "SSH config file not found at $DOTFILES_DIR/ssh/config"
fi

# Install uv if not already installed
if ! command -v uv &>/dev/null; then
    echo -e "${YELLOW}Installing uv...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    print_status "uv installed successfully"
else
    print_status "uv already installed"
fi

# Set zsh as the default shell if it isn't already
if [[ "$SHELL" != "/bin/zsh" && "$SHELL" != "/usr/bin/zsh" ]]; then
    echo -e "${YELLOW}Setting zsh as default shell...${NC}"
    chsh -s "$(which zsh)"
    print_status "Default shell set to zsh"
else
    print_status "zsh is already the default shell"
fi

# Apply macOS system defaults
if [[ -f "$DOTFILES_DIR/macos/defaults.sh" ]]; then
    read -p "Apply macOS system defaults (keyboard, Dock, Finder, etc.)? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash "$DOTFILES_DIR/macos/defaults.sh"
        print_status "macOS defaults applied"
    else
        print_warning "Skipped macOS defaults (run macos/defaults.sh manually anytime)"
    fi
fi

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo -e "${BLUE}Please restart your terminal or run 'source ~/.zshrc' to apply changes.${NC}"
echo -e "${BLUE}You may also want to restart your terminal session to ensure all changes take effect.${NC}"

