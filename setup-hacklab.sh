#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 SAMSUNG MOBILE HACKLAB - Ultimate Installer
#  
#  Features:
#  - Choice of Desktop Environment (XFCE, LXQt, MATE, KDE)
#  - Samsung Adreno GPU acceleration (Turnip/Zink)
#  - Remote access: SSH + VNC (connect from Mac/PC)
#  - Zsh shell with Oh My Zsh
#  - Python & Web Dev environment
#  - Windows App Support (Wine/Hangover)
#  - One-click desktop launch
#  
#  Optimized for: Samsung Galaxy devices (Snapdragon)
#  Author: Tech Jarves
#  YouTube: https://youtube.com/@TechJarves
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=14
CURRENT_STEP=0
DE_CHOICE="1"
DE_NAME="XFCE4"
# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'
# ============== PROGRESS FUNCTIONS ==============
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    
    FILLED=$((PERCENT / 5))
    EMPTY=$((20 - FILLED))
    
    BAR="${GREEN}"
    for ((i=0; i<FILLED; i++)); do BAR+="█"; done
    BAR+="${GRAY}"
    for ((i=0; i<EMPTY; i++)); do BAR+="░"; done
    BAR+="${NC}"
    
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📊 OVERALL PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}
spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r  ${YELLOW}⏳${NC} ${message} ${CYAN}${spin:$i:1}${NC}  "
        sleep 0.1
    done
    
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} ${message}                    \n"
    else
        printf "\r  ${RED}✗${NC} ${message} ${RED}(failed)${NC}     \n"
    fi
    
    return $exit_code
}
install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    (yes | pkg install $pkg -y > /dev/null 2>&1) &
    spinner $! "Installing ${name}..."
}
# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════════════╗
    ║                                              ║
    ║     🚀  SAMSUNG MOBILE HACKLAB v3.0  🚀      ║
    ║                                              ║
    ║     Optimized for Samsung Galaxy Devices     ║
    ║                                              ║
    ╚══════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "${WHITE}            Tech Jarves - YouTube${NC}"
    echo -e "${GRAY}        https://youtube.com/@TechJarves${NC}"
    echo ""
}
# ============== SAMSUNG DEVICE DETECTION ==============
detect_samsung() {
    echo -e "${PURPLE}[*] Detecting Samsung device...${NC}"
    echo ""
    
    DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
    DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
    ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    CPU_ABI=$(getprop ro.product.cpu.abi 2>/dev/null || echo "arm64-v8a")
    ONE_UI_VERSION=$(getprop ro.build.version.oneui 2>/dev/null || echo "Unknown")
    CHIPSET=$(getprop ro.hardware.chipname 2>/dev/null || echo "")
    GPU_VENDOR=$(getprop ro.hardware.egl 2>/dev/null || echo "")
    
    echo -e "  ${GREEN}📱${NC} Device: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    echo -e "  ${GREEN}🤖${NC} Android: ${WHITE}${ANDROID_VERSION}${NC}"
    echo -e "  ${GREEN}🖥️${NC}  One UI: ${WHITE}${ONE_UI_VERSION}${NC}"
    echo -e "  ${GREEN}⚙️${NC}  CPU: ${WHITE}${CPU_ABI}${NC}"
    
    # Samsung Snapdragon = Adreno GPU with Turnip driver support
    # Samsung Exynos = Mali GPU (no Turnip, falls back to Zink software)
    if [[ "$GPU_VENDOR" == *"adreno"* ]] || [[ "$CHIPSET" == *"sm"* ]] || [[ "$CHIPSET" == *"kalama"* ]] || [[ "$CHIPSET" == *"taro"* ]] || [[ "$CHIPSET" == *"lahaina"* ]]; then
        GPU_DRIVER="freedreno"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Adreno (Snapdragon) — Turnip HW acceleration ✓${NC}"
    elif [[ "$CHIPSET" == *"exynos"* ]] || [[ "$CHIPSET" == *"s5e"* ]] || [[ "$GPU_VENDOR" == *"mali"* ]]; then
        GPU_DRIVER="swrast"
        echo -e "  ${YELLOW}🎮${NC} GPU: ${WHITE}Mali (Exynos) — Software rendering (no Turnip)${NC}"
        echo -e "  ${YELLOW}   ⚠ Exynos devices do NOT support Turnip GPU acceleration.${NC}"
        echo -e "  ${YELLOW}   ⚠ We recommend XFCE or LXQt for smoother performance.${NC}"
    else
        # Fallback: assume Snapdragon for most Samsung global models
        GPU_DRIVER="freedreno"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Assumed Adreno (Snapdragon) — Turnip HW acceleration ✓${NC}"
    fi
    
    echo ""
    sleep 1
}
# ============== DESKTOP ENVIRONMENT (AUTO-SELECT XFCE4) ==============
choose_desktop() {
    DE_CHOICE="1"
    DE_NAME="XFCE4"
    echo -e "  ${GREEN}✓ Auto-selected: ${WHITE}${DE_NAME}${NC} (default)"
    echo ""
}
# ============== STEP 1: UPDATE SYSTEM ==============
step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating system packages...${NC}"
    echo ""
    
    (yes | pkg update -y > /dev/null 2>&1) &
    spinner $! "Updating package lists..."
    
    (yes | pkg upgrade -y > /dev/null 2>&1) &
    spinner $! "Upgrading installed packages..."
}
# ============== STEP 2: INSTALL REPOSITORIES ==============
step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding package repositories...${NC}"
    echo ""
    
    install_pkg "x11-repo" "X11 Repository"
    install_pkg "tur-repo" "TUR Repository (Firefox, VS Code)"
}
# ============== STEP 3: INSTALL TERMUX-X11 ==============
step_x11() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Termux-X11...${NC}"
    echo ""
    
    install_pkg "termux-x11-nightly" "Termux-X11 Display Server"
    install_pkg "xorg-xrandr" "XRandR (Display Settings)"
}
# ============== STEP 4: INSTALL DESKTOP ENVIRONMENT ==============
step_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing ${DE_NAME} Desktop...${NC}"
    echo ""
    
    if [ "$DE_CHOICE" == "1" ]; then
        install_pkg "xfce4" "XFCE4 Desktop Environment"
        install_pkg "xfce4-terminal" "XFCE4 Terminal"
        install_pkg "xfce4-whiskermenu-plugin" "Whisker Menu"
        install_pkg "plank-reloaded" "Plank Dock (macOS style)"
        install_pkg "thunar" "Thunar File Manager"
        install_pkg "mousepad" "Mousepad Text Editor"
    elif [ "$DE_CHOICE" == "2" ]; then
        install_pkg "lxqt" "LXQt Desktop"
        install_pkg "qterminal" "QTerminal"
        install_pkg "pcmanfm-qt" "PCManFM-Qt File Manager"
        install_pkg "featherpad" "FeatherPad Text Editor"
    elif [ "$DE_CHOICE" == "3" ]; then
        install_pkg "mate" "MATE Desktop"
        install_pkg "mate-tweak" "MATE Tweak"
        install_pkg "mate-terminal" "MATE Terminal"
        install_pkg "plank-reloaded" "Plank Dock"
    elif [ "$DE_CHOICE" == "4" ]; then
        install_pkg "plasma-desktop" "KDE Plasma Desktop"
        install_pkg "konsole" "Konsole Terminal"
        install_pkg "dolphin" "Dolphin File Manager"
    fi
}
# ============== STEP 5: INSTALL GPU DRIVERS ==============
step_gpu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Samsung GPU Acceleration (Turnip/Zink)...${NC}"
    echo ""
    
    install_pkg "mesa-zink" "Mesa Zink (OpenGL over Vulkan)"
    
    if [ "$GPU_DRIVER" == "freedreno" ]; then
        install_pkg "mesa-vulkan-icd-freedreno" "Turnip Adreno GPU Driver"
    else
        install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan Renderer"
    fi
    
    install_pkg "vulkan-loader-android" "Vulkan Loader"
    
    echo -e "  ${GREEN}✓${NC} GPU acceleration configured for Samsung!"
}
# ============== STEP 6: INSTALL AUDIO ==============
step_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Audio Support...${NC}"
    echo ""
    
    install_pkg "pulseaudio" "PulseAudio Sound Server"
}
# ============== STEP 7: INSTALL BROWSERS & DEV APPS ==============
step_apps() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Applications...${NC}"
    echo ""
    
    install_pkg "firefox" "Firefox Browser"
    install_pkg "chromium" "Chromium Browser"
    install_pkg "code-oss" "VS Code Editor"
    install_pkg "vlc" "VLC Media Player"
    install_pkg "git" "Git Version Control"
    install_pkg "wget" "Wget Downloader"
    install_pkg "curl" "cURL"
}
# ============== STEP 8: INSTALL PYTHON & FLASK ==============
step_python() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Python Environment...${NC}"
    echo ""
    
    install_pkg "python" "Python 3"
    
    (pip install flask requests beautifulsoup4 > /dev/null 2>&1) &
    spinner $! "Installing Python libraries (Flask, Requests, BS4)..."
    
    # Create Python Demo
    mkdir -p ~/demo_python
    cat > ~/demo_python/app.py << 'PYEOF'
