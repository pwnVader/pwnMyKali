#!/usr/bin/env bash
#
# pwnMyKali — Kali Linux hacking environment bootstrapper.
# Tested on Kali Linux 2025.x rolling (VMware, VirtualBox, bare metal).
#

set -uo pipefail

GREEN=$(tput setaf 2 2>/dev/null || echo "")
BLUE=$(tput setaf 4 2>/dev/null || echo "")
RED=$(tput setaf 1 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

log()  { printf "%s[+]%s %s\n" "$BLUE"   "$RESET" "$*"; }
warn() { printf "%s[!]%s %s\n" "$YELLOW" "$RESET" "$*"; }
err()  { printf "%s[-]%s %s\n" "$RED"    "$RESET" "$*" >&2; }
ok()   { printf "%s[✓]%s %s\n" "$GREEN"  "$RESET" "$*"; }

RPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/pwnmykali-install-$(date +%Y%m%d-%H%M%S).log"
BACKUP_DIR="$HOME/.pwnmykali-backup-$(date +%Y%m%d-%H%M%S)"
NERD_FONTS_VERSION="v3.4.0"

banner() {
    printf "%s" "$GREEN"
    cat <<'EOF'

      ____ __      ___ __  __      _  __     _ _
     | _ \\ \ /\ / / _ \  \/  |_   | |/ /__ _| (_)
     |  _/ \ V  V /| | | |\/| | || | ' // _` | | |
     | |    \_/\_/ | | | |  | |__ \ . \ (_| | | |
     |_|           |_|_|_|  |_|_/_/|_|\_\__,_|_|_|
                      pwnMyKali · v1.0
EOF
    printf "%s" "$RESET"
    printf "    bspwm · polybar · kitty · catppuccin mocha\n\n"
}

require_user() {
    if [[ "${EUID}" -eq 0 ]]; then
        err "No ejecutes como root."
        exit 1
    fi
    if [[ -n "${SUDO_USER:-}" ]]; then
        err "No uses sudo para invocar el script. Te pedirá la contraseña cuando sea necesario."
        exit 1
    fi
}

require_kali() {
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        if [[ "${ID:-}" != "kali" ]]; then
            warn "Esta no parece ser Kali Linux (ID=${ID:-unknown})."
            read -rp "    ¿Continuar de todos modos? [y/N] " yn
            [[ "${yn,,}" == "y" ]] || exit 1
        fi
    fi
}

ask_timezone() {
    local current
    current=$(timedatectl show -p Timezone --value 2>/dev/null || echo "UTC")

    local -a zones=(
        "America/Mexico_City"
        "America/Bogota"
        "America/Argentina/Buenos_Aires"
        "America/Santiago"
        "America/Lima"
        "America/Caracas"
        "America/Los_Angeles"
        "America/New_York"
        "Europe/Madrid"
        "Europe/London"
        "UTC"
    )

    printf "\n%s[?]%s Configurar zona horaria del sistema\n" "$YELLOW" "$RESET"
    printf "    Actual: %s%s%s\n\n" "$GREEN" "$current" "$RESET"
    printf "    Opciones rápidas:\n"
    local i=1
    for z in "${zones[@]}"; do
        printf "      %2d) %s\n" "$i" "$z"
        i=$((i+1))
    done
    printf "       0) Mantener la actual\n"
    printf "       c) Escribir una personalizada (formato Region/City)\n\n"

    local choice
    read -rp "    Tu elección [0]: " choice
    choice="${choice:-0}"

    local target=""
    case "$choice" in
        0|"")    ok "Timezone sin cambios ($current)"; return ;;
        c|C)
            read -rp "    Timezone (ej: America/Mexico_City): " target
            ;;
        *)
            if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#zones[@]} )); then
                target="${zones[$((choice-1))]}"
            else
                warn "Opción inválida; se mantiene $current"
                return
            fi
            ;;
    esac

    if [[ -z "$target" ]]; then
        warn "No se especificó timezone; se mantiene $current"
        return
    fi

    if timedatectl list-timezones | grep -qx "$target"; then
        sudo timedatectl set-timezone "$target" && ok "Timezone → $target"
    else
        warn "Timezone '$target' no es válida; se mantiene $current"
    fi
}

backup_existing() {
    log "Backup de configuración previa en $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    local paths=(
        "$HOME/.zshrc" "$HOME/.p10k.zsh" "$HOME/.tmux.conf.local"
        "$HOME/.config/bspwm" "$HOME/.config/sxhkd" "$HOME/.config/polybar"
        "$HOME/.config/kitty" "$HOME/.config/picom" "$HOME/.config/rofi"
    )
    for p in "${paths[@]}"; do
        if [[ -e "$p" ]]; then
            cp -a "$p" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
}

apt_install_strict() {
    # Critical group — abort the installer if anything in the group fails.
    if ! sudo apt install -y --no-install-recommends "$@"; then
        err "Fallo crítico instalando: $*"
        return 1
    fi
}

