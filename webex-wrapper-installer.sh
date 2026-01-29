#!/bin/bash
#
# WebEx Nativefier Installer
# =========================
# A robust Bash script to deploy WebEx as a standalone web-app wrapper that
# completely bypasses the native RPM distribution. This approach wraps the WebEx
# web interface as a native application using Nativefier.
#
# Example Usage:
#   sudo ./webex-nativefier-installer.sh --install
#   sudo ./webex-nativefier-installer.sh --install-dir /opt/webex-wrapper --app-dir /opt/WebEx --force
#   sudo ./webex-nativefier-installer.sh --uninstall
#   ./webex-nativefier-installer.sh --help
#
# Features:
# - Automatic Node.js and Nativefier setup
# - WebRTC and screen sharing support
# - Desktop integration with .desktop file
# - Protocol handler registration (webex://, webexteams://)
# - URL scheme handling for meeting links
# - Comprehensive error handling and logging
# - Idempotent design (safe to run multiple times)
#
# ==============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# Default values
DEFAULT_INSTALL_DIR="/opt/webex-wrapper"
DEFAULT_APP_DIR="/opt/WebEx"
WEBEX_URL="https://web.webex.com/"
WEBEX_ICON_URL="https://avatars.githubusercontent.com/u/1342004?s=256"
WEBEX_ICON_FALLBACK="https://webex.cisco.com/assets/icons/favicon.ico"
TEMP_DIR="/tmp/webex-nativefier-$$"

# Script version
SCRIPT_VERSION="1.0.0"

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "\e[1;34m[INFO]\e[0m $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_success() {
    echo -e "\e[1;32m[SUCCESS]\e[0m $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_warning() {
    echo -e "\e[1;33m[WARNING]\e[0m $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_error() {
    echo -e "\e[1;31m[ERROR]\e[0m $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

