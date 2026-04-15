#!/bin/bash

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

finish() {
    echo -e "\n${BLUE}===========================================${NC}"
    read -p "Presiona Enter para cerrar esta ventana..."
    exit
}

echo -e "${BLUE}=== Iniciando Despliegue de Banking System ===${NC}"

# 1. Validar archivos
if [ ! -f "compose.yml" ] && [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}Error: No se encontró compose.yml${NC}"
    finish
fi

# 2. Actualizar/Clonar Repositorios
for repo in "banking-management" "test.frontend"; do
    if [ -d "$repo" ]; then
        echo -e "${GREEN}Actualizando $repo...${NC}"
        (cd "$repo" && git pull) || echo -e "${RED}Aviso: No se pudo actualizar $repo${NC}"
    else
        echo -e "${GREEN}Clonando $repo...${NC}"
        git clone "https://github.com/Cyborgk27/$repo.git" || { echo -e "${RED}Error fatal clonando $repo${NC}"; finish; }
    fi
done

# 3. Levantamiento selectivo (Ignorando dependencias por completo)
echo -e "${BLUE}=== Levantando Backend y Frontend (Ignorando dependencias de DB) ===${NC}"

# --no-deps: Evita que Docker intente levantar o revisar el servicio 'db'
# --no-recreate: Si ya están arriba, no los toca
if ! docker compose up --build -d --no-deps backend frontend; then
    echo -e "${RED}Error: Falló el despliegue selectivo.${NC}"
    finish
fi

echo -e "${GREEN}=== Despliegue Finalizado ===${NC}"
echo -e "Frontend: http://localhost:80"
echo -e "Backend:  http://localhost:8080"
echo -e "Estado de la DB: Manteniendo contenedor existente."

finish