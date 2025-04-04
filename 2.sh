mkt() {
    # ---- Configuración mejorada de colores ----
    local RED='\033[1;31m' GREEN='\033[1;32m' YELLOW='\033[1;33m'
    local BLUE='\033[1;34m' PURPLE='\033[1;35m' CYAN='\033[1;36m'
    local WHITE='\033[1;37m' NC='\033[0m'
    
    # ---- Variables configurables ----
    local DEFAULT_DIRS=("content" "scripts" "data" "logs" "exploits" "reports")
    local NMAP_CMD="nmap -sV -T4 --open"  # Comando nmap por defecto

    # ---- Mostrar arte ASCII con animación ----
    echo -ne "${PURPLE}"
    while IFS= read -r line; do
        echo "$line"
        sleep 0.01  # Pequeña animación
    done << "EOF"
  ___  _____  _____ 
 / _ \|_   _|/ __  \
| | | | | |   `' / /'
| | | | | |     / /  
| |_| |_| |_  ./ /___
 \___/ \___/  \_____/
EOF
    echo -e "${NC}"

    # ---- Verificar dependencias ----
    local missing_deps=()
    ! command -v nmap &>/dev/null && missing_deps+=("nmap")
    ! command -v xterm &>/dev/null && missing_deps+=("xterm")
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}⚠️ Dependencias faltantes:${NC} ${missing_deps[*]}"
        read -rp "¿Instalar ahora? [y/N] " install_choice
        if [[ "$install_choice" =~ [yY] ]]; then
            sudo apt update && sudo apt install -y "${missing_deps[@]}"
        fi
    fi

    # ---- Directorios personalizables ----
    local dirs=("${DEFAULT_DIRS[@]}")
    if [ $# -gt 0 ]; then
        dirs=("$@")  # Usar directorios proporcionados como argumentos
    fi

    # ---- Crear directorios con verificación ----
    echo -e "${BLUE}🚀 Creando estructura de directorios...${NC}\n"
    local created=0 exists=0
    
    for dir in "${dirs[@]}"; do
        if mkdir -p "$dir"; then
            if [ -d "$dir" ]; then
                echo -e "${GREEN}  ✅ ${WHITE}${dir}${GREEN} creado exitosamente.${NC}"
                ((created++))
            fi
        else
            echo -e "${RED}  ❌ Error al crear ${dir}${NC}"
        fi
    done

    # ---- Ejecutar herramientas de pentesting ----
    echo -e "\n${CYAN}🔍 Iniciando herramientas...${NC}"
    
    # Nmap en xterm con menú interactivo
    if command -v xterm &>/dev/null && command -v nmap &>/dev/null; then
        xterm -hold -e "bash -c 'echo -e \"${PURPLE}Menú Nmap:\n1) Escaneo rápido\n2) Escaneo completo\n3) Personalizado\n${NC}\"; \
        read -p \"Seleccione opción [1-3]: \" opt; \
        case \$opt in \
            1) cmd=\"nmap -T4 -F\" ;; \
            2) cmd=\"nmap -sV -A -T4\" ;; \
            3) read -p \"Ingrese comando nmap: \" cmd ;; \
            *) cmd=\"$NMAP_CMD\" ;; \
        esac; \
        echo -e \"\n${GREEN}Ejecutando: \$cmd${NC}\"; eval \$cmd; bash'" &
    fi

    # ---- Estadísticas finales ----
    echo -e "\n${YELLOW}📊 Resumen:${NC}"
    echo -e "  ${GREEN}${created}${NC} directorios creados"
    echo -e "  ${YELLOW}$((${#dirs[@]} - created))${NC} ya existían"
    echo -e "\n${CYAN}🕒 Tiempo de ejecución: ${WHITE}$SECONDS segundos${NC}"
    echo -e "${PURPLE}=============================================${NC}"
}
