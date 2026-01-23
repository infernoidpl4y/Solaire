#!/bin/bash

set -e

#Encontrar solaire.pl
ruta=$(find / -name "solaire.pl" 2>/dev/null | head -1)
VERSION=$($ruta -v)

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
 ______   ______   __       ________    ________  ______    ______      
/_____/\ /_____/\ /_/\     /_______/\  /_______/\/_____/\  /_____/\     
\::::_\/_\:::_ \ \\:\ \    \::: _  \ \ \__.::._\/\:::_ \ \ \::::_\/_    
 \:\/___/\\:\ \ \ \\:\ \    \::(_)  \ \   \::\ \  \:(_) ) )_\:\/___/\   
  \_::._\:\\:\ \ \ \\:\ \____\:: __  \ \  _\::\ \__\: __ `\ \\::___\/_  
    /____\:\\:\_\ \ \\:\/___/\\:.\ \  \ \/__\::\__/\\ \ `\ \ \\:\____/\ 
    \_____\/ \_____\/ \_____\/ \__\/\__\/\________\/ \_\/ \_\/ \_____\/ 
                                                                        
EOF
echo -e "${NC}"
echo "Instalador de $VERSION"
echo "=========================="
echo ""
    

# Función para error
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Función para éxito
success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Verificar Perl
check_perl() {
    if command -v perl >/dev/null 2>&1; then
        PERL_VERSION=$(perl -e 'print $^V' 2>/dev/null || echo "5.x")
        success "Perl encontrado ($PERL_VERSION)"
        return 0
    else
        echo -e "${YELLOW}[!]${NC} Perl no encontrado"
        return 1
    fi
}

# Detectar gestor de paquetes
detect_pkg_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    elif command -v apk >/dev/null 2>&1; then
        echo "apk"
    else
        error "No se pudo detectar gestor de paquetes"
    fi
}

# Instalar Perl
install_perl() {
    local pkg_manager=$1
    
    echo -e "${YELLOW}[!]${NC} Instalando Perl..."
    
    case $pkg_manager in
        apt)
            sudo apt-get update && sudo apt-get install -y perl
            ;;
        dnf|yum)
            sudo $pkg_manager install -y perl
            ;;
        pacman)
            sudo pacman -Sy --noconfirm perl
            ;;
        zypper)
            sudo zypper refresh && sudo zypper install -y perl
            ;;
        apk)
            doas apk add perl
            ;;
    esac
    
    if ! check_perl; then
        error "Falló la instalación de Perl"
    fi
}
# Crear enlace simbólico
create_link() {
    local script_path="$PWD/solaire.pl"
    
    if [ ! -f "$script_path" ]; then
        error "No se encontró solaire.pl en el directorio actual"
    fi
    
    # Hacer ejecutable
    chmod +x "$script_path"
    success "Permisos de ejecución asignados a solaire.pl"
    
    # Crear enlace en /usr/local/bin
    if command -v sudo >/dev/null 2>&1; then
		sudo ln -s "$ruta" /usr/local/bin/solaire
	elif command -v doas >/dev/null 2>&1; then
		doas ln -s "$ruta" /usr/local/bin/solaire
	elif command -v pkexec >/dev/null 2>&1; then
		pkexec ln -s "$ruta" /usr/local/bin/solaire
	elif [ "$(id -u)" -eq 0 ]; then
		ln -s "$ruta" /usr/local/bin/solaire
	else
		echo "su -c"
	fi
    # Verificar
    if [ -L "/usr/local/bin/solaire" ]; then
        success "Enlace creado: solaire → $script_path"
    else
        error "No se pudo crear el enlace"
    fi
}

# Verificar PATH
check_path() {
    if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
        echo -e "${YELLOW}[!]${NC} /usr/local/bin no está en PATH"
        echo "   Agrega esto a tu ~/.bashrc o ~/.zshrc:"
        echo '   export PATH="$PATH:/usr/local/bin"'
        echo ""
    fi
}

# Instalación principal
main() {
    echo "1. Verificando Perl..."
    if ! check_perl; then
        echo "2. Detectando gestor de paquetes..."
        PKG_MAN=$(detect_pkg_manager)
        echo "   Usando: $PKG_MAN"
        install_perl "$PKG_MAN"
    fi
    
    echo "3. Creando enlace simbólico..."
    create_link
    
    echo "4. Verificando PATH..."
    check_path
    
    echo ""
    echo -e "${GREEN}Instalación completada!${NC}"
    echo "Usa: solaire [archivo.slr]"
    echo "Ejemplo: echo 'print \"Hola\"' > test.slr && solaire test.slr"
}

# Ejecutar
main "$@"
