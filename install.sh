#!/bin/sh
# Get params
yes_to_all=0
for param in "$@"; do
    if [ "${param}" == "-y" ]; then
        yes_to_all=1
    fi
done

# Get sudo
printf 'Acesso root necessário para instalar os pacotes.\n'
command -v sudo &> /dev/null
if [ ! $? -eq 0 ]; then
    printf "${RED}Um pacote necessário (sudo) não foi encontrado no sistema. Tente novamente após instalar o pacote.${NC}\n"
    exit 1
fi
sudo clear;

printf "
             Debelzak's
  _____        _    __ _ _           
 |  __ \      | |  / _(_) |          
 | |  | | ___ | |_| |_ _| | ___  ___ 
 | |  | |/ _ \| __|  _| | |/ _ \/ __|
 | |__| | (_) | |_| | | | |  __/\__ \\
 |_____/ \___/ \__|_| |_|_|\___||___/
                                     
\n"
#######################################
############ Helper functions #########
#######################################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color
HIDE_CURSOR='\033[?25l'
SHOW_CURSOR='\033[?25h'
message() {
    local message_type="$1"
    local message_text="$2"

    case "$message_type" in
        error)   printf "[${RED}FALHA!${NC}] %s\n" "$message_text" ;;
        success) printf "[  ${GREEN}OK${NC}  ] %s\n" "$message_text" ;;
        warning) printf "[ ${YELLOW}WARN${NC} ] %s\n" "$message_text" ;;
        *)       printf "%s\n" "$message_text" ;;
    esac
}

status_message() {
    local message_text="$1"
    local command="$2"

    message_length=${#message_text}
    loading_animation="[      ]"

    loading_animation() {
        local count=0

        while true; do
            case $count in
                0) printf "[ ${YELLOW}>${NC}    ] %s" "$message_text" ;;
                1) printf "[ ${YELLOW}>>${NC}   ] %s" "$message_text" ;;
                2) printf "[ ${YELLOW}>>>${NC}  ] %s" "$message_text" ;;
                3) printf "[ ${YELLOW}>>>>${NC} ] %s" "$message_text"; count=-1;;
            esac

            sleep 0.25
            count=$((count + 1))
            printf "\r"
        done
    }

    # Esconde o cursor
    printf "$HIDE_CURSOR"

    # Inicia a animação em segundo plano
    loading_animation &
    animation_pid=$!

    # Executa o comando
    eval "$command" >> $install_dir/install.log 2>&1
    command_status=$?

    # Encerra a animação
    kill $animation_pid
    wait $animation_pid 2>/dev/null

    # Restaura cursor
    printf "$SHOW_CURSOR"

    if [ $command_status -eq 0 ]; then
        printf "\r[  ${GREEN}OK${NC}  ] %s\n" "$message_text"
    else
        printf "\r[${RED}FALHA!${NC}] %s\n" "$message_text"
        message "error" "A instalação não pôde ser finalizada. Confira o arquivo [$install_dir/install.log] para mais detalhes."
        exit 1
    fi
}

prompt() {
    message_text=$1
    printf "${CYAN}$message_text${NC}"
}

#######################################
############ Actual script ############
#######################################
# Get install dir
install_dir="$HOME/dotfiles"
if [ "${yes_to_all}" != 1 ]; then
    prompt "Diretório de instalação: [$install_dir]: "

    read directory
    if [ -z "$directory" ]; then
        directory=$install_dir
    fi

    if mkdir -p "$directory" && touch "$directory/foo.test" 2> /dev/null; then
        rm "$directory/foo.test"
        message "success" "Diretório de instalação definido em [$directory]."
        install_dir="$directory"
    else
        message "error" "Você não possui permissões para escrever em [$directory]."
        exit 1
    fi
fi


# Diretório atual do script
distro_id="unknown"
distro_name="unknown"