from flask import Flask, render_template_string
app = Flask(__name__)
@app.route("/")
def hello():
    return render_template_string("""
    <html>
        <body style="background-color:#0d1117;color:#58a6ff;font-family:'Segoe UI',sans-serif;text-align:center;padding:50px">
            <h1>🚀 Samsung Mobile HackLab</h1>
            <h3>Python server running natively on your Galaxy!</h3>
            <p style="color:#8b949e">GPU-accelerated Linux • Turnip/Zink</p>
        </body>
    </html>
    """)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PYEOF
    echo -e "  ${GREEN}✓${NC} Python Flask demo created in ~/demo_python"
}
# ============== STEP 9: INSTALL REMOTE ACCESS (SSH + VNC) ==============
step_remote_access() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Remote Access (SSH + VNC)...${NC}"
    echo ""
    
    install_pkg "openssh" "OpenSSH Server"
    install_pkg "x11vnc" "x11vnc (VNC Server)"
    
    # Generate SSH host keys if not present
    if [ ! -f ~/.ssh/id_rsa ]; then
        (ssh-keygen -A > /dev/null 2>&1) &
        spinner $! "Generating SSH host keys..."
    fi
    
    # Set default password for SSH and VNC
    echo -e "  ${YELLOW}⏳${NC} Setting default password..."
    echo "pass