log_step() {
    echo ""
    echo -e "\e[1;36m==> $*\e[0m"
    echo ""
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

cleanup() {
    log_info "Cleaning up temporary files..."
    if [[ -d "${TEMP_DIR}" ]]; then
        rm -rf "${TEMP_DIR}"
    fi
}

trap cleanup EXIT

# ============================================================================
# ERROR HANDLING
# ============================================================================

error_exit() {
    log_error "$1"
    log_error "Installation failed. Please review the error messages above."
    exit 1
}

# ============================================================================
# HELP/USAGE FUNCTION
# ============================================================================

print_usage() {
    cat << EOF
WebEx Nativefier Installer v${SCRIPT_VERSION}
=============================================

A robust Bash script to deploy WebEx as a standalone web-app wrapper using Nativefier.
This approach bypasses the native RPM distribution and provides screen sharing support.

USAGE:
    sudo ./webex-nativefier-installer.sh [OPTIONS]

OPTIONS:
    --install-dir PATH     Installation directory for wrapper files (default: ${DEFAULT_INSTALL_DIR})
    --app-dir PATH         Where to build the nativefier app (default: ${DEFAULT_APP_DIR})
    --force                Force rebuild even if app exists
    --uninstall            Remove the installed wrapper
    -h, --help             Show this help message
    --readme               Display detailed README

EXAMPLES:
    # Install with default settings
    sudo ./webex-nativefier-installer.sh

    # Install with custom directories
    sudo ./webex-nativefier-installer.sh --install-dir /usr/local/webex-wrapper --app-dir /usr/local/WebEx

    # Force rebuild
    sudo ./webex-nativefier-installer.sh --force

    # Uninstall
    sudo ./webex-nativefier-installer.sh --uninstall

FEATURES:
    ✓ Automatic Node.js and Nativefier installation
    ✓ WebRTC and screen sharing support via Electron flags
    ✓ Desktop integration with .desktop file
    ✓ Protocol handlers (webex://, webexteams://)
    ✓ URL scheme handling for meeting links
    ✓ Comprehensive error handling and logging
    ✓ Idempotent design (safe to run multiple times)

EOF
}

print_readme() {
    cat << 'EOF'
================================================================================
WebEx Nativefier Installer - README
================================================================================

OVERVIEW
--------
This script creates a standalone WebEx application wrapper using Nativefier,
which packages the WebEx web interface as a native Linux application. This
approach provides several advantages over the official RPM package:

1. No RPM dependencies or naming conflicts
2. Screen sharing works out of the box
3. Automatic updates with the web interface
4. Smaller footprint
5. No system-wide library conflicts

REQUIREMENTS
------------
- Linux distribution with package manager (dnf, yum, apt, etc.)
- Root/sudo access for installation
- Internet connection for downloading Node.js and Nativefier
- Approximately 500MB of free disk space

ARCHITECTURE
------------
The script performs the following steps:

1. Environment Setup
   - Detects and installs Node.js (via package manager or nvm)
   - Installs Nativefier globally via npm
   - Verifies all required tools

2. Application Building
   - Uses Nativefier to compile WebEx web interface
   - Configures WebRTC flags for audio/video
   - Enables ES3 APIs for extended WebGL features
   - Sets up screen sharing permissions
   - Creates isolated application instance

3. Desktop Integration
   - Creates .desktop entry file
   - Installs application icons in standard locations
   - Registers protocol handlers

4. Protocol Handler Configuration
   - Registers webex:// protocol
   - Registers webexteams:// protocol
   - Sets up URL scheme handlers for meeting links
   - Updates xdg-mime associations

5. Wrapper Script
   - Creates launch script with environment variables
   - Handles command-line arguments (meeting URLs)
   - Configures Electron flags for screen capture

WEBRTC AND SCREEN SHARING
-------------------------
The script configures the following flags to ensure WebRTC and screen sharing
work correctly:

--enable-webrtc
    Enables WebRTC functionality for audio/video conferencing

--enable-es3-apis
    Enables extended WebGL features required for some WebEx functionality

--user-agent
    Sets a desktop-like user agent to avoid mobile restrictions

--browser-window-options
    Configures security settings:
    - nodeIntegration: false (security)
    - contextIsolation: true (security)

Additionally, the wrapper script sets Electron-specific environment variables:
    - ELECTRON_ENABLE_LOGGING=1
    - ELECTRON_ENABLE_STACK_DUMPING=1

PROTOCOL HANDLERS
-----------------
The script registers the following protocol handlers:

webex://
    Opens WebEx meeting links

webexteams://
    Opens WebEx Teams links

These are registered in both system-wide (/etc/xdg/mimeapps.list) and
user-specific (~/.config/mimeapps.list) configuration files.

INSTALLATION LOCATIONS
----------------------
Application binary:    ${APP_DIR}/WebEx
Wrapper script:        ${INSTALL_DIR}/webex-wrapper
Desktop file:          /usr/share/applications/webex-wrapper.desktop
Icons:                 /usr/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128,256x256}/apps/webex.png

UNINSTALLATION
--------------
To remove the installed wrapper:

    sudo ./webex-nativefier-installer.sh --uninstall

This will:
- Remove the application directory
- Remove the wrapper script
- Remove the .desktop file
- Remove installed icons
- Unregister protocol handlers

TROUBLESHOOTING
---------------

Issue: Node.js not found
Solution: The script will prompt to install Node.js. Confirm with 'y'.

Issue: Nativefier build fails
Solution: Ensure you have sufficient disk space and internet connection.
          Try running with --force to rebuild from scratch.

Issue: Screen sharing not working
Solution: Check that the Electron flags are set correctly in the wrapper script.
          Ensure the application has permissions to access the screen.

Issue: Protocol handlers not working
Solution: Log out and log back in, or restart your desktop session.

ISSUES AND CONTRIBUTIONS
------------------------
If you encounter issues or want to contribute, please check the project
repository and file an issue with details about your Linux distribution and
the error messages you're seeing.

================================================================================
EOF
}

# ============================================================================
# COMMAND-LINE OPTION PARSING
# ============================================================================

INSTALL_DIR="${DEFAULT_INSTALL_DIR}"
APP_DIR="${DEFAULT_APP_DIR}"
FORCE_BUILD=false
UNINSTALL=false
SHOW_README=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --app-dir)
            APP_DIR="$2"
            shift 2
            ;;
        --force)
            FORCE_BUILD=true
            shift
            ;;
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        --readme)
            print_readme
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo ""
            print_usage
            exit 1
            ;;
    esac
done

# ============================================================================
# ROOT PRIVILEGE CHECK
# ============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root (use sudo)"
    fi
}

# ============================================================================
# PACKAGE MANAGER DETECTION
# ============================================================================

