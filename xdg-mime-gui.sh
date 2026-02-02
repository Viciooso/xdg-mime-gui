#!/bin/bash

# Script GUI para gestionar aplicaciones predeterminadas con xdg-mime
# Requiere: zenity, xdg-utils

# Verificar que zenity está instalado
if ! command -v zenity &>/dev/null; then
  echo "Error: zenity no está instalado"
  echo "Instálalo con: sudo pacman -S zenity (Arch) o sudo apt install zenity (Debian/Ubuntu)"
  exit 1
fi

# Función para obtener la aplicación actual para un tipo MIME
get_current_app() {
  local mimetype="$1"
  xdg-mime query default "$mimetype" 2>/dev/null || echo "Ninguna"
}

# Función para listar aplicaciones disponibles
list_apps() {
  local apps_dir="/usr/share/applications"
  local local_apps_dir="$HOME/.local/share/applications"

  find "$apps_dir" "$local_apps_dir" -name "*.desktop" 2>/dev/null |
    xargs -I {} basename {} | sort -u
}

# Función principal
main_menu() {
  while true; do
    choice=$(zenity --list \
      --title="Gestor de Aplicaciones Predeterminadas" \
      --text="Selecciona una opción:" \
      --column="Opción" \
      "Establecer aplicación para tipo MIME" \
      "Ver aplicación actual para tipo MIME" \
      "Establecer navegador predeterminado" \
      "Establecer gestor de archivos" \
      "Establecer editor de texto" \
      "Establecer visor de imágenes" \
      "Establecer reproductor de vídeo" \
      "Salir" \
      --height=400 --width=500)

    case "$choice" in
    "Establecer aplicación para tipo MIME")
      set_mime_type
      ;;
    "Ver aplicación actual para tipo MIME")
      query_mime_type
      ;;
    "Establecer navegador predeterminado")
      set_browser
      ;;
    "Establecer gestor de archivos")
      set_file_manager
      ;;
    "Establecer editor de texto")
      set_text_editor
      ;;
    "Establecer visor de imágenes")
      set_image_viewer
      ;;
    "Establecer reproductor de vídeo")
      set_video_player
      ;;
    "Salir" | "")
      exit 0
      ;;
    esac
  done
}

# Establecer aplicación para tipo MIME específico
set_mime_type() {
  mimetype=$(zenity --entry \
    --title="Tipo MIME" \
    --text="Introduce el tipo MIME (ej: text/html, image/png, video/mp4):" \
    --entry-text="")

  if [ -z "$mimetype" ]; then
    return
  fi

  current=$(get_current_app "$mimetype")

  app=$(list_apps | zenity --list \
    --title="Seleccionar Aplicación" \
    --text="Tipo MIME: $mimetype\nActual: $current\n\nSelecciona la aplicación:" \
    --column="Aplicación" \
    --height=400 --width=500)

  if [ -n "$app" ]; then
    xdg-mime default "$app" "$mimetype"
    zenity --info --text="Aplicación '$app' establecida para '$mimetype'"
  fi
}

# Consultar aplicación para tipo MIME
query_mime_type() {
  mimetype=$(zenity --entry \
    --title="Consultar Tipo MIME" \
    --text="Introduce el tipo MIME a consultar:" \
    --entry-text="")

  if [ -n "$mimetype" ]; then
    current=$(get_current_app "$mimetype")
    zenity --info \
      --title="Aplicación Actual" \
      --text="Tipo MIME: $mimetype\nAplicación: $current"
  fi
}

# Establecer navegador predeterminado
set_browser() {
  browsers=$(list_apps | grep -i "firefox\|chrome\|chromium\|brave\|vivaldi\|opera\|qutebrowser\|falkon")

  current=$(get_current_app "text/html")

  browser=$(echo "$browsers" | zenity --list \
    --title="Navegador Predeterminado" \
    --text="Navegador actual: $current\n\nSelecciona un navegador:" \
    --column="Navegador" \
    --height=300 --width=400)

  if [ -n "$browser" ]; then
    xdg-mime default "$browser" text/html
    xdg-mime default "$browser" x-scheme-handler/http
    xdg-mime default "$browser" x-scheme-handler/https
    zenity --info --text="Navegador '$browser' establecido como predeterminado"
  fi
}

# Establecer gestor de archivos
set_file_manager() {
  managers=$(list_apps | grep -i "nautilus\|dolphin\|thunar\|pcmanfm\|nemo\|caja\|ranger\|files")

  current=$(get_current_app "inode/directory")

  manager=$(echo "$managers" | zenity --list \
    --title="Gestor de Archivos" \
    --text="Actual: $current\n\nSelecciona un gestor de archivos:" \
    --column="Gestor" \
    --height=300 --width=400)

  if [ -n "$manager" ]; then
    xdg-mime default "$manager" inode/directory
    zenity --info --text="Gestor de archivos '$manager' establecido"
  fi
}

# Establecer editor de texto
set_text_editor() {
  editors=$(list_apps | grep -i "gedit\|kate\|mousepad\|pluma\|nvim\|vim\|emacs\|code\|sublime\|atom\|nano")

  current=$(get_current_app "text/plain")

  editor=$(echo "$editors" | zenity --list \
    --title="Editor de Texto" \
    --text="Actual: $current\n\nSelecciona un editor:" \
    --column="Editor" \
    --height=300 --width=400)

  if [ -n "$editor" ]; then
    xdg-mime default "$editor" text/plain
    zenity --info --text="Editor '$editor' establecido"
  fi
}

# Establecer visor de imágenes
set_image_viewer() {
  viewers=$(list_apps | grep -i "eog\|gwenview\|ristretto\|feh\|sxiv\|viewnior\|nomacs\|gthumb")

  current=$(get_current_app "image/png")

  viewer=$(echo "$viewers" | zenity --list \
    --title="Visor de Imágenes" \
    --text="Actual: $current\n\nSelecciona un visor:" \
    --column="Visor" \
    --height=300 --width=400)

  if [ -n "$viewer" ]; then
    for type in image/png image/jpeg image/jpg image/gif image/webp image/svg+xml; do
      xdg-mime default "$viewer" "$type"
    done
    zenity --info --text="Visor '$viewer' establecido para imágenes"
  fi
}

# Establecer reproductor de vídeo
set_video_player() {
  players=$(list_apps | grep -i "vlc\|mpv\|totem\|celluloid\|smplayer\|dragon\|parole")

  current=$(get_current_app "video/mp4")

  player=$(echo "$players" | zenity --list \
    --title="Reproductor de Vídeo" \
    --text="Actual: $current\n\nSelecciona un reproductor:" \
    --column="Reproductor" \
    --height=300 --width=400)

  if [ -n "$player" ]; then
    for type in video/mp4 video/x-matroska video/webm video/avi video/x-msvideo; do
      xdg-mime default "$player" "$type"
    done
    zenity --info --text="Reproductor '$player' establecido para vídeos"
  fi
}

# Ejecutar menú principal
main_menu
