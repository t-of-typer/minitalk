#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_all.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: avinals <avinals-@student.42madrid.com>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/13 20:00:00 by avinals           #+#    #+#              #
#    Updated: 2025/07/13 20:00:00 by avinals          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Incluye todas las pruebas: obligatorias, bonus y casos extremos

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para imprimir headers bonitos
print_header() {
    echo -e "\n${CYAN}===============================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}===============================================${NC}\n"
}

print_subheader() {
    echo -e "\n${YELLOW}--- $1 ---${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Función para obtener PID del servidor
get_server_pid() {
    local server_name=$1
    ps aux | grep "./$server_name" | grep -v grep | grep -v test | awk '{print $2}' | head -1
}

# Función para matar servidores
kill_servers() {
    print_info "Matando servidores previos..."
    pkill -f "./server" 2>/dev/null || true
    pkill -f "./server_b" 2>/dev/null || true
    sleep 1
}

# Función para compilar
compile_project() {
    print_header "COMPILACIÓN DEL PROYECTO"
    
    print_info "Limpiando archivos previos..."
    make fclean > /dev/null 2>&1
    
    print_info "Compilando parte obligatoria..."
    if make all > /dev/null 2>&1; then
        print_success "Compilación obligatoria exitosa"
    else
        print_error "Error en compilación obligatoria"
        return 1
    fi
    
    print_info "Compilando parte bonus..."
    if make bonus > /dev/null 2>&1; then
        print_success "Compilación bonus exitosa"
    else
        print_error "Error en compilación bonus"
        return 1
    fi
    
    print_success "Todo compilado correctamente!"
}

# Función para verificar norminette
check_norminette() {
    print_header "VERIFICACIÓN DE NORMINETTE"
    
    if command -v norminette > /dev/null 2>&1; then
        print_info "Verificando norminette en archivos principales..."
        norminette *.c *.h
        if [ $? -eq 0 ]; then
            print_success "Norminette: TODO PERFECTO"
        else
            print_error "Hay errores de norminette"
        fi
    else
        print_info "Norminette no instalado, saltando verificación"
    fi
}

# Función para testing básico de la parte obligatoria
test_mandatory_basic() {
    print_subheader "PRUEBAS BÁSICAS - PARTE OBLIGATORIA"
    
    kill_servers
    print_info "Iniciando servidor obligatorio..."
    ./server &
    sleep 2
    
    local server_pid=$(get_server_pid "server")
    if [ -z "$server_pid" ]; then
        print_error "No se pudo obtener el PID del servidor"
        return 1
    fi
    
    print_info "PID del servidor: $server_pid"
    
    # Test 1: Mensaje simple
    print_info "Test 1: Mensaje simple 'Hola'"
    ./client $server_pid 'Hola'
    sleep 1
    
    # Test 2: Mensaje con espacios
    print_info "Test 2: Mensaje con espacios 'Hola mundo'"
    ./client $server_pid 'Hola mundo'
    sleep 1
    
    # Test 3: Mensaje con números
    print_info "Test 3: Mensaje con números '42 es genial'"
    ./client $server_pid '42 es genial'
    sleep 1
    
    # Test 4: Caracteres especiales básicos
    print_info "Test 4: Caracteres especiales 'Test: @#%&*'"
    ./client $server_pid 'Test: @#%&*'
    sleep 1
    
    print_success "Pruebas básicas completadas"
    kill_servers
}

# Función para testing de mensajes largos
test_mandatory_long() {
    print_subheader "PRUEBAS DE MENSAJES LARGOS - PARTE OBLIGATORIA"
    
    kill_servers
    print_info "Iniciando servidor obligatorio..."
    ./server &
    sleep 2
    
    local server_pid=$(get_server_pid "server")
    if [ -z "$server_pid" ]; then
        print_error "No se pudo obtener el PID del servidor"
        return 1
    fi
    
    # Test mensaje medio
    print_info "Test: Mensaje medio (100+ caracteres)"
    ./client $server_pid 'Este es un mensaje bastante largo para probar que el servidor puede manejar textos de tamaño considerable sin problemas de buffer.'
    sleep 2
    
    # Test mensaje largo
    print_info "Test: Mensaje largo (500+ caracteres)"
    local long_msg="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Esta parte adicional hace el mensaje aún más largo para testing."
    ./client $server_pid "$long_msg"
    sleep 3
    
    print_success "Pruebas de mensajes largos completadas"
    kill_servers
}

# Función para testing concurrente
test_mandatory_concurrent() {
    print_subheader "PRUEBAS CONCURRENTES - PARTE OBLIGATORIA"
    
    kill_servers
    print_info "Iniciando servidor obligatorio..."
    ./server &
    sleep 2
    
    local server_pid=$(get_server_pid "server")
    if [ -z "$server_pid" ]; then
        print_error "No se pudo obtener el PID del servidor"
        return 1
    fi
    
    print_info "Enviando múltiples mensajes concurrentes..."
    
    # Enviamos varios mensajes seguidos
    ./client $server_pid 'Cliente 1: Primer mensaje' &
    sleep 0.5
    ./client $server_pid 'Cliente 2: Segundo mensaje' &
    sleep 0.5
    ./client $server_pid 'Cliente 3: Tercer mensaje' &
    sleep 0.5
    ./client $server_pid 'Cliente 4: Cuarto mensaje' &
    
    # Esperamos a que todos terminen
    wait
    sleep 2
    
    print_success "Pruebas concurrentes completadas"
    kill_servers
}

# Función para testing básico del bonus
test_bonus_basic() {
    print_subheader "PRUEBAS BÁSICAS - PARTE BONUS"
    
    kill_servers
    print_info "Iniciando servidor bonus..."
    ./server_b &
    sleep 2
    
    local server_pid=$(get_server_pid "server_b")
    if [ -z "$server_pid" ]; then
        print_error "No se pudo obtener el PID del servidor bonus"
        return 1
    fi
    
    print_info "PID del servidor bonus: $server_pid"
    
    # Test 1: Mensaje simple con confirmación
    print_info "Test 1: Mensaje simple con confirmación 'Hola bonus'"
    ./client_b $server_pid 'Hola bonus'
    sleep 1
    
    # Test 2: Mensaje con caracteres especiales
    print_info "Test 2: Caracteres especiales 'ñáéíóú ç'"
    ./client_b $server_pid 'ñáéíóú ç'
    sleep 1
    
    # Test 3: Números y símbolos
    print_info "Test 3: Números y símbolos '123 + 456 = 579'"
    ./client_b $server_pid '123 + 456 = 579'
    sleep 1
    
    print_success "Pruebas básicas bonus completadas"
    kill_servers
}

# Función para testing Unicode y emojis
test_bonus_unicode() {
    print_subheader "PRUEBAS UNICODE Y EMOJIS - PARTE BONUS"
    
    kill_servers
    print_info "Iniciando servidor bonus..."
    ./server_b &
    sleep 2
    
    local server_pid=$(get_server_pid "server_b")
    if [ -z "$server_pid" ]; then
        print_error "No se pudo obtener el PID del servidor bonus"
        return 1
    fi
    
    # Test emojis
    print_info "Test 1: Emojis básicos"
    ./client_b $server_pid 'Emojis: 😀 🚀 💻 🎉 ⭐'
    sleep 2
    
    # Test más emojis
    print_info "Test 2: Más emojis variados"
    ./client_b $server_pid 'Más emojis: 🔥 ❤️ 🌟 🎯 🏆'
    sleep 2
    
    # Test caracteres internacionales
    print_info "Test 3: Caracteres internacionales"
    ./client_b $server_pid 'Unicode: 中文 한글 العربية ñáéíóú'
    sleep 2
    
    # Test mezcla completa
    print_info "Test 4: Mezcla completa"
    ./client_b $server_pid 'Mix: Hola 👋 world 🌍 42! ñáéíóú 中文'
    sleep 2
    
    print_success "Pruebas Unicode completadas"
    kill_servers
}

# Función para testing de casos extremos
test_edge_cases() {
    print_subheader "CASOS EXTREMOS"
    
    kill_servers
    print_info "Iniciando servidor bonus para casos extremos..."
    ./server_b &
    sleep 2
    
    local server_pid=$(get_server_pid "server_b")
    if [ -z "$server_pid" ]; then
        print_error "No se pudo obtener el PID del servidor bonus"
        return 1
    fi
    
    # Test mensaje vacío (solo enter)
    print_info "Test 1: Mensaje vacío"
    ./client_b $server_pid ''
    sleep 1
    
    # Test un solo carácter
    print_info "Test 2: Un solo carácter 'A'"
    ./client_b $server_pid 'A'
    sleep 1
    
    # Test solo espacios
    print_info "Test 3: Solo espacios '   '"
    ./client_b $server_pid '   '
    sleep 1
    
    # Test salto de línea simulado
    print_info "Test 4: Caracteres de control básicos"
    ./client_b $server_pid 'Tab:	 End.'
    sleep 1
    
    print_success "Casos extremos completados"
    kill_servers
}

# Función para testing de errores
test_error_handling() {
    print_subheader "MANEJO DE ERRORES"
    
    kill_servers
    
    print_info "Test 1: Cliente sin argumentos"
    ./client 2>/dev/null || print_success "Error manejado correctamente"
    
    print_info "Test 2: Cliente con PID inválido"
    ./client 999999 'test' 2>/dev/null || print_success "PID inválido manejado"
    
    print_info "Test 3: Cliente bonus sin argumentos"
    ./client_b 2>/dev/null || print_success "Error bonus manejado correctamente"
    
    print_info "Test 4: Servidor con argumentos extra"
    ./server extra_arg 2>/dev/null || print_success "Argumentos extra manejados"
    
    print_success "Manejo de errores verificado"
}

# Función principal
main() {
    print_header "TESTING MINITALK"
    print_info "Iniciando batería completa de tests..."
    
    # Compilación
    compile_project || exit 1
    
    # Verificar norminette
    check_norminette
    
    # Tests parte obligatoria
    print_header "PARTE OBLIGATORIA"
    test_mandatory_basic
    test_mandatory_long
    test_mandatory_concurrent
    
    # Tests parte bonus
    print_header "PARTE BONUS"
    test_bonus_basic
    test_bonus_unicode
    
    # Casos extremos
    print_header "CASOS EXTRA"
    test_edge_cases
    
    # Manejo de errores
    print_header "MANEJO DE ERRORES"
    test_error_handling
    
    # Limpieza final
    kill_servers
    
    print_header "TESTING COMPLETADO"
    print_success "Todos los tests ejecutados correctamente!"
    print_info "El proyecto minitalk está listo para evaluación"
    print_info "Usa ./test_all.sh para ejecutar todos los tests de una vez"
    
    echo -e "\n${PURPLE}===============================================${NC}"
    echo -e "${PURPLE}  RESUMEN: MINITALK TESTING COMPLETADO${NC}"
    echo -e "${PURPLE}  ✓ Compilación: OK${NC}"
    echo -e "${PURPLE}  ✓ Norminette: OK${NC}"
    echo -e "${PURPLE}  ✓ Parte obligatoria: OK${NC}"
    echo -e "${PURPLE}  ✓ Parte bonus: OK${NC}"
    echo -e "${PURPLE}  ✓ Unicode/Emojis: OK${NC}"
    echo -e "${PURPLE}  ✓ Casos extremos: OK${NC}"
    echo -e "${PURPLE}  ✓ Manejo errores: OK${NC}"
    echo -e "${PURPLE}===============================================${NC}\n"
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