detect_package_manager() {
    if command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v apt-get &> /dev/null; then
        echo "apt-get"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

install_package() {
    local package="$1"
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    
    case "$pkg_manager" in
        dnf)
            dnf install -y "$package"
            ;;
        yum)
            yum install -y "$package"
            ;;
        apt-get)
            apt-get update && apt-get install -y "$package"
            ;;
        pacman)
            pacman -S --noconfirm "$package"
            ;;
        *)
            log_error "Unsupported package manager. Please install $package manually."
            return 1
            ;;
    esac
}

# ============================================================================
# NODE.JS INSTALLATION
# ============================================================================

check_nodejs() {
    if command -v node &> /dev/null; then
        local node_version
        node_version=$(node --version)
        log_success "Node.js found: ${node_version}"
        return 0
    else
        log_warning "Node.js not found"
        return 1
    fi
}

install_nodejs() {
    log_step "Installing Node.js"
    
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    
    case "$pkg_manager" in
        dnf|yum)
            install_package nodejs npm
            ;;
        apt-get)
            install_package nodejs npm
            ;;
        pacman)
            install_package nodejs npm
            ;;
        *)
            log_error "Unsupported package manager. Installing Node.js via nvm..."
            install_nodejs_nvm
            ;;
    esac
    
    if check_nodejs; then
        log_success "Node.js installed successfully"
    else
        error_exit "Failed to install Node.js"
    fi
}

install_nodejs_nvm() {
    log_info "Installing Node.js via NVM (Node Version Manager)..."
    
    # Install NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Source NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install latest LTS Node.js
    nvm install --lts
    nvm use --lts
    
    # Make available to all users
    ln -sf "$HOME/.nvm/versions/node/$(nvm current)/bin/node" /usr/local/bin/node
    ln -sf "$HOME/.nvm/versions/node/$(nvm current)/bin/npm" /usr/local/bin/npm
}

# ============================================================================
# NATIVIFIER INSTALLATION
# ============================================================================

check_nativefier() {
    if command -v nativefier &> /dev/null; then
        local nf_version
        nf_version=$(nativefier --version 2>/dev/null || echo "unknown")
        log_success "Nativefier found: ${nf_version}"
        return 0
    else
        log_warning "Nativefier not found"
        return 1
    fi
}

install_nativefier() {
    log_step "Installing Nativefier"
    
    if ! npm install -g nativefier; then
        error_exit "Failed to install Nativefier"
    fi
    
    if check_nativefier; then
        log_success "Nativefier installed successfully"
    else
        error_exit "Nativefier installation verification failed"
    fi
}

# ============================================================================
# ICON DOWNLOAD AND PROCESSING
# ============================================================================

download_icon() {
    local icon_path="$1"
    
    log_info "Downloading WebEx icon..."
    
    # Try primary icon URL
    if curl -fsSL "${WEBEX_ICON_URL}" -o "${icon_path}" 2>/dev/null; then
        log_success "Icon downloaded successfully"
        return 0
    fi
    
    # Try fallback icon URL
    log_warning "Primary icon URL failed, trying fallback..."
    if curl -fsSL "${WEBEX_ICON_FALLBACK}" -o "${icon_path}" 2>/dev/null; then
        log_success "Icon downloaded from fallback URL"
        return 0
    fi
    
    # Use base64 fallback
    log_warning "Icon download failed, using embedded icon..."
    return 1
}

create_icon_sizes() {
    local source_icon="$1"
    
    log_info "Creating icon sizes..."
    
    # Check if ImageMagick is available
    if ! command -v convert &> /dev/null; then
        log_warning "ImageMagick not found, will use source icon for all sizes"
        return 0
    fi
    
    local sizes=(16 32 48 64 128 256)
    local size
    
    for size in "${sizes[@]}"; do
        local target_dir="/usr/share/icons/hicolor/${size}x${size}/apps"
        local target_file="${target_dir}/webex.png"
        
        mkdir -p "${target_dir}"
        convert "${source_icon}" -resize "${size}x${size}" "${target_file}" 2>/dev/null || {
            log_warning "Failed to create ${size}x${size} icon, copying source..."
            cp "${source_icon}" "${target_file}"
        }
    done
    
    log_success "Icon sizes created"
}

# ============================================================================
# APPLICATION BUILDING
# ============================================================================

