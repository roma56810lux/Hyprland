# Hyprland Dotfiles — EndeavourOS в VMware (3.8 ГБ ОЗУ)

Готовый набор конфигов **Hyprland + Waybar + Alacritty** для виртуальной машины
EndeavourOS (Arch Linux) под VMware Workstation/Player. Заточен под:

- драйвер `vmwgfx` (3D-ускорение) и автоматическую подстройку разрешения под окно VMware;
- скромные 3.8 ГБ ОЗУ — blur, тени и анимации отключены;
- управление строго с клавиатуры.

## Что уже настроено

| Область | Что сделано |
|---|---|
| VMware | `WLR_NO_HARDWARE_CURSORS=1` + `cursor { no_hardware_cursors = true }` (иначе курсор пропадает); `monitor=,preferred,auto,1`; автозапуск `vmware-user-suid-wrapper` для общего буфера обмена |
| ОЗУ | Отключены blur, тени, анимации, лого/сплэш-рендер Hyprland; `vfr = true` |
| Клавиатура | `us,ru` по `Alt+Shift`; repeat_rate 50 / delay 250; vim-навигация |
| Буфер обмена | История через `cliphist` + `rofi` |
| Скриншоты | `grim` + `slurp` (область → буфер/файл) |
| Панель | Waybar 26px: воркспейсы, заголовок окна, часы, раскладка, CPU, RAM, громкость, трей |
| Терминал | Alacritty, JetBrainsMono Nerd Font 11px, отступы 6px, тема Tokyo Night |

## Структура репозитория

```text
.
├── .gitignore
├── README.md
├── install.sh
└── config/                    # без точки — удобно перетаскивать в браузер
    ├── hypr/
    │   ├── hyprland.conf
    │   └── conf/
    │       ├── monitors.conf
    │       ├── env.conf
    │       ├── autostart.conf
    │       ├── look.conf
    │       ├── binds.conf
    │       └── rules.conf
    ├── waybar/
    │   ├── config.jsonc
    │   └── style.css
    └── alacritty/
        └── alacritty.toml
```

## Требования (ВМ)

```bash
sudo pacman -S --needed hyprland alacritty waybar rofi-wayland dunst \
  wl-clipboard cliphist grim slurp swaybg hyprpolkitagent wireplumber \
  open-vm-tools stow curl wget unzip ttf-jetbrains-mono-nerd
```

- `open-vm-tools` — общий буфер обмена с Windows 11.
- `ttf-jetbrains-mono-nerd` — иконки Waybar и шрифт Alacritty.

## Горячие клавиши

| Клавиши | Действие |
|---|---|
| `SUPER + Q` | Терминал Alacritty |
| `SUPER + R` | Меню приложений (rofi drun) |
| `SUPER + C` | Закрыть окно |
| `SUPER + F` | Полный экран |
| `SUPER + V` | Плавающее окно |
| `SUPER + H / J / K / L` | Фокус по vim-клавишам |
| `SUPER + Shift + H/J/K/L` | Перемещение окна |
| `SUPER + Ctrl + H/J/K/L` | Изменение размера окна |
| `SUPER + 1..9` | Воркспейс 1..9 |
| `SUPER + Shift + 1..9` | Отправить окно на воркспейс |
| `SUPER + ~` (grave) | Scratchpad |
| `SUPER + Shift + V` | История буфера (cliphist + rofi) |
| `SUPER + Shift + C` | Очистить историю буфера |
| `Print` | Скриншот области → буфер |
| `SUPER + Print` | Весь экран → буфер |
| `SUPER + Shift + S` | Скриншот области → файл |
| `Alt + Shift` | Смена раскладки us/ru |
| `XF86Audio*` | Громкость (wpctl) |

## Часть 1. Заливка на GitHub (Windows 11, браузер)

1. Откройте [github.com](https://github.com) и войдите в аккаунт.
2. Справа сверху нажмите `+` → **New repository**.
3. Имя, например `hypr-dotfiles`; выберите **Public**; обязательно поставьте
   галочку **Add a README file**; нажмите **Create repository**.
4. В репозитории нажмите **Add file → Upload files**.
5. Перетащите мышью папку `config` целиком и файл `install.sh`
   (по желанию также `README.md` и `.gitignore` — наш README просто
   заменит автоматический).
6. Внизу **Commit changes** → **Commit changes** (прямо в ветку `main`).
7. Проверьте, что в репозитории появились `config/` и `install.sh`.

## Часть 2. Развёртывание на ВМ (одна команда)

Замените `USERNAME` и `REPO` на свои значения и выполните:

```bash
cd /tmp && curl -L -o hypr-dotfiles.zip https://github.com/USERNAME/REPO/archive/refs/heads/main.zip && unzip -o hypr-dotfiles.zip -d hypr-dotfiles && bash hypr-dotfiles/REPO-main/install.sh
```

Через `wget`:

```bash
cd /tmp && wget -O hypr-dotfiles.zip https://github.com/USERNAME/REPO/archive/refs/heads/main.zip && unzip -o hypr-dotfiles.zip -d hypr-dotfiles && bash hypr-dotfiles/REPO-main/install.sh
```

Архив GitHub распаковывается в папку `REPO-main` (имя репозитория + `-main`).
Скрипт сам перенесёт конфиги из `/tmp` в `~/.dotfiles`, почистит Windows-переносы
строк (CRLF → LF), сделает бэкапы в `~/.config/*.bak` и создаст симлинки.

## После установки

- Перезайдите в сессию Hyprland или выполните `hyprctl reload`.
- Обои: положите картинку в `~/.config/hypr/background.jpg` (путь можно
  поменять в `config/hypr/conf/autostart.conf`).
- Панель: `pkill waybar; waybar &`.
- Если буфер обмена с Windows 11 не работает — проверьте, что пакет
  `open-vm-tools` установлен и служба `vmtoolsd` запущена.
