#!/usr/bin/env bash
#
# pwnMyKali — live theme switcher for polybar + rofi.
# Usage: styles.sh --<theme>
# See the bottom of this file for the list of themes.
#

set -uo pipefail

PFILE="$HOME/.config/polybar/forest/colors.ini"
RFILE="$HOME/.config/polybar/forest/scripts/rofi/colors.rasi"

apply() {
    sed -i -e "s/^background = #.*/background = $BG/g" "$PFILE"
    sed -i -e "s/^foreground = #.*/foreground = $FG/g" "$PFILE"
    sed -i -e "s/^sep        = #.*/sep        = $SEP/g" "$PFILE"

    cat > "$RFILE" <<-EOF
	/* $NAME — rofi palette */

	* {
	  al:   #00000000;
	  bg:   ${BG}FF;
	  bga:  ${BGA}FF;
	  fg:   ${FG}FF;
	  ac:   ${AC}FF;
	  se:   ${SE}FF;
	}
EOF

    polybar-msg cmd restart >/dev/null 2>&1 || true
}

case "${1:-}" in
    --mocha|--catppuccin-mocha|--default)
        NAME="Catppuccin Mocha"
        BG="#1e1e2e"; FG="#cdd6f4"; BGA="#313244"; SEP="#45475a"
        AC="#f5c2e7"; SE="#89b4fa";   apply ;;

    --macchiato|--catppuccin-macchiato)
        NAME="Catppuccin Macchiato"
        BG="#24273a"; FG="#cad3f5"; BGA="#363a4f"; SEP="#494d64"
        AC="#f5bde6"; SE="#8aadf4";   apply ;;

    --frappe|--catppuccin-frappe)
        NAME="Catppuccin Frappé"
        BG="#303446"; FG="#c6d0f5"; BGA="#414559"; SEP="#51576d"
        AC="#f4b8e4"; SE="#8caaee";   apply ;;

    --latte|--catppuccin-latte)
        NAME="Catppuccin Latte"
        BG="#eff1f5"; FG="#4c4f69"; BGA="#e6e9ef"; SEP="#bcc0cc"
        AC="#ea76cb"; SE="#1e66f5";   apply ;;

    --nord)
        NAME="Nord"
        BG="#2e3440"; FG="#eceff4"; BGA="#3b4252"; SEP="#4c566a"
        AC="#bf616a"; SE="#88c0d0";   apply ;;

    --gruvbox)
        NAME="Gruvbox Dark"
        BG="#282828"; FG="#ebdbb2"; BGA="#3c3836"; SEP="#504945"
        AC="#fb4934"; SE="#8ec07c";   apply ;;

    --tokyonight)
        NAME="Tokyo Night"
        BG="#1a1b26"; FG="#c0caf5"; BGA="#24283b"; SEP="#414868"
        AC="#bb9af7"; SE="#7aa2f7";   apply ;;

    --everforest)
        NAME="Everforest Dark"
        BG="#2d353b"; FG="#d3c6aa"; BGA="#374145"; SEP="#475258"
        AC="#e67e80"; SE="#a7c080";   apply ;;

    --dracula)
        NAME="Dracula"
        BG="#282a36"; FG="#f8f8f2"; BGA="#44475a"; SEP="#6272a4"
        AC="#ff79c6"; SE="#8be9fd";   apply ;;

    --rose-pine|--rosepine)
        NAME="Rosé Pine"
        BG="#191724"; FG="#e0def4"; BGA="#1f1d2e"; SEP="#26233a"
        AC="#eb6f92"; SE="#9ccfd8";   apply ;;

    *)
        cat <<-USAGE
		Uso: $(basename "$0") --<tema>

		Temas disponibles:
		  --mocha       Catppuccin Mocha (default)
		  --macchiato   Catppuccin Macchiato
		  --frappe      Catppuccin Frappé
		  --latte       Catppuccin Latte
		  --nord        Nord
		  --gruvbox     Gruvbox Dark
		  --tokyonight  Tokyo Night
		  --everforest  Everforest Dark
		  --dracula     Dracula
		  --rose-pine   Rosé Pine
		USAGE
        exit 1 ;;
esac