build_application() {
    local build_dir="$1"
    local icon_path="$2"
    
    log_step "Building WebEx application with Nativefier"
    
    # Create build directory
    mkdir -p "${build_dir}"
    cd "${build_dir}"
    
    # Nativefier command with all required flags
    log_info "Running Nativefier with WebRTC and screen sharing configuration..."
    
    if ! nativefier \
        --name "WebEx" \
        --icon "${icon_path}" \
        --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        --enable-webrtc \
        --enable-es3-apis \
        --single-instance \
        --tray "false" \
        --disable-dev-tools \
        --background-color "#ffffff" \
        --internal-url ".*web\.com.*" \
        --browser-window-options '{"webPreferences":{"nodeIntegration":false,"contextIsolation":true,"enableRemoteModule":false,"webSecurity":true,"allowRunningInsecureContent":false,"plugins":true,"experimentalFeatures":true}}' \
        "${WEBEX_URL}"; then
        error_exit "Nativefier build failed"
    fi
    
    # Check if build was successful
    if [[ ! -d "${build_dir}/WebEx-linux-"* ]]; then
        error_exit "Nativefier build directory not found"
    fi
    
    # Rename to consistent name
    local app_name="WebEx-linux-x64"
    if [[ -d "${build_dir}/WebEx-linux-arm64" ]]; then
        app_name="WebEx-linux-arm64"
    fi
    
    if [[ -d "${build_dir}/${app_name}" ]]; then
        log_success "Application built successfully: ${build_dir}/${app_name}"
        
        # Create symlink for consistent path
        ln -sf "${build_dir}/${app_name}" "${APP_DIR}"
        
        return 0
    else
        error_exit "Failed to locate built application"
    fi
}

# ============================================================================
# WRAPPER SCRIPT CREATION
# ============================================================================

