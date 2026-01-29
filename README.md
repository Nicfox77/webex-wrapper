# webex-wrapper

A web-app wrapper for Cisco Webex on Linux using Nativefier. This approach creates a standalone desktop application by wrapping the Webex web interface, providing screen sharing support and avoiding RPM dependency issues.

## Overview

This project provides a clean alternative to the official Cisco Webex RPM package by using Nativefier to create a native Linux application wrapper. This approach offers several advantages:

- **No RPM dependencies** - Avoids library conflicts and dependency naming issues
- **Screen sharing support** - Works out of the box with proper WebRTC configuration
- **Automatic updates** - Always uses the latest web interface
- **Smaller footprint** - No system-wide library installations
- **Cross-distribution compatibility** - Works on any Linux distribution with Node.js

## Installation

### Prerequisites

- Linux distribution with package manager (dnf, yum, apt, pacman, etc.)
- Root/sudo access for installation
- Internet connection for downloading Node.js and Nativefier
- Approximately 500MB of free disk space

### Quick Install

Run the installer with default settings:

```bash
sudo ./webex-wrapper-installer.sh
```

### Custom Installation

Install with custom directories:

```bash
sudo ./webex-wrapper-installer.sh --install-dir /usr/local/webex-wrapper --app-dir /usr/local/WebEx
```

Force rebuild if already installed:

```bash
sudo ./webex-wrapper-installer.sh --force
```

### Uninstallation

Remove the installed wrapper:

```bash
sudo ./webex-wrapper-installer.sh --uninstall
```

## Usage

### Launching the Application

After installation, you can launch Webex in several ways:

1. **From the application menu** - Look for "WebEx Meeting"
2. **From the command line**:
   ```bash
   webex-wrapper
   ```
3. **With a meeting URL**:
   ```bash
   webex-wrapper "https://webex.com/meeting/your-meeting-id"
   ```

### Protocol Handlers

The wrapper registers protocol handlers for:
- `webex://` - Opens Webex meeting links
- `webexteams://` - Opens Webex Teams links

Clicking on these links in your browser or other applications will automatically open the Webex wrapper.

## Features

- **WebRTC Support** - Full audio/video conferencing capabilities
- **Screen Sharing** - Configured with proper Electron flags
- **Desktop Integration** - Includes .desktop file and application icons
- **Protocol Handlers** - Handles webex:// and webexteams:// URLs
- **Security** - Configured with secure Electron settings (nodeIntegration disabled, contextIsolation enabled)

## Installation Locations

- **Application binary**: `/opt/WebEx/WebEx`
- **Wrapper script**: `/opt/webex-wrapper/webex-wrapper`
- **Desktop file**: `/usr/share/applications/webex-wrapper.desktop`
- **Icons**: `/usr/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128,256x256}/apps/webex.png`

## Troubleshooting

### Node.js not found
The installer will automatically prompt to install Node.js. Confirm with 'y' when prompted.

### Nativefier build fails
Ensure you have sufficient disk space and internet connection. Try running with `--force` to rebuild from scratch.

### Screen sharing not working
Check that the Electron flags are set correctly in the wrapper script. Ensure the application has permissions to access the screen.

### Protocol handlers not working
Log out and log back in, or restart your desktop session for the changes to take effect.

## Command-Line Options

```
--install-dir PATH     Installation directory for wrapper files (default: /opt/webex-wrapper)
--app-dir PATH         Where to build the nativefier app (default: /opt/WebEx)
--force                Force rebuild even if app exists
--uninstall            Remove the installed wrapper
-h, --help             Show help message
--readme               Display detailed README
```

## Technical Details

### Architecture

The installer performs the following steps:

1. **Environment Setup**
   - Detects and installs Node.js (via package manager or nvm)
   - Installs Nativefier globally via npm
   - Verifies all required tools

2. **Application Building**
   - Uses Nativefier to compile Webex web interface
   - Configures WebRTC flags for audio/video
   - Enables ES3 APIs for extended WebGL features
   - Sets up screen sharing permissions
   - Creates isolated application instance

3. **Desktop Integration**
   - Creates .desktop entry file
   - Installs application icons in standard locations
   - Registers protocol handlers

4. **Wrapper Script**
   - Creates launch script with environment variables
   - Handles command-line arguments (meeting URLs)
   - Configures Electron flags for screen capture

### WebRTC Configuration

The wrapper configures the following flags:

- `--enable-webrtc` - Enables WebRTC functionality for audio/video conferencing
- `--enable-es3-apis` - Enables extended WebGL features
- `--user-agent` - Sets a desktop-like user agent
- `--browser-window-options` - Configures security settings

### Environment Variables

The wrapper script sets:
- `ELECTRON_ENABLE_LOGGING=1`
- `ELECTRON_ENABLE_STACK_DUMPING=1`
- `LD_LIBRARY_PATH` - For screen capture libraries
- `PULSE_SERVER` - For audio capture

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Webex

https://webex.com/
