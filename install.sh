#!/bin/sh
no_prompt=0

for param in "$@"; do
    if [ "${param}" == "--no-prompt" ]; then
        no_prompt=1
    fi
done

# Get sudo
echo -e 'Acesso root necessário para instalar os pacotes.'
sudo clear

echo -e "
  _____        _    __ _ _           
 |  __ \      | |  / _(_) |          
 | |  | | ___ | |_| |_ _| | ___  ___ 
 | |  | |/ _ \| __|  _| | |/ _ \/ __|
 | |__| | (_) | |_| | | | |  __/\__ \\
 |_____/ \___/ \__|_| |_|_|\___||___/
                                     
            By Debelzak
"

#######################################
############ Helper functions #########
#######################################
message() {
    message_type=$1
    message_text=$2
    if [ "${message_type}" == "error" ]; then
         echo -e "[\033[0;31mFALHOU\033[0m] $message_text"
    elif [ "${message_type}" == "ok" ]; then
         echo -e "[  \033[0;32mOK\033[0m  ] $message_text"
    elif [ "${message_type}" == "info" ]; then
         echo -e "[ \033[0;33mINFO\033[0m ] $message_text"
    else
         echo -e "${message_text}"
    fi
}

status_message() {
    message_text=$1
    command=$2

    message_length=${#message_text}
    loading_animation="[      ]"

    loading_animation() {
        local count=0

        while true; do
            case $count in
                0) echo -n "[      ] $message_text" ;;
                1) echo -n "[ .    ] $message_text" ;;
                2) echo -n "[ ..   ] $message_text" ;;
                3) echo -n "[ ...  ] $message_text" ;;
                4) echo -n "[ .... ] $message_text" ;;
                *) count=-1 ;;
            esac

            sleep 0.25
            count=$((count + 1))
            printf "\r"
        done
    }

    # Esconde o cursor
    echo -en "\033[?25l"

    # Inicia a animação em segundo plano
    loading_animation &
    animation_pid=$!

    # Executa o comando
    eval "$command" >> $script_dir/install.log 2>&1
    command_status=$?

    # Encerra a animação
    kill $animation_pid
    wait $animation_pid 2>/dev/null

    # Restaura cursor
    echo -en "\033[?25h"

    if [ $command_status -eq 0 ]; then
        echo -e "\r[  \033[0;32mOK\033[0m  ] $message_text"
    else
        echo -e "\r[\033[0;31mFALHOU\033[0m] $message_text"
        message "error" "A instalação não pôde ser finalizada. Confira o arquivo [$script_dir/install.log] para mais detalhes."
        exit 1
    fi
}

prompt() {
    message_text=$1
    echo -en "\033[0;36m$message_text\033[0m"
}

#######################################
############ Actual script ############
#######################################
# Diretório atual do script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
distro_id="unknown"
distro_name="unknown"

detect_distro() {
    if [ ! -f /etc/os-release ]; then 
        echo -e "O arquivo /etc/os-release não está disponível. Não é possível determinar a distribuição Linux."
        return 1
    fi

    source /etc/os-release
    if [ -z "$ID" ]; then
        echo -e "Não foi possível determinar a distribuição Linux."
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

    echo -e "Você está usando uma distribuição incompatível com esse script: $distro_name" >> $script_dir/install.log

    return 1
}

check_internet_connection() {
    ping -c 1 google.com > /dev/null 2>&1 && return 0 || return 1;
}

install_packages_arch() {
    status_message "Atualizando mirrorlist..." "sudo pacman -Syy"

    # Lista de pacotes a serem instalados
    packages=(
        pkgconf                 #eww build
        gcc                     #eww build
        cargo-nightly           #eww build
        gtk3                    #eww runtime
        gtk-layer-shell         #eww runtime (wayland)
        xorg
        xorg-xinit
        xdotool
        i3-wm
        alacritty
        picom
        nitrogen
        git
        rofi
        dunst
        noto-fonts-cjk
        ttf-font-awesome
        ttf-meslo-nerd
        nodejs
        npm
        pavucontrol
        flameshot
        # arc-gtk-theme arc-icon-theme lxappearance
        # feh
        # mplayer
    )

    # Loop para instalar cada pacote
    for package in "${packages[@]}"; do
        status_message "Instalando pacote ${package}..." "sudo pacman -Sq --noconfirm $package"
    done

    message "ok" "Todos os pacotes foram instalados com sucesso!"
}