pass" | passwd > /dev/null 2>&1
    
    # Create VNC password file
    mkdir -p ~/.vnc
    x11vnc -storepasswd pass ~/.vnc/passwd > /dev/null 2>&1
    
    echo -e "  ${GREEN}✓${NC} Default password set: ${WHITE}pass${NC}"
    echo -e "  ${YELLOW}💡${NC} Change it later with: ${WHITE}passwd${NC}"
    echo -e "  ${GREEN}✓${NC} Remote access configured"
}

# ============== STEP 10: INSTALL ZSH ==============
step_zsh() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Zsh Shell...${NC}"
    echo ""
    
    install_pkg "zsh" "Zsh Shell"
    
    # Install Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        (git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" > /dev/null 2>&1) &
        spinner $! "Installing Oh My Zsh..."
        
        # Create default .zshrc
        cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
        # Source GPU config in zshrc
        echo 'source ~/.config/hacklab-gpu.sh 2>/dev/null' >> "$HOME/.zshrc"
    fi
    
    # Set zsh as default shell
    chsh -s zsh > /dev/null 2>&1
    
    echo -e "  ${GREEN}✓${NC} Zsh with Oh My Zsh installed and set as default shell"
}
# ============== STEP 12: INSTALL WINE (WINDOWS APPS) ==============
step_wine() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Wine (Windows Support)...${NC}"
    echo ""
    
    # Remove existing wine-stable to avoid conflicts
    (pkg remove wine-stable -y > /dev/null 2>&1) &
    spinner $! "Removing old Wine versions..."
    
    install_pkg "hangover-wine" "Wine Compatibility Layer"
    install_pkg "hangover-wowbox64" "Box64 Wrapper"
    
    # Symlink wine binaries
    ln -sf /data/data/com.termux/files/usr/opt/hangover-wine/bin/wine /data/data/com.termux/files/usr/bin/wine
    ln -sf /data/data/com.termux/files/usr/opt/hangover-wine/bin/winecfg /data/data/com.termux/files/usr/bin/winecfg
    
    # Apply font smoothing for better Windows UI
    echo -e "  ${YELLOW}⏳${NC} Applying Windows UI optimizations..."
    wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v FontSmoothing /t REG_SZ /d 2 /f > /dev/null 2>&1
    echo -e "  ${GREEN}✓${NC} Wine configured"
}
# ============== STEP 13: CREATE LAUNCHER SCRIPTS ==============
step_launchers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Launcher Scripts...${NC}"
    echo ""
    
    mkdir -p ~/.config
    
    # --- XDG path fix for Termux ---
    XDG_INJECT='export XDG_DATA_DIRS=/data/data/com.termux/files/usr/share:${XDG_DATA_DIRS}
