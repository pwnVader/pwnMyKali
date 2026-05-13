# pwnMyKali

Despliega un entorno de hacking minimalista y funcional sobre **Kali Linux 2025.x** con un solo script: bspwm + polybar + kitty + zsh, todo cableado en paleta **Catppuccin Mocha** y con switcher de temas en caliente.

## Probado en

- Kali Linux 2025.x (rolling) — VMware Workstation/Fusion, VirtualBox y Bare Metal
- Resolución mínima recomendada: 1920×1080

## Instalación

> Hazlo desde una instalación limpia de Kali, como usuario normal (no root, no sudo).

```bash
git clone https://github.com/<tu-usuario>/pwnMyKali.git
cd pwnMyKali
bash pwnmykali.sh
sudo reboot
```

Al reiniciar, en la pantalla de login elige sesión **bspwm**. El wallpaper se toma de `~/Wallpapers/wallpaper.*`.

El instalador hace backup de tus dotfiles existentes en `~/.pwnmykali-backup-<timestamp>/` antes de tocar nada.

## Atajos de teclado

| Atajo                            | Acción                                                  |
|----------------------------------|---------------------------------------------------------|
| `Super + Enter`                  | Terminal Kitty                                          |
| `Super + d`                      | Lanzador (rofi)                                         |
| `Super + 1..9,0`                 | Cambia de escritorio                                    |
| `Super + Shift + 1..9,0`         | Mueve la ventana al escritorio                          |
| `Super + Flechas`                | Foco entre ventanas                                     |
| `Super + Shift + Flechas`        | Mueve la ventana                                        |
| `Super + Alt + Flechas`          | Redimensiona la ventana                                 |
| `Super + Tab`                    | Alterna entre los dos últimos escritorios               |
| `Super + w` / `Super + Shift+w`  | Cierra / fuerza el cierre                               |
| `Super + Alt + r` / `q`          | Recarga / reinicia bspwm                                |
| `Super + m`                      | Alterna tiled / monocle                                 |
| `Super + {t,Shift+t,s,f}`        | tiled / pseudo / floating / fullscreen                  |
| `Super + Shift + f`              | Firefox                                                 |
| `Super + Shift + b`              | Burp Suite                                              |
| `Super + Shift + a`              | Thunar                                                  |
| `Print`                          | Captura selección                                       |
| `Ctrl + Print`                   | Captura pantalla completa                               |
| `Alt + Print`                    | Captura ventana enfocada                                |
| Clic derecho en polybar          | Menú de cambio de tema                                  |

## Comandos útiles

| Comando            | Descripción                                                   |
|--------------------|---------------------------------------------------------------|
| `target 10.0.0.1`  | Fija la IP objetivo y la muestra en la polybar                |
| `target reset`     | Limpia el objetivo                                            |
| `screenshot`       | Captura pantalla (alias: `select`, `window`)                  |
| `tmux`             | Entra a tmux (config: `~/.tmux.conf.local`)                   |
| `p10k configure`   | Reconfigura el prompt Powerlevel10k                           |

## Temas disponibles

Cambiables en caliente desde el clic derecho de la polybar o ejecutando `~/.config/polybar/forest/scripts/styles.sh --<tema>`:

- **Catppuccin Mocha** (por defecto)
- Catppuccin Macchiato
- Catppuccin Frappé
- Catppuccin Latte
- Nord
- Gruvbox
- Tokyo Night
- Everforest
- Dracula
- Rosé Pine

## Paquetes incluidos

```
bspwm · sxhkd · polybar · picom · kitty · rofi · feh · scrot · neovim
zsh · oh-my-zsh · powerlevel10k · zsh-autosuggestions · zsh-syntax-highlighting
tmux + oh-my-tmux · fzf · lsd · bat · bpython · fastfetch · ranger
JetBrainsMono Nerd Font · Hack Nerd Font
open-vm-tools-desktop (compatibilidad VMware)
```

## Rutas de configuración

| Ruta                                    | Contenido                              |
|-----------------------------------------|----------------------------------------|
| `~/.config/sxhkd/sxhkdrc`               | Atajos                                 |
| `~/.config/bspwm/bspwmrc`               | Reglas del WM                          |
| `~/.config/polybar/forest/`             | Barra, módulos, colores                |
| `~/.config/kitty/kitty.conf`            | Terminal                               |
| `~/.zshrc`, `~/.p10k.zsh`               | Shell y prompt                         |
| `~/Wallpapers/`                         | Wallpapers (uno llamado `wallpaper.*`) |

## Licencia

MIT — ver [LICENSE](LICENSE). Maintainer: Jesus P Romero.
