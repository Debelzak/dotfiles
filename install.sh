#!/bin/bash
no_prompt=0

echo -e 'Acesso root necessário para instalar os pacotes.'
sudo clear

for param in "$@"; do
    echo ${param};
    if [ "${param}" == "--no-prompt" ]; then
        no_prompt=1
    fi
done

cleanup() {
    echo -en "\r\033[KFinalizando script..."
    echo -e "\033[?25h"  # Restaura o cursor
}
trap cleanup EXIT

# Esconde o cursor
echo -e "\033[?25l"
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
############ Util functions ###########
#######################################
message() {
    message_type=$1
    message_text=$2
    if [ "${message_type}" == "error" ]; then
         echo -e "[\033[0;31mFAILED\033[0m] $message_text"
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
    loading_animation="[    ]"

    loading_animation() {
        local delay=0.25
        local count=0
        local max_dots=3

        while true; do
            case $count in
                0) echo -n "[      ] $message_text" ;;
                1) echo -n "[ .    ] $message_text" ;;
                2) echo -n "[ ..   ] $message_text" ;;
                3) echo -n "[ ...  ] $message_text" ;;
                4) echo -n "[ .... ] $message_text" ;;
                *) count=-1 ;;
            esac

            sleep $delay
            count=$((count + 1))
            printf "\r"
        done
    }

    # Inicia a animação em segundo plano
    loading_animation &
    animation_pid=$!

    # Executa o comando
    eval $command >> $script_dir/install.log 2>&1
    command_status=$?

    # Encerra a animação
    kill $animation_pid
    wait $animation_pid 2>/dev/null

    if [ $command_status -eq 0 ]; then
        echo -e "\r[  \033[0;32mOK\033[0m  ] $message_text"
    else
        echo -e "\r[\033[0;31mFAILED\033[0m] $message_text"
        message "error" "[FAILED] A instalação não pôde ser finalizada. Confira o arquivo install.log para mais detalhes."
        echo -e "\033[?25h"
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

# Reset logo file
echo "" > $script_dir/install.log

## Prompt
if [ "${no_prompt}" != 1 ]; then
    message "info" "Os arquivos de configurações serão instalados utilizando este diretório: $script_dir. Após a conclusão, não será possível mover o diretório para outra localização."
    prompt "Deseja continuar? [Y/n]: "
    read continue
    if [ "$continue" == "n" ]; then
        exit 0;
    fi
fi

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

        status_message "Configurando ${FUNCNAME[1]}..." "rm -rf '$target'; ln -sf '$source' '$target'"
    else
        message "error" "Configurações do alvo ${FUNCNAME[1]} não foram encontradas! [$source]"
        message "error" "Finalizando script."
        exit 1
    fi
}

install_packages_arch() {
    status_message "Updating mirrorlist..." "sudo pacman -Syy"

    # Lista de pacotes a serem instalados
    packages=(
        xorg
        xorg-xinit
        xdotool
        i3-wm
        alacritty
        picom
        nitrogen
        cargo-nightly           #eww compile requirement
        gtk3 gtk-layer-shell    #eww requirement
        rofi
        dunst
        ttf-font-awesome
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
        status_message "Installing package ${package}..." "sudo pacman -Sq --noconfirm $package"
    done

    message "ok" "All packages installed successfully!"
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

    cmd="cargo build --release --no-default-features --features=x11"
    status_message "Compilando pacote EWW... Isso pode demorar um pouco." "$cmd"

    cmd="sudo install -vDm755 target/release/eww -t '/usr/bin/'"
    status_message "Instalando pacote EWW..." "$cmd"

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


##### Tasks
install_packages_arch
user_dirs
xinit
Alacritty
i3wm
picom
eww
rofi

message "ok" "Instalação finalizada com sucesso!"