export XDG_CONFIG_DIRS=/data/data/com.termux/files/usr/etc/xdg:${XDG_CONFIG_DIRS}'
    
    # KDE needs special env injection
    if [ "$DE_CHOICE" == "4" ]; then
        mkdir -p ~/.config/plasma-workspace/env
        cat > ~/.config/plasma-workspace/env/xdg_fix.sh << KDEXDG
#!/data/data/com.termux/files/usr/bin/bash
${XDG_INJECT}
KDEXDG
        chmod +x ~/.config/plasma-workspace/env/xdg_fix.sh
    fi
    
    # --- GPU Configuration ---
    cat > ~/.config/hacklab-gpu.sh << 'GPUEOF'
# Samsung Mobile HackLab - GPU Acceleration Config
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
GPUEOF
    if [ "$DE_CHOICE" == "4" ]; then
        echo "export KWIN_COMPOSE=O2ES" >> ~/.config/hacklab-gpu.sh
    else
        echo "${XDG_INJECT}" >> ~/.config/hacklab-gpu.sh
    fi
    
    echo -e "  ${GREEN}✓${NC} GPU config created"
    
    # Add to bashrc
    if ! grep -q "hacklab-gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/hacklab-gpu.sh 2>/dev/null' >> ~/.bashrc
    fi
    
    # --- Plank autostart for XFCE / MATE ---
    if [ "$DE_CHOICE" == "1" ] || [ "$DE_CHOICE" == "3" ]; then
        mkdir -p ~/.config/autostart
        cat > ~/.config/autostart/plank.desktop << 'PLANKEOF'
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
PLANKEOF
    else
        rm -f ~/.config/autostart/plank.desktop 2>/dev/null
    fi
    
    # --- Main Desktop Launcher ---
    cat > ~/start-hacklab.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash

# Prevent Android from killing Termux
termux-wake-lock 2>/dev/null

export XDG_DATA_DIRS=/data/data/com.termux/files/usr/share:${XDG_DATA_DIRS}
export XDG_CONFIG_DIRS=/data/data/com.termux/files/usr/etc/xdg:${XDG_CONFIG_DIRS}

# Detect installed desktop environments
DESKTOPS=()
declare -A EXEC_CMDS
declare -A KILL_CMDS