apt_install_soft() {
    # Optional group — install best-effort, one package at a time so a single
    # broken / renamed / disappeared package does not poison the whole batch.
    local missing=()
    for pkg in "$@"; do
        sudo apt install -y --no-install-recommends "$pkg" >/dev/null 2>&1 \
            || missing+=("$pkg")
    done
    if (( ${#missing[@]} > 0 )); then
        warn "Paquetes opcionales que no se pudieron instalar: ${missing[*]}"
    fi
}

install_packages() {
    log "Actualizando índice de paquetes"
    sudo apt update

    # ── Core WM stack — installer is useless without these ───────────────────
    log "Instalando WM core (bspwm, sxhkd, polybar, picom, rofi, kitty)"
    apt_install_strict \
        bspwm sxhkd polybar picom rofi kitty || return 1

    # suckless-tools provides `wmname`, needed by bspwmrc for the Java fix.
    # The package name does NOT match the binary name — known footgun.
    log "Instalando shell + utilidades base"
    apt_install_strict \
        git curl wget unzip zsh tmux vim neovim fzf \
        feh scrot imagemagick xclip xsel xdotool suckless-tools \
        acpi || return 1

    # Verify the critical binaries actually landed.
    local missing_core=()
    for bin in bspwm sxhkd polybar picom kitty rofi wmname feh; do
        command -v "$bin" >/dev/null || missing_core+=("$bin")
    done
    if (( ${#missing_core[@]} > 0 )); then
        err "Tras la instalación faltan binarios críticos: ${missing_core[*]}"
        return 1
    fi
    ok "WM core verificado"

    # ── VMware integration is critical when running inside VMware ────────────
    # Without open-vm-tools-desktop the user has no clipboard sync, dynamic
    # resolution, and most importantly keyboard/mouse pass-through can break
    # inside the X session (host events stop reaching X clients).
    local virt=""
    command -v systemd-detect-virt >/dev/null && virt=$(systemd-detect-virt 2>/dev/null || true)
    if [[ "$virt" == "vmware" ]] \
       || grep -qi vmware /sys/class/dmi/id/sys_vendor 2>/dev/null \
       || grep -qi vmware /sys/class/dmi/id/product_name 2>/dev/null; then
        log "Detectado VMware → instalando open-vm-tools-desktop como crítico"
        apt_install_strict open-vm-tools open-vm-tools-desktop || return 1
        sudo systemctl enable --now open-vm-tools.service 2>/dev/null || true
    else
        apt_install_soft open-vm-tools open-vm-tools-desktop
    fi

    # ── Optional / nice-to-have — install one by one ─────────────────────────
    log "Instalando utilidades opcionales (fallos no abortan)"
    apt_install_soft \
        ranger thunar lsd bat bpython fastfetch \
        fonts-jetbrains-mono fonts-hack \
        network-manager-gnome \
        firefox-esr \
        dirsearch feroxbuster gobuster nmap
}

install_nerd_fonts() {
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"

    for font in JetBrainsMono Hack; do
        if fc-list | grep -qi "${font} Nerd Font"; then
            ok "Nerd Font ${font} ya instalada"
            continue
        fi
        log "Descargando ${font} Nerd Font ${NERD_FONTS_VERSION}"
        local tmp; tmp=$(mktemp -d)
        if wget -q --show-progress \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/${font}.zip" \
            -O "$tmp/${font}.zip"; then
            unzip -qo "$tmp/${font}.zip" -d "$tmp/${font}"
            find "$tmp/${font}" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -exec mv -f {} "$fonts_dir/" \;
            ok "${font} Nerd Font instalada"
        else
            warn "No se pudo descargar ${font} Nerd Font; continuando"
        fi
        rm -rf "$tmp"
    done

    fc-cache -f >/dev/null
}

install_ohmyzsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        ok "Oh-My-Zsh ya instalado"
    else
        log "Instalando Oh-My-Zsh"
        RUNZSH=no CHSH=no \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    log "Instalando Powerlevel10k"
    if [[ -d "$custom/themes/powerlevel10k" ]]; then
        git -C "$custom/themes/powerlevel10k" pull --quiet || true
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$custom/themes/powerlevel10k"
    fi

    log "Instalando plugins de Zsh"
    for repo in "zsh-users/zsh-autosuggestions" "zsh-users/zsh-syntax-highlighting"; do
        local name="${repo##*/}"
        if [[ -d "$custom/plugins/$name" ]]; then
            git -C "$custom/plugins/$name" pull --quiet || true
        else
            git clone --depth=1 "https://github.com/${repo}.git" "$custom/plugins/$name"
        fi
    done

    log "Aplicando .zshrc y .p10k.zsh"
    cp -f "$RPATH/CONFIGS/zshrc"   "$HOME/.zshrc"
    cp -f "$RPATH/CONFIGS/p10k.zsh" "$HOME/.p10k.zsh"

    if [[ "$SHELL" != *zsh ]]; then
        log "Estableciendo zsh como shell por defecto"
        sudo chsh -s "$(command -v zsh)" "$USER" || \
            warn "No se pudo cambiar la shell; hazlo manualmente con: chsh -s \$(which zsh)"
    fi
}

install_fzf_keybinds() {
    if [[ ! -d "$HOME/.fzf" ]]; then
        log "Instalando fzf (keybindings y completions)"
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    fi
    yes | "$HOME/.fzf/install" --key-bindings --completion --no-update-rc >/dev/null
}

install_tmux_oh_my_tmux() {
    log "Instalando oh-my-tmux"
    if [[ ! -d "$HOME/.tmux" ]]; then
        git clone --depth=1 https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
    else
        git -C "$HOME/.tmux" pull --quiet || true
    fi
    ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
    cp -f "$RPATH/CONFIGS/tmux.conf.local" "$HOME/.tmux.conf.local"
}

deploy_configs() {
    log "Desplegando configuraciones en ~/.config"
    mkdir -p "$HOME/.config"
    cp -rf "$RPATH/CONFIGS/config/"* "$HOME/.config/"

    mkdir -p "$HOME/.config/polybar/forest/scripts"
    cp -f "$RPATH/SCRIPTS/"* "$HOME/.config/polybar/forest/scripts/"

    log "Enlazando comandos a /usr/bin"
    sudo ln -sf "$HOME/.config/polybar/forest/scripts/target.sh"     /usr/bin/target
    sudo ln -sf "$HOME/.config/polybar/forest/scripts/screenshot.sh" /usr/bin/screenshot

    chmod +x "$HOME/.config/bspwm/bspwmrc" \
             "$HOME/.config/bspwm/scripts/"* \
             "$HOME/.config/polybar/forest/launch.sh" \
             "$HOME/.config/polybar/forest/scripts/"*.sh \
             "$HOME/.config/polybar/forest/scripts/checkupdates"

    mkdir -p "$HOME/screenshots" "$HOME/Wallpapers"
    cp -rf "$RPATH/WALLPAPERS/"* "$HOME/Wallpapers/"
}

register_xsession() {
    # The bspwm apt package on Debian/Kali installs the binary but does NOT
    # drop a session file in /usr/share/xsessions/, so it never appears in the
    # LightDM session picker. We create it ourselves.
    log "Registrando bspwm como sesión X11 (/usr/share/xsessions/bspwm.desktop)"
    sudo mkdir -p /usr/share/xsessions
    sudo tee /usr/share/xsessions/bspwm.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=bspwm
Comment=Binary space partitioning window manager
Exec=bspwm
TryExec=bspwm
Type=Application
DesktopNames=bspwm
EOF
}

run_install() {
    # All the heavy lifting. Output is teed to LOG_FILE by main().
    # install_packages aborts on critical failures; everything else is
    # best-effort but reports its own failures.
    backup_existing       || return 1
    install_packages      || return 1
    install_nerd_fonts    || warn "Nerd Fonts: instalación parcial"
    install_ohmyzsh       || warn "oh-my-zsh: instalación parcial"
    install_fzf_keybinds  || warn "fzf: instalación parcial"
    install_tmux_oh_my_tmux || warn "tmux: instalación parcial"
    deploy_configs        || return 1
    register_xsession     || return 1
}

main() {
    require_user
    banner
    require_kali
    log "Log de la instalación: $LOG_FILE"

    # Interactive prompts run BEFORE we attach tee so the menu does not
    # contaminate the log and the script does not appear to "hang" later.
    ask_timezone

    # Tee just the install block; once it ends, tee exits cleanly and the
    # shell returns control to the user (no stuck stdout pipe at reboot time).
    run_install 2>&1 | tee -a "$LOG_FILE"
    local rc=${PIPESTATUS[0]}

    sync
    echo
    if [[ $rc -ne 0 ]]; then
        err "La instalación terminó con errores (rc=$rc). Revisa $LOG_FILE"
        exit "$rc"
    fi

    # Post-install sanity check: scream if bspwm or its session file are not
    # in place — these are exactly the two things that have to be right for
    # bspwm to be selectable at the LightDM login screen.
    local fatal=()
    command -v bspwm >/dev/null            || fatal+=("binario bspwm")
    [[ -x /usr/share/xsessions/bspwm.desktop ]] || \
        [[ -r /usr/share/xsessions/bspwm.desktop ]] || fatal+=("/usr/share/xsessions/bspwm.desktop")
    if (( ${#fatal[@]} > 0 )); then
        err "Comprobación final falló — faltan: ${fatal[*]}"
        err "bspwm NO aparecerá en el selector de sesión. Revisa $LOG_FILE"
        exit 1
    fi

    ok "Entorno desplegado correctamente."
    log "Backup de tu configuración anterior: $BACKUP_DIR"
    log "Log completo: $LOG_FILE"
    echo
    log "Reinicia con:  sudo reboot"
    log "En la pantalla de login, selecciona la sesión 'bspwm' antes de entrar."
}

main "$@"