detect_distro() {
    if [ ! -f /etc/os-release ]; then 
        printf "O arquivo /etc/os-release não está disponível. Não é possível determinar a distribuição Linux.\n"
        return 1
    fi

    source /etc/os-release
    if [ -z "$ID" ]; then
        printf "Não foi possível determinar a distribuição Linux.\n"
        return 1
    fi

    distro_id=$ID
    distro_name=$NAME

    return 0
}

check_distro_compatibility() {
    local compatible_distros=("arch")

    for comp_distro in "${compatible_distros[@]}"; do
        [ "$distro_id" = "$comp_distro" ] && return 0
    done

    printf "Você está usando uma distribuição incompatível com esse script: $distro_name\n"

    return 1
}

check_internet_connection() {
    ping -c 1 google.com > /dev/null 2>&1 && return 0 || return 1;
}

install_packages_arch() {
    status_message "Atualizando mirrorlist..." "sudo pacman -Syy"

    # Lista de pacotes a serem instalados
    packages=(
        polkit-gnome
        pkg-config              # eww build
        gcc                     # eww build
        cargo-nightly           # eww build
        libdbusmenu-gtk3        # eww build
        gtk3                    # eww runtime
        gtk-layer-shell         # eww runtime (wayland)
        socat                   # hyprland & eww req
        hyprland                # wayland wm
        hyprpaper               # wallpaper
        nwg-look                # wayland (?)
        mesa
        alacritty               # Terminal Emulator
        git                     # CORE
        rofi-wayland            # Launcher
        dunst                   # Notifications Popup
        noto-fonts              # Fonts
        noto-fonts-cjk          # Unicode font / Japanese
        ttf-vlgothic            # Unicode font / Japanese
        ttf-font-awesome        # Font Awesome
        nodejs                  # Eww Weather
        npm                     # Eww Weather
        pavucontrol             # Eww Sound
        alsa-utils              # Eww Sound
        flameshot               # Print Screen
        nautilus                # File explorer
        zsh                     # Shell
        jq                      # Json management
        gdm                     # Login screen
    )

    # Loop para instalar cada pacote
    for package in "${packages[@]}"; do
        status_message "Instalando pacote ${package}..." "sudo pacman -Sq --noconfirm $package"
    done

    message "success" "Todos os pacotes foram instalados com sucesso!"
}

create_links() {
    # Diretório de destino para os links simbólicos
    source=$1
    target=$2

    if [ -e "$source" ]; then
        if [ -e "$target" ]; then
            ## Prompt
            if [ "${yes_to_all}" != 1 ]; then
                prompt "Já existe uma configuração de ${FUNCNAME[1]} presente. Deseja substituir? [y/N]: "
                read replace
                if [ "${replace}" != "y" ]; then
                    return;
                fi
            fi
        fi

        directory=$(dirname $target)
        status_message "Configurando ${FUNCNAME[1]}..." "rm -rf '$target'; mkdir -p '$directory'; ln -sf '$source' '$target'"
    else
        message "error" "Configurações do alvo ${FUNCNAME[1]} não foram encontradas! [$source]"
        exit 1
    fi
}

##### Fonts
fonts() {
    #font_dir=/usr/share/fonts/TTF/
    font_dir=$HOME/.local/share/fonts/

    mkdir -p "$font_dir"
    status_message "Instalando fontes..." "cp -r '$install_dir/fonts/' '$font_dir'"
}

##### GTK3
gtk3() {
    source_dir="$install_dir/config/gtk-3.0"
    target_dir="$HOME/.config/gtk-3.0"

    create_links "$source_dir" "$target_dir"
}

##### Zsh
zsh() {
    source_dir="$install_dir/config/zsh"
    target_dir="$HOME/.local/share/zsh"

    create_links "$source_dir" "$target_dir"

    status_message "Configurando zsh como shell padrão..." "sudo usermod -s /bin/zsh $USER"
}

zshrc() {
    source_file="$install_dir/config/.zshrc"
    target_file="$HOME/.zshrc"
    
    create_links "$source_file" "$target_file"
}