if command -v startxfce4 >/dev/null 2>&1; then
    DESKTOPS+=("XFCE4")
    EXEC_CMDS["XFCE4"]="startxfce4"
    KILL_CMDS["XFCE4"]="pkill -9 xfce4-session; pkill -9 plank"
fi

if command -v startlxqt >/dev/null 2>&1; then
    DESKTOPS+=("LXQt")
    EXEC_CMDS["LXQt"]="startlxqt"
    KILL_CMDS["LXQt"]="pkill -9 lxqt-session"
fi

if command -v mate-session >/dev/null 2>&1; then
    DESKTOPS+=("MATE")
    EXEC_CMDS["MATE"]="mate-session"
    KILL_CMDS["MATE"]="pkill -9 mate-session; pkill -9 plank"
fi

if command -v startplasma-x11 >/dev/null 2>&1; then
    DESKTOPS+=("KDE Plasma")
    EXEC_CMDS["KDE Plasma"]="(sleep 5 && pkill -9 plasmashell && plasmashell) > /dev/null 2>&1 & startplasma-x11"
    KILL_CMDS["KDE Plasma"]="pkill -9 startplasma-x11; pkill -9 kwin_x11; pkill -9 plasmashell"
fi

if [ ${#DESKTOPS[@]} -eq 0 ]; then
    echo "❌ No desktop environments found! Run setup-hacklab.sh first."
    exit 1
fi

# Auto-select first available DE (no prompt)
SELECTED_DE="${DESKTOPS[0]}"

echo ""
echo "🚀 Starting Samsung Mobile HackLab (${SELECTED_DE})..."
echo ""

# Load GPU config
source ~/.config/hacklab-gpu.sh 2>/dev/null

# Kill any existing sessions
echo "🔄 Cleaning up old sessions..."
pkill -9 -f "termux.x11" 2>/dev/null
eval "${KILL_CMDS["${SELECTED_DE}"]}" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null

# === AUDIO SETUP ===
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "🔊 Starting audio server..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

# === START X11 ===
echo "📺 Starting X11 display server..."
termux-x11 :0 -ac &
sleep 3
export DISPLAY=:0

# === START SSH ===
echo "🔑 Starting SSH server (port 8022)..."
pkill sshd 2>/dev/null
sshd

# === START VNC ===
echo "🌐 Starting VNC server (port 5900)..."
pkill x11vnc 2>/dev/null
x11vnc -display :0 -forever -rfbauth ~/.vnc/passwd -listen 0.0.0.0 -rfbport 5900 -bg > /dev/null 2>&1

# Get device IP
DEVICE_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
[ -z "$DEVICE_IP" ] && DEVICE_IP=$(ifconfig 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Open the Termux-X11 app to see desktop!"
echo "  🔊 Audio is enabled!"
echo "  🎮 GPU acceleration is active!"
echo ""
echo "  🌐 REMOTE ACCESS:"
echo "  SSH: ssh ${DEVICE_IP} -p 8022"
echo "  VNC: vnc://${DEVICE_IP}:5900"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

eval "${EXEC_CMDS["${SELECTED_DE}"]}"
LAUNCHEREOF
    chmod +x ~/start-hacklab.sh
    echo -e "  ${GREEN}✓${NC} Created ~/start-hacklab.sh"
    
    # --- Quick Tools Menu ---
    cat > ~/hacktools.sh << 'TOOLSEOF'
#!/data/data/com.termux/files/usr/bin/bash
while true; do
    clear
    echo ""
    echo "╔═══════════════════════════════════════════════╗"
    echo "║   🔧 Samsung Mobile HackLab - Quick Tools     ║"
    echo "╠═══════════════════════════════════════════════╣"
    echo "║                                               ║"
    echo "║   1) 🌐 Start VNC Server (remote desktop)    ║"
    echo "║   2) 🔑 Start SSH Server                      ║"
    echo "║   3) 🖥️  Start Desktop                        ║"
    echo "║   4) 🎮 Check GPU Status                      ║"
    echo "║   0) ❌ Exit                                  ║"
    echo "║                                               ║"
    echo "╚═══════════════════════════════════════════════╝"
    echo ""
    read -p "  Select option: " choice
    
    case $choice in
        1)
            echo ""
            echo "  Starting VNC server on port 5900..."
            echo "  Connect from Mac: open vnc://\$(hostname -I | awk '{print \$1}'):5900"
            echo "  Password: pass"
            x11vnc -display :0 -forever -rfbauth ~/.vnc/passwd -listen 0.0.0.0 -rfbport 5900
            ;;
        2)
            echo ""
            echo "  Starting SSH server on port 8022..."
            sshd
            echo "  Connect from Mac: ssh \$(whoami)@\$(hostname -I | awk '{print \$1}') -p 8022"
            read -p "  Press Enter to continue..."
            ;;
        3) 
            bash ~/start-hacklab.sh
            ;;
        4)
            echo ""
            echo "  === GPU Information ==="
            glxinfo 2>/dev/null | grep -i "renderer\|vendor\|version" || echo "  glxinfo not available (install mesa-utils)"
            echo ""
            vulkaninfo 2>/dev/null | head -20 || echo "  vulkaninfo not available"
            echo ""
            read -p "  Press Enter to continue..."
            ;;
        0) 
            echo ""
            echo "  👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "  Invalid option."
            sleep 1
            ;;
    esac
