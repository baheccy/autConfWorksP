#!/usr/bin/zsh

# Definiciones de colores ANSI
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
BLUE=$'\e[34m'
RESET=$'\e[0m'

# Lista de paquetes y componentes
paquetes=(
    fish bspwm polybar picom kitty vlc tmux
    rofi sxhkd ranger cava unrar feh btop
    git wget xorg vlc-plugin-access-extra fortune cowsay
    translate-shell vim neovim
)

# Variables de configuración
log_file="install.log"
fastfetch_url="https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb"

# Variables globales
typeset -gA instalados=()

# Funciones
ejecutar_comando() {
    local cmd=$1
    local guardar_log=${2:-true}

    if [[ $guardar_log == true ]]; then
        cmd+=" >> $log_file 2>&1"
    fi

    sh -c "$cmd"
    return $?
}

obtener_paquetes_instalados() {
    instalados=()
    while IFS= read -r pkg; do
        instalados[$pkg]=1
    done < <(dpkg-query -W -f '${Package}\n' 2>/dev/null)
}

verificar_instalaciones() {
    obtener_paquetes_instalados
    print "${YELLOW}\nVerificando paquetes:\n${RESET}"

    local max_length=0
    for p in "${paquetes[@]}"; do
        (( ${#p} > max_length )) && max_length=${#p}
    done

    local contador=1
    for p in "${paquetes[@]}"; do
        local existe=${+instalados[$p]}
        local color=$GREEN
        local estado="[INSTALADO]"
        (( !existe )) && { color=$RED; estado="[FALTANTE ]" }
        printf "${YELLOW}%2d: %-*s ${color}%s${RESET}\n" $contador $((max_length + 2)) "$p" "$estado"
        ((contador++))
    done
}

actualizar_sistema() {
    print "${BLUE}\nActualizando repositorios...\n${RESET}"
    ejecutar_comando "apt update" || {
        print "${RED}Error actualizando repositorios\n${RESET}"
        return 1
    }
    
    print "${BLUE}Actualizando paquetes...\n${RESET}"
    ejecutar_comando "apt upgrade -y" || print "${RED}Error actualizando paquetes\n${RESET}"
}

instalar_paquetes() {
    obtener_paquetes_instalados
    local faltantes=()

    for p in "${paquetes[@]}"; do
        (( ! ${+instalados[$p]} )) && faltantes+=($p)
    done

    if (( ${#faltantes[@]} > 0 )); then
        print "${YELLOW}\nInstalando paquetes faltantes...\n${RESET}"
        local cmd="apt install -y ${faltantes[@]}"
        ejecutar_comando "$cmd" || {
            print "${RED}Error instalando paquetes\n${RESET}"
            return 1
        }
    else
        print "${GREEN}\nTodos los paquetes ya están instalados\n${RESET}"
    fi

    instalar_ohmyzsh
    instalar_powerlevel10k
    instalar_fastfetch
}

instalar_ohmyzsh() {
    local ohmyzsh_path="$HOME/.oh-my-zsh"

    [[ -d $ohmyzsh_path ]] && {
        print "${GREEN}\nOh My Zsh ya está instalado\n${RESET}"
        return
    }

    print "${YELLOW}\nInstalando Oh My Zsh...\n${RESET}"
    local cmd='sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    ejecutar_comando "$cmd" false || print "${RED}Error instalando Oh My Zsh\n${RESET}"
}

instalar_powerlevel10k() {
    local p10k_path="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

    [[ -d $p10k_path ]] && {
        print "${GREEN}\nPowerlevel10k ya está instalado\n${RESET}"
        return
    }

    print "${YELLOW}\nInstalando Powerlevel10k...\n${RESET}"
    local cmd="git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $p10k_path"
    ejecutar_comando "$cmd" && {
        sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
    } || print "${RED}Error instalando Powerlevel10k\n${RESET}"
}

instalar_fastfetch() {
    ejecutar_comando "command -v fastfetch" && {
        print "${GREEN}\nFastFetch ya está instalado\n${RESET}"
        return
    }

    print "${YELLOW}\nInstalando FastFetch...\n${RESET}"
    ejecutar_comando "curl -LO $fastfetch_url" && \
    ejecutar_comando "dpkg -i fastfetch-linux-amd64.deb" && \
    ejecutar_comando "rm fastfetch-linux-amd64.deb" && {
        print "${GREEN}FastFetch instalado correctamente\n${RESET}"
    } || print "${RED}Error instalando FastFetch\n${RESET}"
}

instalar_controladores_nvidia() {
    print "${YELLOW}\nInstalando controladores Nvidia...\n${RESET}"
    ejecutar_comando "apt install -y nvidia-driver" || print "${RED}Error instalando controladores\n${RESET}"
}

limpiar_log() {
    rm -f "$log_file" && print "${GREEN}Log de instalación limpiado\n${RESET}" || print "${RED}Error limpiando log\n${RESET}"
}

limpiar_pantalla() {
    print -n "\033[H\033[J"
}

mostrar_menu() {
    local opcion
    while true; do
        limpiar_pantalla
        print "${RED}\n*** Sistema Debian Config Tool ***\n${RESET}"
        print "${YELLOW}1. Verificar paquetes"
        print "2. Instalar paquetes y componentes"
        print "3. Instalar controladores Nvidia"
        print "4. Limpiar log de instalación"
        print "0. Salir"
        print -n "Opción: ${RESET}"

        read opcion || { opcion=invalid; }

        if [[ ! $opcion =~ ^[0-9]+$ ]]; then
            print "${RED}\nEntrada inválida\n${RESET}"
            printf "${YELLOW}Presione Enter para continuar...${RESET}"
            read -k1
            continue
        fi

        limpiar_pantalla

        case $opcion in
            1) verificar_instalaciones ;;
            2) instalar_paquetes ;;
            3) instalar_controladores_nvidia ;;
            4) limpiar_log ;;
            0) print "${GREEN}\nSaliendo...\n${RESET}"; exit 0 ;;
            *) print "${RED}\nOpción no válida\n${RESET}" ;;
        esac

        [[ $opcion != 0 ]] && {
            printf "${YELLOW}\nPresione Enter para continuar...${RESET}"
            read -k1
        }
    done
}

# Verificar si se ejecuta como root
[[ $EUID -ne 0 ]] && {
    print "${RED}Ejecutar como root: sudo $0\n${RESET}"
    exit 1
}

limpiar_pantalla
mostrar_menu