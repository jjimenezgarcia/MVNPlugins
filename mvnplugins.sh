#!/bin/bash

# Parsea el directorio como un argumento o utiliza el directorio actual si no se proporciona un argumento.
directory="${1:-.}"

# Verifica que el directorio exista
if [ ! -d "$directory" ]; then
    echo "El directorio especificado no existe: $directory"
    exit 1
fi

# Colores
RED='\033[1;91m'
GREEN='\033[1;92m'
NC='\033[0m'  # Sin color

# Verifica si existen los directorios 'target' en el directorio especificado
if [ -d "$directory/target" ]; then

    # Ejecuta el comando de Maven para Checkstyle y verifica la salida en la consola
    checkstyle_output=$(mvn -f "$directory/pom.xml" clean checkstyle:checkstyle 2>&1)

    # Verifica si la salida de Checkstyle contiene la cadena [WARN]
    if echo "$checkstyle_output" | grep -q '\[WARN\]'; then
        echo -e "${RED}Errores en el build de Checkstyle.${NC}"
        echo "$checkstyle_output" | grep -E '^\[WARN\]'
    else
        echo -e "${GREEN}Build de Checkstyle completado sin errores.${NC}"
    fi
    mvn -f "$directory/pom.xml" clean pmd:pmd > /dev/null 2>&1
    pmd_exit_code=$?
    
    # PMD
    echo -e "${GREEN}Archivo PMD.${NC}"
    batcat "$directory/target/pmd.xml"

    mvn -f "$directory/pom.xml" clean spotbugs:check > /dev/null 2>&1
    spotbugs_exit_code=$?
    
    # Informa sobre el resultado del comando SpotBugs
    if [ $spotbugs_exit_code -ne 0 ]; then
        echo -e "${RED}Errores en el build de SpotBugs.${NC}"
    else
        echo -e "${GREEN}Build de SpotBugs completado sin errores.${NC}"
    fi
    
    mvn -f "$directory/pom.xml" clean javadoc:javadoc > /dev/null 2>&1
    javadoc_exit_code=$?

    # Informa sobre el resultado del comando Javadoc
    if [ $javadoc_exit_code -ne 0 ]; then
        echo -e "${RED}Errores en el build de Javadoc.${NC}"
    else
        echo -e "${GREEN}Build de Javadoc completado sin errores.${NC}"
    fi

else
    echo "No existe pom.xml en $directory."
fi