done
TOOLSEOF
    chmod +x ~/hacktools.sh
    echo -e "  ${GREEN}✓${NC} Created ~/hacktools.sh"
    
    # --- Desktop Stop Script ---
    cat > ~/stop-hacklab.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "🛑 Stopping Samsung Mobile HackLab..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 xfce4-session 2>/dev/null
pkill -9 plank 2>/dev/null
pkill -9 lxqt-session 2>/dev/null
pkill -9 mate-session 2>/dev/null
pkill -9 startplasma-x11 2>/dev/null
pkill -9 kwin_x11 2>/dev/null
pkill -9 plasmashell 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
pkill x11vnc 2>/dev/null
pkill sshd 2>/dev/null
termux-wake-unlock 2>/dev/null
echo "✓ Desktop, VNC, and SSH stopped."
STOPEOF
    chmod +x ~/stop-hacklab.sh
    echo -e "  ${GREEN}✓${NC} Created ~/stop-hacklab.sh"
}
# ============== STEP 14: CREATE DESKTOP SHORTCUTS ==============
step_shortcuts() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Desktop Shortcuts...${NC}"
    echo ""
    
    mkdir -p ~/Desktop
    
    # Determine terminal command based on DE
    case $DE_CHOICE in
        1) TERM_CMD="xfce4-terminal"; TERM_EXEC_FLAG="-e";;
        2) TERM_CMD="qterminal"; TERM_EXEC_FLAG="-e";;
        3) TERM_CMD="mate-terminal"; TERM_EXEC_FLAG="-e";;
        4) TERM_CMD="konsole"; TERM_EXEC_FLAG="-e";;
    esac
    
    # Firefox
    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF
    
    # Chromium
    cat > ~/Desktop/Chromium.desktop << 'EOF'
[Desktop Entry]
Name=Chromium
Comment=Web Browser
Exec=chromium --no-sandbox
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
EOF
    
    # VS Code
    cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Comment=Code Editor
Exec=code-oss --no-sandbox
Icon=code-oss
Type=Application
Categories=Development;
EOF
    
    # VLC
    cat > ~/Desktop/VLC.desktop << 'EOF'
[Desktop Entry]
Name=VLC Media Player
Comment=Media Player
Exec=vlc
Icon=vlc
Type=Application
Categories=AudioVideo;
EOF
    
    # Terminal
    cat > ~/Desktop/Terminal.desktop << EOF
[Desktop Entry]
Name=Terminal
Comment=Terminal Emulator
Exec=${TERM_CMD}
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
EOF
    
    # Windows Explorer via Wine
    cat > ~/Desktop/Windows_Explorer.desktop << 'EOF'
