#!/usr/bin/env bash
# ============================================================
#  install.sh — развёртывание конфигов Hyprland/Waybar/Alacritty
#
#  НАЗНАЧЕНИЕ: создаёт симлинки из ./config/* в ~/.config/
#  ЗАПУСК (только в Linux!):  bash install.sh
#
#  ВАЖНО: папка называется `config` БЕЗ точки, чтобы её было
#  удобно перетаскивать в браузер на Windows. Симлинки ниже
#  создаются на абсолютные пути, поэтому имя папки не важно.
# ============================================================

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SRC_DIR="$REPO_DIR/config"
DST_DIR="$HOME/.config"

echo ""
echo "======================================================"
echo "  Hyprland dotfiles — установка"
echo "  Репозиторий: $REPO_DIR"
echo "======================================================"

# ------------------------------------------------------------
# 0. Если репозиторий лежит во временной папке (/tmp — случай
#    распаковки ZIP), переносим его в ~/.dotfiles, чтобы
#    абсолютные симлинки не сломались после перезагрузки.
# ------------------------------------------------------------
TARGET_REPO="$HOME/.dotfiles"
if [ "$REPO_DIR" != "$TARGET_REPO" ]; then
    case "$REPO_DIR" in
        /tmp/*|/var/tmp/*)
            echo ""
            echo "==> [0/4] Репозиторий во временной папке — переношу в $TARGET_REPO ..."
            if [ -e "$TARGET_REPO" ] || [ -L "$TARGET_REPO" ]; then
                OLD="${TARGET_REPO}.bak.$(date +%Y%m%d-%H%M%S)"
                mv -f "$TARGET_REPO" "$OLD"
                echo "    старый $TARGET_REPO -> $OLD"
            fi
            cp -a "$REPO_DIR" "$TARGET_REPO"
            REPO_DIR="$TARGET_REPO"
            SRC_DIR="$REPO_DIR/config"
            ;;
        *)
            echo "    Репозиторий в постоянной папке — используем как есть."
            ;;
    esac
fi

# ------------------------------------------------------------
# 1. Чистка Windows-переносов строк (CRLF -> LF) во всех файлах
# ------------------------------------------------------------
echo ""
echo "==> [1/4] Чистка Windows-переносов строк (CRLF -> LF) ..."
if command -v sed >/dev/null 2>&1 && command -v find >/dev/null 2>&1; then
    find "$REPO_DIR" -type f \( \
        -name '*.conf' -o -name '*.sh' -o -name '*.jsonc' -o \
        -name '*.css' -o -name '*.toml' -o -name '*.md' -o \
        -name '.gitignore' \) \
        -exec sed -i 's/\r$//' {} +
    echo "    OK: все текстовые файлы переведены на LF."
else
    echo "    [!] sed/find не найдены — пропускаю (не критично)."
fi

# ------------------------------------------------------------
# 2. Проверка установленных программ
# ------------------------------------------------------------
echo ""
echo "==> [2/4] Проверка зависимостей ..."
MISSING=0
for bin in hyprland alacritty waybar rofi dunst wl-copy cliphist grim slurp swaybg hyprpolkitagent wpctl; do
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "    [!] $bin не найден в PATH"
        MISSING=1
    fi
done
if [ "$MISSING" -eq 0 ]; then
    echo "    OK: все зависимости на месте."
fi

# ------------------------------------------------------------
# 3. Бэкап существующих конфигов в ~/.config/*.bak
# ------------------------------------------------------------
echo ""
echo "==> [3/4] Бэкап существующих конфигов ..."
backup_dir() {
    local name="$1"
    local dir="$DST_DIR/$name"
    if [ -e "$dir" ] || [ -L "$dir" ]; then
        local bak="${dir}.bak"
        # если .bak уже существует — сдвигаем его с датой
        if [ -e "$bak" ] || [ -L "$bak" ]; then
            local old="${bak}.$(date +%Y%m%d-%H%M%S)"
            mv -f "$bak" "$old"
            echo "    старый бэкап сдвинут: $old"
        fi
        mv -f "$dir" "$bak"
        echo "    $dir -> $bak"
    fi
}
backup_dir hypr
backup_dir waybar
backup_dir alacritty
mkdir -p "$DST_DIR"

# ------------------------------------------------------------
# 4. Симлинки на абсолютные пути
# ------------------------------------------------------------
echo ""
echo "==> [4/4] Создание симлинков в ~/.config ..."
for name in hypr waybar alacritty; do
    src="$SRC_DIR/$name"
    dst="$DST_DIR/$name"
    if [ ! -d "$src" ]; then
        echo "    [!] Не найден источник: $src"
        exit 1
    fi
    ln -sfn "$src" "$dst"
    echo "    $dst -> $src"
done

chmod +x "$REPO_DIR/install.sh" 2>/dev/null || true

echo ""
echo "======================================================"
echo "  Готово! Дальнейшие шаги:"
echo "  1. Перезайдите в сессию Hyprland или выполните:"
echo "       hyprctl reload"
echo "  2. Обои: положите картинку в"
echo "       ~/.config/hypr/background.jpg"
echo "  3. Waybar перечитает конфиг после перезапуска:"
echo "       pkill waybar; waybar &"
echo "  ВАЖНО: симлинки абсолютные. Если перенесёте папку"
echo "  с конфигами — запустите install.sh заново."
echo "======================================================"
