#!/bin/bash

set -e  # Exit on any error

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
if [[ -f "$DOTFILES_DIR/homebrew/Brewfile" ]]; then
    echo -e "${YELLOW}Installing Homebrew packages from Brewfile...${NC}"
    brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile"
    print_status "Homebrew packages installed successfully"
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

# Install mise-en-place if not already installed
if ! command -v mise &>/dev/null; then
    echo -e "${YELLOW}Installing mise...${NC}"
    curl https://mise.run | sh
    print_status "mise installed successfully"
else
    print_status "mise already installed"
fi

# Set zsh as the default shell if it isn't already
if [[ "$SHELL" != "/bin/zsh" && "$SHELL" != "/usr/bin/zsh" ]]; then
    echo -e "${YELLOW}Setting zsh as default shell...${NC}"
    chsh -s "$(which zsh)"
    print_status "Default shell set to zsh"
else
    print_status "zsh is already the default shell"
fi

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo -e "${BLUE}Please restart your terminal or run 'source ~/.zshrc' to apply changes.${NC}"
echo -e "${BLUE}You may also want to restart your terminal session to ensure all changes take effect.${NC}"

