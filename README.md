# Run Linux on Samsung

Transform your **Samsung Galaxy** smartphone or tablet into a fully functional, GPU-accelerated **Linux Desktop** using Termux. This automated script installs your choice of Desktop Environment (XFCE4, LXQt, MATE, or KDE Plasma), configures Turnip/Zink drivers for Snapdragon hardware acceleration, and sets up remote access so you can work from your Mac or PC.

**Created by**: [Tech Jarves](https://youtube.com/techjarves) – *Subscribe on YouTube for full tutorials!*

## 🚀 Key Features

- **Multiple Desktop Environments**: Choose between XFCE4, LXQt, MATE, and KDE Plasma.
- **Hardware GPU Acceleration**: Automatically configures Turnip & Zink Vulkan drivers for Snapdragon / Adreno devices (Exynos falls back to software rendering).
- **Remote Access from Mac/PC**: SSH server + VNC (x11vnc) — connect to your phone's terminal or full graphical desktop from any computer on your network.
- **Zsh Shell**: Zsh with Oh My Zsh pre-configured as the default shell.
- **Development Ready**: Python 3, Flask, VS Code (code-oss), Git, Firefox, and Chromium pre-installed.
- **Windows App Compatibility**: Run `x86_64` Windows applications using Wine and Box64 via Hangover.

## 📱 Prerequisites

1. **Samsung Galaxy** device running Android 10 or higher.
2. **Termux**: Download the official version from [F-Droid](https://f-droid.org/en/packages/com.termux/). *(Do not use the Google Play Store version — it is obsolete).*
3. **Termux-X11**: Required to render the Linux display. Download the latest APK from the [Termux-X11 GitHub Releases](https://github.com/termux/termux-x11/releases).
4. **Storage**: Approximately 3-4 GB of free internal space.

## ⚙️ Installation

### Method 1: One-Click Install (Recommended)

```bash
apt update && apt upgrade -y && apt install curl -y && curl -fsSL https://raw.githubusercontent.com/yyyyeeeeesss/Linux-on-Samsung/main/setup-hacklab.sh | bash
```

### Method 2: Manual Clone

```bash
apt update && apt upgrade -y
apt install git curl -y
git clone https://github.com/yyyyeeeeesss/Linux-on-Samsung.git
cd Linux-on-Samsung
chmod +x setup-hacklab.sh
./setup-hacklab.sh
```

## 🖥️ Usage

After installation, the launcher scripts are in your home directory.

### Start the Desktop

1. Keep the **Termux-X11** app open in the background.
2. Run:
   ```bash
   ./start-hacklab.sh
   ```
   If you installed multiple DEs, you'll be prompted to choose which one to boot.

### Remote Access from Mac

**SSH (terminal)**:
```bash
ssh <user>@<phone-ip> -p 8022
```

**VNC (graphical desktop)**:
1. Start the desktop on the phone (`./start-hacklab.sh`).
2. Start VNC via the quick menu (`./hacktools.sh` → option 1), or manually:
   ```bash
   x11vnc -display :0 -forever -nopw -listen 0.0.0.0 -rfbport 5900
   ```
3. On your Mac, open **Finder → Go → Connect to Server** (⌘K) and enter:
   ```
   vnc://<phone-ip>:5900
   ```
   Or use any VNC client (e.g., RealVNC Viewer).

### Quick Tools Menu

```bash
./hacktools.sh
```

### Stop the Desktop

```bash
./stop-hacklab.sh
```

### Test Python Flask Demo

```bash
cd ~/demo_python && python app.py
```
Open `http://localhost:5000` in Firefox or Chromium on the device.

## ⚡ Hardware Compatibility

| Chipset | GPU | Driver | Recommendation |
|---------|-----|--------|----------------|
| Snapdragon (Adreno) | Adreno | Turnip (HW accel) | Any DE, including KDE Plasma |
| Exynos (Mali) | Mali | Software (llvmpipe) | XFCE4 or LXQt for best performance |

## 📦 What Gets Installed

| Category | Packages |
|----------|----------|
| Desktop | XFCE4 / LXQt / MATE / KDE Plasma |
| Browsers | Firefox, Chromium |
| Development | Python 3, Flask, VS Code, Git |
| Shell | Zsh + Oh My Zsh |
| Remote Access | OpenSSH (port 8022), x11vnc (VNC) |
| Media | VLC, PulseAudio |
| Windows Apps | Wine / Hangover (Box64) |
| GPU | Mesa Zink, Turnip / swrast |

---
⭐ **Like this project?** Drop a star on GitHub and subscribe to [Tech Jarves](https://youtube.com/techjarves)!