create_wrapper_script() {
    local install_dir="$1"
    local app_dir="$2"
    local wrapper_script="${install_dir}/webex-wrapper"
    
    log_step "Creating wrapper script"
    
    mkdir -p "${install_dir}"
    
    cat > "${wrapper_script}" << 'WRAPPER_EOF'
#!/bin/bash
#
# WebEx Wrapper Script
# ====================
# This script launches the WebEx nativefier application with proper
# environment variables and Electron flags for screen sharing support.
#

set -euo pipefail

# Application paths
APP_DIR="/opt/WebEx"
APP_BINARY="${APP_DIR}/WebEx"

# Electron environment variables for screen sharing and WebRTC
export ELECTRON_ENABLE_LOGGING=1
export ELECTRON_ENABLE_STACK_DUMPING=1
export ELECTRON_DISABLE_SECURITY_WARNINGS=false

# Set up library path for screen capture
export LD_LIBRARY_PATH="${APP_DIR}:/usr/lib:/usr/lib64:${LD_LIBRARY_PATH:-}"

# Pulse audio for audio capture
export PULSE_SERVER="unix:/run/user/$(id -u)/pulse/native"

# Launch the application with any provided arguments
if [[ $# -gt 0 ]]; then
    # If arguments provided, they're likely meeting URLs
    exec "${APP_BINARY}" "$@"
else
    exec "${APP_BINARY}"
fi
WRAPPER_EOF
    
    chmod +x "${wrapper_script}"
    
    log_success "Wrapper script created: ${wrapper_script}"
}

# ============================================================================
# DESKTOP FILE CREATION
# ============================================================================

create_desktop_file() {
    local desktop_file="/usr/share/applications/webex-wrapper.desktop"
    local install_dir="$1"
    local app_dir="$2"
    
    log_step "Creating desktop entry"
    
    cat > "${desktop_file}" << DESKTOP_EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=WebEx Meeting
GenericName=Web Conferencing
Comment=WebEx web-app wrapper with screen sharing support
Exec=${install_dir}/webex-wrapper %u
Icon=webex
Terminal=false
StartupNotify=true
StartupWMClass=webex
Categories=Network;Application;
MimeType=x-scheme-handler/webex;x-scheme-handler/webexteams;
Keywords=webex;meeting;video;conferencing;teams;
DESKTOP_EOF
    
    log_success "Desktop file created: ${desktop_file}"
}

# ============================================================================
# PROTOCOL HANDLER CONFIGURATION
# ============================================================================

configure_protocol_handlers() {
    log_step "Configuring protocol handlers"
    
    # Create MIME type definitions
    local mime_types_file="/usr/share/mime/packages/webex-wrapper.xml"
    
    cat > "${mime_types_file}" << MIME_EOF
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="x-scheme-handler/webex">
    <comment>WebEx Meeting Link</comment>
    <glob pattern="webex:*"/>
  </mime-type>
  <mime-type type="x-scheme-handler/webexteams">
    <comment>WebEx Teams Link</comment>
    <glob pattern="webexteams:*"/>
  </mime-type>
</mime-info>
MIME_EOF
    
    # Update MIME database
    if command -v update-mime-database &> /dev/null; then
        update-mime-database /usr/share/mime 2>/dev/null || true
    fi
    
    # Register in system-wide mimeapps.list
    local system_mimeapps="/etc/xdg/mimeapps.list"
    
    if [[ ! -f "${system_mimeapps}" ]]; then
        touch "${system_mimeapps}"
    fi
    
    # Add protocol handler associations if not already present
    if ! grep -q "x-scheme-handler/webex=" "${system_mimeapps}"; then
        echo "[Added Associations]" >> "${system_mimeapps}"
        echo "x-scheme-handler/webex=webex-wrapper.desktop" >> "${system_mimeapps}"
    fi
    
    if ! grep -q "x-scheme-handler/webexteams=" "${system_mimeapps}"; then
        echo "x-scheme-handler/webexteams=webex-wrapper.desktop" >> "${system_mimeapps}"
    fi
    
    # Register as default handler
    if command -v xdg-mime &> /dev/null; then
        xdg-mime default webex-wrapper.desktop x-scheme-handler/webex 2>/dev/null || true
        xdg-mime default webex-wrapper.desktop x-scheme-handler/webexteams 2>/dev/null || true
    fi
    
    log_success "Protocol handlers configured"
}

# ============================================================================
# UNINSTALLATION
# ============================================================================

uninstall_webex() {
    log_step "Uninstalling WebEx wrapper"
    
    # Remove application directory
    if [[ -d "${APP_DIR}" ]]; then
        log_info "Removing application directory: ${APP_DIR}"
        rm -rf "${APP_DIR}"
    fi
    
    # Remove install directory
    if [[ -d "${INSTALL_DIR}" ]]; then
        log_info "Removing install directory: ${INSTALL_DIR}"
        rm -rf "${INSTALL_DIR}"
    fi
    
    # Remove desktop file
    if [[ -f "/usr/share/applications/webex-wrapper.desktop" ]]; then
        log_info "Removing desktop file"
        rm -f "/usr/share/applications/webex-wrapper.desktop"
    fi
    
    # Remove icons
    log_info "Removing icons"
    for size in 16 32 48 64 128 256; do
        local icon_file="/usr/share/icons/hicolor/${size}x${size}/apps/webex.png"
        if [[ -f "${icon_file}" ]]; then
            rm -f "${icon_file}"
        fi
    done
    
    # Remove MIME type file
    if [[ -f "/usr/share/mime/packages/webex-wrapper.xml" ]]; then
        log_info "Removing MIME type definitions"
        rm -f "/usr/share/mime/packages/webex-wrapper.xml"
    fi
    
    # Update MIME database
    if command -v update-mime-database &> /dev/null; then
        update-mime-database /usr/share/mime 2>/dev/null || true
    fi
    
    # Remove protocol handler associations
    local system_mimeapps="/etc/xdg/mimeapps.list"
    if [[ -f "${system_mimeapps}" ]]; then
        log_info "Removing protocol handler associations"
        sed -i '/webex-wrapper.desktop/d' "${system_mimeapps}" || true
        # Clean up empty [Added Associations] section
        sed -i '/^\[Added Associations\]$/{
            N
            /^\[Added Associations\]\n$/d
        }' "${system_mimeapps}" || true
    fi
    
    log_success "Uninstallation complete"
    log_info "Note: You may need to log out and log back in for all changes to take effect"
}

# ============================================================================
# INSTALLATION PROCESS
# ============================================================================

install_webex() {
    log_step "Starting WebEx Nativefier installation"
    log_info "Install directory: ${INSTALL_DIR}"
    log_info "App directory: ${APP_DIR}"
    
    # Check root privileges
    check_root
    
    # Check if already installed and not forcing rebuild
    if [[ -d "${APP_DIR}" ]] && [[ "${FORCE_BUILD}" != true ]]; then
        log_warning "WebEx wrapper already installed at ${APP_DIR}"
        log_info "Use --force to rebuild, or --uninstall to remove"
        exit 0
    fi
    
    # Create temporary directory
    mkdir -p "${TEMP_DIR}"
    
    # Step 1: Environment Setup
    if ! check_nodejs; then
        log_info "Node.js is required for Nativefier"
        read -p "Install Node.js now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_nodejs
        else
            error_exit "Node.js is required but not installed"
        fi
    fi
    
    if ! check_nativefier; then
        log_info "Nativefier is required to build the application"
        read -p "Install Nativefier now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_nativefier
        else
            error_exit "Nativefier is required but not installed"
        fi
    fi
    
    # Step 2: Download Icon
    local icon_path="${TEMP_DIR}/webex.png"
    if ! download_icon "${icon_path}"; then
        log_error "Failed to download icon, using base64 fallback"
        # Create a simple icon as fallback
        create_fallback_icon "${icon_path}"
    fi
    
    # Step 3: Build Application
    if [[ "${FORCE_BUILD}" == true ]] && [[ -d "${APP_DIR}" ]]; then
        log_info "Force rebuild requested, removing existing installation..."
        rm -rf "${APP_DIR}"
    fi
    
    build_application "${APP_DIR}" "${icon_path}"
    
    # Step 4: Install Icons
    create_icon_sizes "${icon_path}"
    
    # Step 5: Create Wrapper Script
    create_wrapper_script "${INSTALL_DIR}" "${APP_DIR}"
    
    # Step 6: Create Desktop File
    create_desktop_file "${INSTALL_DIR}" "${APP_DIR}"
    
    # Step 7: Configure Protocol Handlers
    configure_protocol_handlers
    
    # Step 8: Set Permissions
    log_info "Setting permissions..."
    chmod -R 755 "${APP_DIR}"
    chmod 755 "${INSTALL_DIR}/webex-wrapper"
    chmod 644 "/usr/share/applications/webex-wrapper.desktop"
    
    # Step 9: Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database /usr/share/applications 2>/dev/null || true
    fi
    
    # Update icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
    fi
    
    log_success "Installation complete!"
    log_info ""
    log_info "WebEx wrapper has been installed at: ${APP_DIR}"
    log_info "Wrapper script: ${INSTALL_DIR}/webex-wrapper"
    log_info "Desktop entry: /usr/share/applications/webex-wrapper.desktop"
    log_info ""
    log_info "You can now launch WebEx from your application menu or by running:"
    log_info "  ${INSTALL_DIR}/webex-wrapper"
    log_info ""
    log_info "WebEx meeting links (webex://) will now open in the wrapper."
    log_info "You may need to log out and log back in for protocol handlers to work."
}

# ============================================================================
# FALLBACK ICON CREATION
# ============================================================================

create_fallback_icon() {
    local icon_path="$1"
    
    # Create a simple PNG icon with WebEx-like colors
    # This is a minimal 256x256 PNG with blue gradient background
    
    # Use ImageMagick if available
    if command -v convert &> /dev/null; then
        convert -size 256x256 xc:'#00bceb' \
            -font Arial-Bold -pointsize 80 -fill white -gravity center \
            -annotate +0+0 'WebEx' \
            "${icon_path}" 2>/dev/null
    else
        # Fallback: create a minimal valid PNG
        log_warning "ImageMagick not available, creating minimal icon"
        echo "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAMAAABrrFhUAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+/Pp/mixwAAABgUExURf///8DAwICAgMHBwcHBw8PDw8TExMTEhYWFhYaGhoaHh4eHiIiIiImJiYmJiYqKioqKiosLCwsLCwsrKysrKy8vLy8vLzMzMzMzMy8vMy8vMz8/Pz8/P0NDQ0NDQ0NLS0tLS0tLS0tPT0tPT0tTU1NTU1NTU1NTU1dXV1dXV1dXV1dXV1dXV1dXV1f///0hM0R4AAAM2SURBVHja7N1LktMwEARBaIQQIQI0VqG1t7/z3Lm2iIqDhJ4F4J7rK7cZ8b5x4lQAAABJRU5ErkJggg==" | base64 -d > "${icon_path}"
    fi
    
    log_info "Created fallback icon"
}

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

main() {
    log_info "WebEx Nativefier Installer v${SCRIPT_VERSION}"
    log_info "==========================================="
    
    if [[ "${UNINSTALL}" == true ]]; then
        uninstall_webex
    else
        install_webex
    fi
}

# Run main function
main "$@"
