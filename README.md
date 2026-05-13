# pwnMyKali

> Mi setup personal de Kali Linux: bspwm minimalista, todo en Catppuccin Mocha, optimizado para sesiones de pentesting y CTFs en VMware.

![Kali](https://img.shields.io/badge/Kali-2025.x-557C94?logo=kalilinux\&logoColor=white)
![WM](https://img.shields.io/badge/WM-bspwm-1e1e2e)
![Theme](https://img.shields.io/badge/theme-Catppuccin%20Mocha-cba6f7)
![License](https://img.shields.io/badge/license-MIT-a6e3a1)

---

## Por qué este repo

El XFCE que trae Kali por defecto es funcional pero pesado y ocupa demasiado espacio mental. Quería algo que:

- Arranque en **bspwm** y consuma ~150 MB en idle (vs ~700 MB del XFCE base)
- Maneje todo desde teclado (cero ratón salvo para Burp)
- Se vea cohesionado sin sacrificar legibilidad en pantalla pequeña de VM
- Sea **reproducible**: un script y queda idéntico a la última vez

Resultado: este repo. Un solo comando lo despliega.

---

## Stack

| Capa            | Pieza                                      |
|-----------------|--------------------------------------------|
| Window manager  | bspwm + sxhkd                              |
| Status bar      | polybar                                    |
| Compositor      | picom                                      |
| Terminal        | kitty                                      |
| Shell + prompt  | zsh · oh-my-zsh · Powerlevel10k            |
| Multiplexer     | tmux + oh-my-tmux                          |
| Launcher / menús| rofi                                       |
| Editor          | neovim                                     |
| Tipografía      | JetBrainsMono Nerd Font · Hack Nerd Font   |
| Paleta          | Catppuccin Mocha (+ 9 alternativas)        |

---

## Instalación paso a paso

### Requisitos previos

- **Kali Linux 2025.x** (rolling) recién instalado — VMware Workstation/Fusion, VirtualBox o bare metal
- Usuario no-root con permisos `sudo`
- Conexión a Internet estable
- ~3 GB libres (paquetes + fuentes Nerd)
- Recomendado: snapshot de la VM antes de empezar (por si quieres rebobinar limpio)

### Pasos

**1. Arranca tu Kali e inicia sesión** con tu usuario normal. Abre una terminal.

**2. Asegura que `git` está instalado:**
```bash
sudo apt update && sudo apt install -y git
```

**3. Clona el repo en tu home:**
```bash
cd ~
git clone https://github.com/pwnVader/pwnMyKali.git
cd pwnMyKali
```

**4. Lanza el bootstrap** *(sin `sudo` — el script te pedirá la clave cuando la necesite)*:
```bash
bash pwnmykali.sh
```

Durante la ejecución vas a ver:
- Un banner ASCII de `pwnMyKali`
- Un **prompt para fijar la timezone** (Enter para mantener la actual, o algo como `Europe/Madrid`, `America/Mexico_City`)
- La ruta del **backup** de tus dotfiles previas (en `~/.pwnmykali-backup-<timestamp>/`)
- La ruta del **logfile** completo (en `/tmp/pwnmykali-install-*.log`)
- Descarga e instalación de paquetes, fuentes, oh-my-zsh, plugins, tmux, fzf, etc.

Tarda **5–10 minutos** dependiendo de tu red.

**5. Cuando termine, reinicia:**
```bash
sudo reboot
```

**6. En la pantalla de login** *(antes de meter la contraseña)*:
- Haz clic en el **icono de engranaje** (rueda dentada) que aparece junto al campo de contraseña
- Selecciona **`bspwm`** como sesión
- Mete tu contraseña y entra

**7. Lo que deberías ver:** wallpaper, polybar arriba con módulos (target, red, CPU, memoria, reloj, menú power), terminal vacía. Si la polybar no aparece, salta a [Troubleshooting](#troubleshooting).

### Primer arranque — prueba estos atajos

| Atajo                | Resultado                                |
|----------------------|------------------------------------------|
| `Super + Enter`      | Abre kitty                               |
| `Super + d`          | Lanzador rofi                            |
| `Super + Shift + f`  | Firefox                                  |
| `Super + 1..9`       | Cambia de escritorio                     |
| Clic der. en polybar | Menú de cambio de tema                   |

Si todo responde, ya estás listo.

---

## Cambiar tema en caliente

10 paletas disponibles, intercambiables sin reiniciar:

```bash
~/.config/polybar/forest/scripts/styles.sh --mocha       # default
~/.config/polybar/forest/scripts/styles.sh --macchiato
~/.config/polybar/forest/scripts/styles.sh --frappe
~/.config/polybar/forest/scripts/styles.sh --latte
~/.config/polybar/forest/scripts/styles.sh --nord
~/.config/polybar/forest/scripts/styles.sh --gruvbox
~/.config/polybar/forest/scripts/styles.sh --tokyonight
~/.config/polybar/forest/scripts/styles.sh --everforest
~/.config/polybar/forest/scripts/styles.sh --dracula
~/.config/polybar/forest/scripts/styles.sh --rose-pine
```

O abre el menú gráfico con **clic derecho en el icono del launcher** (esquina izquierda de la polybar).

> Nota: el switcher solo cambia polybar + rofi. Para que kitty cambie de paleta edita `~/.config/kitty/color.ini` con la paleta correspondiente y recarga (`Ctrl + Shift + F5`).

---

## Cheatsheet de atajos

<details>
<summary><b>Ver tabla completa</b></summary>

### Navegación
| Atajo                       | Acción                                          |
|-----------------------------|-------------------------------------------------|
| `Super + 1..9, 0`           | Cambia al escritorio N                          |
| `Super + Tab`               | Alterna entre los dos últimos escritorios       |
| `Super + Flechas`           | Mueve el foco                                   |
| `Super + bracketleft/right` | Escritorio anterior / siguiente                 |

### Ventanas
| Atajo                       | Acción                                          |
|-----------------------------|-------------------------------------------------|
| `Super + Shift + Flechas`   | Mueve la ventana                                |
| `Super + Shift + 1..9, 0`   | Envía la ventana a otro escritorio              |
| `Super + Alt + Flechas`     | Redimensiona                                    |
| `Super + w`                 | Cierra ventana                                  |
| `Super + Shift + w`         | Fuerza cierre                                   |
| `Super + m`                 | Tiled / monocle                                 |
| `Super + t / Shift+t / s / f` | tiled · pseudo · floating · fullscreen        |

### Aplicaciones
| Atajo                       | Acción                                          |
|-----------------------------|-------------------------------------------------|
| `Super + Enter`             | Kitty                                           |
| `Super + d`                 | Rofi (drun)                                     |
| `Super + Shift + f`         | Firefox                                         |
| `Super + Shift + b`         | Burp Suite                                      |
| `Super + Shift + a`         | Thunar                                          |

### Sistema / WM
| Atajo                       | Acción                                          |
|-----------------------------|-------------------------------------------------|
| `Super + Alt + r`           | Recargar bspwm                                  |
| `Super + Alt + q`           | Salir de bspwm                                  |
| `Super + Escape`            | Recargar sxhkd                                  |

### Capturas
| Atajo                       | Acción                                          |
|-----------------------------|-------------------------------------------------|
| `Print`                     | Captura: selección                              |
| `Ctrl + Print`              | Captura: pantalla completa                      |
| `Alt + Print`               | Captura: ventana enfocada                       |

Las capturas se guardan en `~/screenshots/`.

</details>

---

## Aliases / comandos extra del shell

| Comando            | Hace                                                          |
|--------------------|---------------------------------------------------------------|
| `target 10.0.0.1`  | Fija la IP objetivo y la muestra en la polybar (módulo 󰓾)     |
| `target reset`     | Limpia el objetivo                                            |
| `t` / `tt`         | Alias cortos de `target` / `target reset`                     |
| `screenshot`       | Captura pantalla (`screenshot select` / `screenshot window`)  |
| `serve`            | `python3 -m http.server` en el directorio actual (puerto 8000)|
| `serve8080`        | Lo mismo en :8080                                             |
| `listen <port>`    | `nc -lvnp <port>`                                             |
| `myip`             | IP pública                                                    |
| `lanip`            | Interfaces locales con su IP                                  |
| `ports`            | `ss -tulpn`                                                   |
| `urldecode` / `urlencode` | URL-encoding rápido                                    |
| `b64d` / `b64e`    | Base64 decode / encode                                        |

---

## Troubleshooting

**La polybar no aparece después de elegir bspwm**
Abre una terminal con `Super+Enter` y ejecuta:
```bash
~/.config/polybar/forest/launch.sh
```
El error te dice qué falta (típicamente un módulo de red mal nombrado).

**Sin glifos / cuadritos en la polybar**
La Nerd Font no se cargó. Verifica:
```bash
fc-list | grep -i "nerd font"
```
Si no aparece nada, relanza solo la sección de fuentes editando `pwnmykali.sh` o copia manualmente los `.ttf` desde `~/.local/share/fonts/` y `fc-cache -f`.

**`xrandr` no detecta la resolución correcta en VMware**
Edita `~/.config/bspwm/bspwmrc` y reemplaza el bloque final por una resolución fija:
```bash
xrandr --output <tu-output> --mode 1920x1080
```
(El output lo ves con `xrandr | head`.)

**Quiero volver al XFCE de Kali**
En la pantalla de login, engranaje → `Xfce Session`. Tu config de bspwm sigue ahí intacta.

**Quiero deshacer todo**
El instalador dejó un backup. Restaurar:
```bash
LAST_BACKUP=$(ls -td ~/.pwnmykali-backup-* | head -n1)
cp -a "$LAST_BACKUP"/. ~/
```

---

## Estructura del repo

```
pwnMyKali/
├── pwnmykali.sh                       # Bootstrap idempotente
├── README.md
├── LICENSE
├── CONFIGS/
│   ├── zshrc                          # Aliases + plugins + p10k
│   ├── p10k.zsh                       # Prompt config
│   ├── tmux.conf.local                # Override de oh-my-tmux
│   └── config/                        # → ~/.config/
│       ├── bspwm/
│       ├── sxhkd/
│       ├── kitty/
│       ├── picom/
│       └── polybar/forest/
├── SCRIPTS/                           # → /usr/bin/{target,screenshot}
│   ├── target.sh
│   └── screenshot.sh
└── WALLPAPERS/                        # → ~/Wallpapers/
```

---

## Roadmap

- [ ] Config de **neovim** con tema Catppuccin Mocha y lazy.nvim
- [ ] Integración **tmux** con la paleta del switcher (no solo polybar/rofi)
- [ ] `fastfetch.jsonc` con el logo y colores del tema activo
- [ ] CLI `pwnmykali` global para cambiar tema desde la terminal sin recordar la ruta del script
- [ ] Soporte multi-monitor en `bspwmrc`

---

## Licencia

MIT — © 2026 [Jesus P Romero](https://github.com/pwnVader). Ver [`LICENSE`](LICENSE).
