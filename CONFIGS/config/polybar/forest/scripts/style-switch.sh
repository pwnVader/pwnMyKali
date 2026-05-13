#!/usr/bin/env bash
#
# pwnMyKali — rofi-based theme picker.
#

set -uo pipefail

SDIR="$HOME/.config/polybar/forest/scripts"

MENU=$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p 'Tema' \
    -theme "$SDIR/rofi/styles.rasi" \
    <<< " Catppuccin Mocha| Catppuccin Macchiato| Catppuccin Frappé| Catppuccin Latte| Nord| Gruvbox| Tokyo Night| Everforest| Dracula| Rosé Pine|")

case "$MENU" in
    *Mocha)      "$SDIR/styles.sh" --mocha ;;
    *Macchiato)  "$SDIR/styles.sh" --macchiato ;;
    *Frappé)     "$SDIR/styles.sh" --frappe ;;
    *Latte)      "$SDIR/styles.sh" --latte ;;
    *Nord)       "$SDIR/styles.sh" --nord ;;
    *Gruvbox)    "$SDIR/styles.sh" --gruvbox ;;
    *"Tokyo Night") "$SDIR/styles.sh" --tokyonight ;;
    *Everforest) "$SDIR/styles.sh" --everforest ;;
    *Dracula)    "$SDIR/styles.sh" --dracula ;;
    *"Rosé Pine") "$SDIR/styles.sh" --rose-pine ;;
esac