create_links() {
    # Diretório de destino para os links simbólicos
    source=$1
    target=$2

    if [ -e "$source" ]; then
        if [ -e "$target" ]; then
            ## Prompt
            if [ "${no_prompt}" != 1 ]; then
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

##### ~/
xinit() {
    source_file="$script_dir/xinitrc"
    target_file="$HOME/.xinitrc"

    create_links "$source_file" "$target_file"
}

##### ~/.config/
user_dirs() {
    source_file="$script_dir/config/user-dirs.dirs"
    target_file="$HOME/.config/user-dirs.dirs"

    create_links "$source_file" "$target_file"
}

Alacritty() {
    source_dir="$script_dir/config/alacritty"
    target_dir="$HOME/.config/alacritty"

    create_links "$source_dir" "$target_dir"
}

i3wm() {
    source_dir="$script_dir/config/i3"
    target_dir="$HOME/.config/i3"

    create_links "$source_dir" "$target_dir"
}

picom() {
    source_dir="$script_dir/config/picom"
    target_dir="$HOME/.config/picom"

    create_links "$source_dir" "$target_dir"
}

eww() {
    # build
    cd "$script_dir/eww/src"
    status_message "Compilando Elkowars Wacky Widgets (EWW)... Isso deve levar um tempo." "cargo build --release --no-default-features --features=x11"
    status_message "Instalando Elkowars Wacky Widgets (EWW)..." "sudo install -vDm755 target/release/eww -t '/usr/bin/'"
    cd "$script_dir"

    # setup links
    source_dir="$script_dir/config/eww"
    target_dir="$HOME/.config/eww"

    create_links "$source_dir" "$target_dir"
}

rofi() {
    source_dir="$script_dir/config/rofi"
    target_dir="$HOME/.config/rofi"

    create_links "$source_dir" "$target_dir"
}

nitrogen() {
    target_dir="$HOME/.config/nitrogen"
    status_message "Configurando papel de parede..." "mkdir -p '$target_dir'"
    echo "[xin_-1]"                             >  "$target_dir/bg-saved.cfg"
    echo "file=$script_dir/wallpaper/1.jpeg"    >> "$target_dir/bg-saved.cfg"
    echo "mode=4"                               >> "$target_dir/bg-saved.cfg"
    echo "bgcolor=#000000"                      >> "$target_dir/bg-saved.cfg"
}

##### Tasks
pre_install() {
    # Reset logo file
    echo "" > $script_dir/install.log

    ## Prompt
    message "info" "Os arquivos de configurações serão instalados utilizando este diretório: [$script_dir]. Após a conclusão, não será possível mover o diretório para outra localização."
    if [ "${no_prompt}" != 1 ]; then
        prompt "Deseja continuar? [Y/n]: "
        read continue
        if [ "$continue" == "n" ]; then
            exit 0;
        fi
    fi

    # Detect distro
    status_message "Detectando distribuição linux..." "detect_distro"
    status_message "Checando compatibilidade com distribuição..." "check_distro_compatibility"
    message "ok" "Você está usando uma distribuição compatível: $distro_name"

    # Check internet connection
    status_message "Checando conexão com a internet..." "check_internet_connection"

    if [ "$distro_id" = "arch" ]; then
        install_packages_arch
    fi

    # Fetch git submodules
    status_message "Inicializando submódulos git..." "git submodule init"
    status_message "Atualizando submódulos git..." "git submodule update"
}

install() {
    user_dirs
    xinit
    Alacritty
    i3wm
    picom
    eww
    rofi
    nitrogen
}

post_install() {
    message "ok" "Instalação finalizada com sucesso!"
}

pre_install
install
post_install