[Desktop Entry]
Name=Windows Explorer
Comment=Windows File Manager (Wine)
Exec=wine winefile
Icon=folder-windows
Type=Application
Categories=System;
EOF
    
    # Wine Config
    cat > ~/Desktop/Wine_Config.desktop << 'EOF'
[Desktop Entry]
Name=Wine Config
Comment=Windows Settings
Exec=wine winecfg
Icon=wine
Type=Application
Categories=Settings;
EOF
    
    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Desktop shortcuts created"
}
# ============== STEP 15: FINAL CONFIGURATION ==============
step_finalize() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Final Configuration...${NC}"
    echo ""
    
    # Set proper permissions
    chmod -R 755 ~/Desktop 2>/dev/null
    
    # Source GPU config in current session
    source ~/.config/hacklab-gpu.sh 2>/dev/null
    
    echo -e "  ${GREEN}✓${NC} Configuration complete!"
}
# ============== COMPLETION SCREEN ==============
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║         ✅  INSTALLATION COMPLETE!  ✅                        ║
    ║                                                               ║
    ║              🎉 100% - All Done! 🎉                           ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
COMPLETE
    echo -e "${NC}"
    
    echo -e "${WHITE}📱 Your Samsung Mobile HackLab is ready!${NC}"
    echo -e "${WHITE}   Desktop: ${CYAN}${DE_NAME}${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}🚀 TO START THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/start-hacklab.sh${NC}"
    echo ""
    echo -e "${WHITE}🔧 FOR QUICK TOOLS MENU:${NC}"
    echo -e "   ${GREEN}bash ~/hacktools.sh${NC}"
    echo ""
    echo -e "${WHITE}🛑 TO STOP THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/stop-hacklab.sh${NC}"
    echo ""
    echo -e "${WHITE}🐍 PYTHON FLASK DEMO:${NC}"
    echo -e "   ${GREEN}cd ~/demo_python && python app.py${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📦 INSTALLED TOOLS:${NC}"
    echo ""
    echo -e "  ${WHITE}🌐 Remote Access:${NC}"
    echo -e "     • SSH Server (port 8022)"
    echo -e "     • VNC Server (x11vnc)"
    echo ""
    echo -e "  ${WHITE}💻 Development & Apps:${NC}"
    echo -e "     • Python 3 + Flask"
    echo -e "     • VS Code, Git, Firefox, Chromium, VLC"
    echo -e "     • Zsh + Oh My Zsh"
    echo ""
    echo -e "  ${WHITE}🖥️  Desktop & System:${NC}"
    echo -e "     • ${DE_NAME} Desktop Environment"
    echo -e "     • GPU Acceleration (Turnip/Zink)"
    echo -e "     • PulseAudio, Wine/Hangover"
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📺 Subscribe: https://youtube.com/@TechJarves${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}⚡ TIP: Open Termux-X11 app first, then run start-hacklab.sh${NC}"
    echo ""
}
# ============== MAIN INSTALLATION ==============
main() {
    show_banner
    
    echo -e "${WHITE}  Installing complete Linux desktop with GPU acceleration${NC}"
    echo -e "${WHITE}  and remote access on your Samsung Galaxy phone.${NC}"
    echo ""
    echo -e "${GRAY}  Estimated time: 20-40 minutes (depends on internet speed)${NC}"
    echo ""
    
    detect_samsung
    choose_desktop
    
    step_update        # Step 1
    step_repos         # Step 2
    step_x11           # Step 3
    step_desktop       # Step 4
    step_gpu           # Step 5
    step_audio         # Step 6
    step_apps          # Step 7
    step_python        # Step 8
    step_remote_access # Step 9
    step_zsh           # Step 10
    step_wine          # Step 11
    step_launchers     # Step 12
    step_shortcuts     # Step 13
    step_finalize      # Step 14
    
    show_completion
}
# ============== RUN ==============
main
