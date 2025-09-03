# MINITALK - Proyecto de Comunicación por Señales

Minitalk es un proyecto de 42 que implementa un sistema de comunicación cliente-servidor usando **únicamente señales UNIX**. Básicamente, es como mandar mensajes por WhatsApp, pero bit a bit y usando solo `SIGUSR1` y `SIGUSR2`. 

## Objetivos del Proyecto

- **Parte obligatoria**: Comunicación básica servidor-cliente
- **Parte bonus**: Confirmaciones de recepción y soporte Unicode completo
- **Norminette**: Código perfectamente limpio según estándares 42
- **Sin malloc en handlers**: Handlers de señales async-safe (super importante)

## Estructura del Proyecto

```
minitalk/
├── server.c          # Servidor obligatorio (simple y robusto)
├── client.c          # Cliente obligatorio 
├── server_bonus.c    # Servidor bonus (con confirmaciones)
├── client_bonus.c    # Cliente bonus (espera confirmaciones)
├── minitalk.h        # Headers compartidos
├── test_all.sh       # Script completo de testing
├── Makefile          # Compilación automática
└── Libft/            # Mi librería personal de funciones
```

## Compilación y Uso

### Compilar todo:
```bash
make all        # Parte obligatoria
make bonus      # Parte bonus
make            # Por defecto compila obligatoria
```

### Uso básico:
```bash
# Parte obligatoria
./server                    # Arranca servidor (te da el PID)
./client <PID> "mensaje"    # Envía mensaje

# Parte bonus
./server_b                  # Servidor con confirmaciones
./client_b <PID> "mensaje"  # Cliente que espera confirmaciones
```

### Testing automático:
```bash
./test_all.sh  # Ejecuta TODOS los tests automáticamente
```

## Explicación Técnica 

#### 1. **Comunicación bit a bit**
Cada carácter se convierte en 8 bits y se envía usando:
- `SIGUSR1` = bit 1
- `SIGUSR2` = bit 0

```c
// Ejemplo: enviar 'A' (ASCII 65 = 01000001 en binario)
kill(pid, SIGUSR2);  // 0
kill(pid, SIGUSR1);  // 1  
kill(pid, SIGUSR2);  // 0
kill(pid, SIGUSR2);  // 0
kill(pid, SIGUSR2);  // 0
kill(pid, SIGUSR2);  // 0
kill(pid, SIGUSR2);  // 0
kill(pid, SIGUSR1);  // 1
```

#### 2. **Diferencias entre versiones**

| Aspecto | Obligatoria (`server.c`) | Bonus (`server_bonus.c`) |
|---------|-------------------------|--------------------------|
| **API Señales** | `signal()` simple | `sigaction()` con `SA_SIGINFO` |
| **Buffer** | Estático 4KB | Dinámico con `malloc` |
| **Confirmaciones** |  No |  Sí (bidireccional) |
| **Concurrencia** | Un cliente a la vez | Múltiples clientes |
| **Robusto** | Básico pero funcional | Avanzado y profesional |

#### 3. **Gestión de memoria inteligente**

**Servidor obligatorio**: Buffer estático super simple:
```c
static char g_message[4096];  // No malloc, no problemas
```

**Servidor bonus**: Buffer dinámico que crece:
```c
static char *g_buffer = NULL;  // Empieza en NULL
// Se expande automáticamente cuando se necesita más espacio
```

#### 4. **Handlers async-safe**
Los handlers de señales NO pueden usar `malloc` (obligatoria) porque no es async-safe. En el bonus sí podemos porque usamos `sigaction` con mejor control.

#### 5. **Soporte Unicode completo**
El bonus maneja:
- **Emojis**: 😀 🚀 💻 🎉 ⭐ 🔥 ❤️ 🌟
- **Acentos**: ñáéíóú ç ü 
- **Idiomas**: 中文 한글 العربية

## Casos de Prueba Incluidos

### Parte Obligatoria
1. **Mensajes básicos**: "Hola", "42 es genial"
2. **Mensajes largos**: Textos de 500+ caracteres
3. **Concurrencia**: Múltiples clientes enviando simultáneamente
4. **Caracteres especiales**: @#%&* y símbolos básicos

### Parte Bonus  
1. **Confirmaciones**: Cada bit confirmado por el servidor
2. **Unicode completo**: Emojis y caracteres internacionales
3. **Buffer dinámico**: Mensajes de cualquier tamaño
4. **Mejor timing**: Comunicación más rápida y confiable

### Casos Extra
1. **Mensaje vacío**: `""` 
2. **Un carácter**: `"A"`
3. **Solo espacios**: `"   "`
4. **PID inválido**: Manejo de errores


## Limitaciones:
- **Un mensaje a la vez**: El obligatorio no maneja concurrencia perfecta
- **Buffer fijo**: La versión obligatoria tiene límite de 4KB
- **Timing dependiente**: Velocidad limitada por `usleep()`


## **Manejo de señales**
```c
// Obligatoria: 
signal(SIGUSR1, ft_handler);

// Bonus: Con información del emisor
sa.sa_sigaction = ft_handler;  // Recibe siginfo_t con PID
sa.sa_flags = SA_SIGINFO;
```

## Resultados Esperados

Cuando ejecutes el testing completo deberías ver:

```
TESTING MINITALK
===============================================
✓ Compilación obligatoria exitosa
✓ Compilación bonus exitosa  
✓ Norminette: TODO PERFECTO
✓ Pruebas básicas completadas
✓ Pruebas de mensajes largos completadas
✓ Pruebas concurrentes completadas
✓ Pruebas básicas bonus completadas
✓ Pruebas Unicode completadas
✓ Casos extremos completados
✓ Manejo de errores verificado

TESTING COMPLETADO
===============================================
  RESUMEN: MINITALK TESTING COMPLETADO
  ✓ Compilación: OK
  ✓ Norminette: OK  
  ✓ Parte obligatoria: OK
  ✓ Parte bonus: OK
  ✓ Unicode/Emojis: OK
  ✓ Casos extremos: OK
  ✓ Manejo errores: OK
===============================================
```