##### ~/.config/
user_dirs() {
    source_file="$install_dir/config/user-dirs.dirs"
    target_file="$HOME/.config/user-dirs.dirs"

    create_links "$source_file" "$target_file"
}

alacritty() {
    source_dir="$install_dir/config/alacritty"
    target_dir="$HOME/.config/alacritty"

    create_links "$source_dir" "$target_dir"
}

hyprland() {
    source_dir="$install_dir/config/hypr"
    target_dir="$HOME/.config/hypr"

    create_links "$source_dir" "$target_dir"
}

wallpaper() {
    source_dir="$install_dir/wallpaper"
    target_dir="$HOME/Imagens/wallpaper"
    
    create_links "$source_dir" "$target_dir"
}

eww() {
    # build
    cd "$install_dir/eww/src"
    status_message "Compilando eww. Isso deve levar um tempo..." "cargo build --release --no-default-features --features=x11,wayland"
    status_message "Instalando eww..." "sudo install -vDm755 target/release/eww -t '/usr/bin/'"
    cd "$install_dir"

    # setup links
    source_dir="$install_dir/config/eww"
    target_dir="$HOME/.config/eww"

    create_links "$source_dir" "$target_dir"
}

rofi() {
    source_dir="$install_dir/config/rofi"
    target_dir="$HOME/.config/rofi"

    create_links "$source_dir" "$target_dir"
}

##### Tasks
pre_install() {
    # Create and enters diretory
    install_dir=$(readlink -f "$install_dir")
    mkdir -p $install_dir
    cd $install_dir

    # Format to full path
    install_dir=$(pwd)

    # Reset logo file
    echo "" > $install_dir/install.log

    ## Prompt
    message "warning" "Os arquivos de configurações serão instalados utilizando este diretório: [$install_dir]. Após a conclusão, não será possível mover o diretório para outra localização."
    if [ "${yes_to_all}" != 1 ]; then
        prompt "Deseja continuar? [Y/n]: "
        read continue
        if [ "$continue" == "n" ]; then
            exit 0;
        fi
    fi

    # Detect distro
    status_message "Detectando distribuição linux..." "detect_distro"
    status_message "Checando compatibilidade com distribuição..." "check_distro_compatibility"
    message "success" "Você está usando uma distribuição compatível: $distro_name"

    # Check internet connection
    status_message "Checando conexão com a internet..." "check_internet_connection"

    case $distro_id in
        arch)
            install_packages_arch
        ;;
    esac

    # Verify existing files...
    if [ ! -d "$install_dir/.git" ]; then
        status_message "Inicializando repositório..." "git init"
        status_message "Adicionando repositório remoto..." "git remote add origin https://github.com/debelzak/dotfiles.git"
        status_message "Baixando arquivos de repositório remoto..." "git fetch"
        status_message "Fazendo checkout para branch principal..." "git reset origin/main --hard"
    fi

    # Fetch git submodules
    status_message "Inicializando submódulos git..." "git submodule init"
    status_message "Atualizando submódulos git..." "git submodule update"
}

install() {
    fonts
    gtk3
    user_dirs
    alacritty
    hyprland
    wallpaper
    eww
    rofi
    zsh
    zshrc
}

post_install() {
    echo -e "${GREEN}Instalação realizada com sucesso!${NC}";
    echo -e "${GREEN}Inicialize a sessão com o comando: Hyprland${NC}";

    prompt "Iniciar interface gráfica automaticamente ao ligar o computador? [Y/n]: "
    read continue
    if [ "$continue" != "n" ]; then
        status_message "Habilitando serviço GDM..." "sudo systemctl enable gdm"
    fi
    
    prompt "Iniciar interface gráfica agora? [Y/n]: "
    read continue
    if [ "$continue" != "n" ]; then
        status_message "Inicializando serviço GDM..." "sudo systemctl restart gdm"
    fi
}

pre_install
install
post_install
