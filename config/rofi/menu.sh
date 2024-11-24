#!/bin/sh

if [ -z "$1" ]; then
    #########################################################
    ###################### CONFIG ###########################
    #########################################################
    # Diretórios de ícones
    icon_dirs="
    /usr/share/icons/hicolor
    /usr/share/icons/Adwaita
    /usr/share/pixmaps
    $HOME/.local/share/icons
    $HOME/.icons
    /var/lib/flatpak/exports/share/icons
    $HOME/.local/share/flatpak/exports/share/icons
    "

    # Nome do ícone de fallback
    fallback_icon_name="application-x-executable"

    # Arquivo temporário para cache
    cache_file="/tmp/icon_cache.txt"

    #########################################################
    ###################### RUNTIME ##########################
    #########################################################
    # Define o ícone padrão para fallback
    fallback_icon=""
    for dir in $icon_dirs; do
    fallback_icon=$(find "$dir" -type f -name "${fallback_icon_name}*" 2>/dev/null | head -n 1)
    [ -n "$fallback_icon" ] && break
    done

    # Função para buscar ícones
    find_icon() {
        local icon=""
        local class=$1

        # Verifica se o ícone já está no cache e se o arquivo existe. Caso o ícone esteja no cache mas o arquivo não existe mais, remove a entrada inválida e continua o script.
        if grep -q "^$class|" "$cache_file"; then
            icon=$(grep "^$class|" "$cache_file" | cut -d'|' -f2)
            if [[ -f "$icon" ]]; then
            echo "$icon"
            return
            else
            sed -i "/^$class|/d" "$cache_file"
            fi
        fi
        
        icon=""

        # Gerar os diretórios montados dinamicamente
        mount_dirs=$(echo /tmp/.mount_*/usr/share/icons)

        # Atualizar a variável icon_dirs
        icon_dirs="$icon_dirs
        $mount_dirs"

        # Tentar encontrar ícone nos diretórios especificados
        for dir in $icon_dirs; do
            icon=$(find "$dir" -iname "*${class,,}*" 2>/dev/null | head -n 1)
            [ -n "$icon" ] && break
        done

        # Se nenhum ícone for encontrado, tentar buscar em arquivos .desktop
        if [ -z "$icon" ]; then
            desktop_file=$(find /usr/share/applications $HOME/.local/share/applications \
            /var/lib/flatpak/exports/share/applications $HOME/.local/share/flatpak/exports/share/applications \
            -type f -name "${class,,}*.desktop" 2>/dev/null | head -n 1)

            if [ -n "$desktop_file" ]; then
            icon=$(grep -E '^Icon=' "$desktop_file" | head -n 1 | cut -d'=' -f2)
            # Tentar localizar o arquivo real do ícone, caso seja referenciado apenas pelo nome
            if [ -n "$icon" ] && [ ! -f "$icon" ]; then
                for dir in $icon_dirs; do
                found_icon=$(find "$dir" -type f -iname "${icon,,}*" 2>/dev/null | head -n 1)
                if [[ -n "$found_icon" ]]; then
                    icon=$found_icon
                    break
                fi
                done
            fi
            fi
        fi

        # Salva no cache
        echo "$class|$icon" >> "$cache_file"

        echo "$icon"
    }

    # Inicializa a string de retorno
    return=""

    # Obtém os aplicativos em execução no Hyprland (saída JSON)
    running_applications=$(hyprctl clients -j)

    # Verifica se o comando foi bem-sucedido
    if [ $? -ne 0 ]; then
        exit 1
    fi

    # Itera sobre cada cliente na saída JSON e constrói a variável `return`
    return=$(echo "$running_applications" | jq -c '.[]' | while read -r client; do
        # Extrai o título e a classe do aplicativo
        app_name=$(echo "$client" | jq -r '.title')
        app_class=$(echo "$client" | jq -r '.class')
        app_workspace=$(echo "$client" | jq -r '.workspace.name')
        app_icon=$(find_icon $app_class)
        
        # Formata o retorno no formato esperado pelo rofi
        echo "  [${app_workspace}] ${app_name}\0icon\x1f${app_icon}\n"
    done)

    # Passa os aplicativos formatados para o rofi
    echo -en "$return"
else
    window_title=$(echo "$1" | sed 's/^  \[[0-9]*\] //')
    window_address=$(hyprctl clients -j | jq -r --arg title "$window_title" '.[] | select(.title == $title) | .address')

    hyprctl dispatch focuswindow "address:$window_address" > /dev/null 2>&1
fi