%define uint32_t 4
%define uint64_t 8
%define ptr 8

; typedef struct lista_t
%define lista_longitud_offset 0 ; uint32_t
%define lista_primero_offset 4 ; nodo_t*
%define lista_ultimo_offset 12 ; nodo_t*
%define lista_size 20 ; __attribute__((__packed__)) lista

; typedef struct nodo_t
%define nodo_borrar_offset 0 ; void*(void*)
%define nodo_dato_offset 8 ; void*
%define nodo_siguiente_offset 16 ; nodo_t*
%define nodo_anterior_offset 24 ; nodo_t*
%define nodo_size 32 ; __attribute__((__packed__)) nodo

; typedef struct ciudad_t
%define ciudad_nombre_offset 0 ; char*
%define ciudad_poblacion_offset 8 ; uint64_t
%define ciudad_size 16 ; __attribute__((__packed__)) ciudad

; typedef struct ruta_t {
%define ruta_ciudadA_offset 0 ;  ciudad_t*
%define ruta_distancia_offset 8 ; double
%define ruta_ciudadB_offset 16 ; ciudad_t*
%define ruta_size 24 ; __attribute__((__packed__)) ruta

; typedef struct redCaminera_t
%define redCaminera_ciudades_offset 0 ; lista_t*
%define redCaminera_rutas_offset 8 ; lista_t*
%define redCaminera_nombre_offset 16 ; char*
%define redCaminera_size 24; __attribute__((__packed__)) redCaminera

extern free
extern malloc


; UTILS

; LISTA 

global l_crear
l_crear:
mov rdi, lista_size
call malloc WRT ..plt
xor rsi, rsi

mov [rax + lista_longitud_offset], dword 0
mov [rax + lista_primero_offset], rsi
mov [rax + lista_ultimo_offset], rsi
ret


global l_agregarAdelante
l_agregarAdelante:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov rbx, [rdi] ; me guardo la lista (desreferenciada)
mov r12, rsi ; me guardo el dato
mov r13, rdx ; me guardo la funcion borrar

mov rdi, nodo_size
call malloc WRT ..plt ; pido memoria para nuevo nodo

mov [rax + nodo_dato_offset], r12 ; muevo el dato
mov [rax + nodo_borrar_offset], r13 ; muevo func borrar

xor rdi, rdi
mov [rax + nodo_anterior_offset], rdi ; seteo el anterior a null

mov rdi, [rbx + lista_primero_offset] ; me fijo si había un primer nodo
mov [rax + nodo_siguiente_offset], rdi
cmp rdi, 0
je noHayPrimero
mov [rdi + nodo_anterior_offset], rax ; si había, le agrego este de anterior
jmp agregarAdelante
noHayPrimero:
mov [rbx + lista_ultimo_offset], rax ; si no había, también es el último
agregarAdelante:
mov [rbx + lista_primero_offset], rax ; ahora es el primero

jmp terminarInsercion


global l_agregarAtras
l_agregarAtras:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov rbx, [rdi] ; me guardo la lista (desreferenciada)
mov r12, rsi ; me guardo el dato
mov r13, rdx ; me guardo la funcion borrar

mov rdi, nodo_size
call malloc WRT ..plt

mov [rax + nodo_dato_offset], r12
mov [rax + nodo_borrar_offset], r13

xor rdi, rdi
mov [rax + nodo_siguiente_offset], rdi

mov rdi, [rbx + lista_ultimo_offset]
mov [rax + nodo_anterior_offset], rdi
cmp rdi, 0
je noHayUltimo
mov [rdi + nodo_siguiente_offset], rax
jmp agregarAtras

noHayUltimo:
mov [rbx + lista_primero_offset], rax
agregarAtras:
mov [rbx + lista_ultimo_offset], rax

jmp terminarInsercion

global l_agregarOrdenado
l_agregarOrdenado:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15

mov rbx, [rdi] ; me guardo la lista (desreferenciada)
mov r12, rsi ; me guardo el dato
mov r13, rdx ; me guardo la funcion borrar
mov r14, rcx ; me guardo la funcion de comparacion

mov rdi, nodo_size
call malloc WRT ..plt ; pido memoria para el nuevo nodo

mov r15, rax ; y lo guardo

mov [r15 + nodo_dato_offset], r12 ; le seteo el dato
mov [r15 + nodo_borrar_offset], r13 ; y la funcion borrar
xor rdi, rdi
mov [r15 + nodo_siguiente_offset], rdi
mov [r15 + nodo_anterior_offset], rdi

mov r12, rbx
add r12, lista_primero_offset ; tomo el puntero a puntero del primero de la lista
mov r13, rbx
add r13, lista_ultimo_offset ; y del ultimo de la lista
xor rdi, rdi
cmp [r12], rdi ; si no hay primero
je l_agregarOrdenado_unico ; entonces lo agrego adelante y atras

l_agregarOrdenado_loop:

mov r13, [r12]
add r13, nodo_anterior_offset

mov rdi, [r12]
mov rdi, [rdi + nodo_dato_offset]
mov rsi, [r15 + nodo_dato_offset]

call r14
cmp rax, 1
jl l_agregarOrdenado_done

mov r12, [r12]
add r12, nodo_siguiente_offset
xor rdi, rdi
cmp [r12], rdi ; si el "proximo" es nulo, es el ultimo
je l_agregarOrdenado_ultimo

jmp l_agregarOrdenado_loop

l_agregarOrdenado_ultimo:
mov r13, rbx
add r13, lista_ultimo_offset
mov r8, [r13]
xor r9, r9
jmp l_agregarOrdenado_guardarPrevios

l_agregarOrdenado_primero:
xor r8, r8
mov r9, [r12]
jmp l_agregarOrdenado_guardarPrevios

l_agregarOrdenado_done:
xor rdi, rdi
cmp [r13], rdi
je l_agregarOrdenado_primero

mov r8, [r12]
mov r8, [r8 + nodo_anterior_offset]
mov r9, [r13]
mov r9, [r9 + nodo_siguiente_offset]
l_agregarOrdenado_guardarPrevios:
mov [r15 + nodo_anterior_offset], r8
mov [r15 + nodo_siguiente_offset], r9
l_agregarOrdenado_unico:
mov [r12], r15
mov [r13], r15

pop r15
pop r14

terminarInsercion:
mov rdi, [rbx + lista_longitud_offset]
inc rdi
mov [rbx + lista_longitud_offset], rdi

pop r13
pop r12
pop rbx
pop rbp

ret

global l_borrarTodo
l_borrarTodo:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov rbx, rdi ; me guardo la lista para usar frees
mov r12, [rbx + lista_primero_offset]
cmp r12, 0
je borrar_done
borrar_while:
mov r13, [r12 + nodo_siguiente_offset]

mov rdi, [r12 + nodo_dato_offset]
mov r8, [r12 + nodo_borrar_offset]

call r8

mov rdi, r12
call free WRT ..plt

mov r12, r13
cmp r12, 0
jne borrar_while

borrar_done:

mov rdi, rbx
call free WRT ..plt

pop r13
pop r12
pop rbx
pop rbp
ret

; CIUDAD

global c_crear
c_crear:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov r13, rsi ; me guardo la población

call str_copy

mov r12, rax ; me guardo el nombre

mov rdi, ciudad_size
call malloc WRT ..plt

mov [rax + ciudad_nombre_offset], r12
mov [rax + ciudad_poblacion_offset], r13

pop r13
pop r12
pop rbx
pop rbp
ret

global c_cmp
c_cmp:
mov rdi, [rdi + ciudad_nombre_offset]
mov rsi, [rsi + ciudad_nombre_offset]
call str_cmp
ret

global c_borrar
c_borrar:
push rbp
mov rbp, rsp
push rbx

mov rbx, rdi

mov rdi, [rbx + ciudad_nombre_offset]
call free WRT ..plt

mov rdi, rbx
call free WRT ..plt

pop rbx
pop rbp
ret

; RUTA

global r_crear
r_crear:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov rbx, rdi ; me guardo la ciudad 1
mov r12, rsi ; me guardo la ciudad 2
movq r13, xmm0 ; me guardo la distancia

call c_cmp
cmp rax, 0
je r_crear_done ; si son iguales, no crear ruta
jg r_crear_ordenado ; ordenar lexicograficamente

mov r9, rbx
mov rbx, r12
mov r12, r9

r_crear_ordenado:

mov rdi, ruta_size
call malloc WRT ..plt

mov [rax + ruta_ciudadA_offset], rbx
mov [rax + ruta_distancia_offset], r13
mov [rax + ruta_ciudadB_offset], r12

r_crear_done:

pop r13
pop r12
pop rbx
pop rbp
ret

global r_cmp
r_cmp:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov r12, rdi ; me guardo las rutas
mov r13, rsi

mov rdi, [r12 + ruta_ciudadA_offset]
mov rsi, [r13 + ruta_ciudadA_offset]
call c_cmp ; comparo por el nombre de ciudad A

cmp rax, 0
jne rutasComparadas

mov rdi, [r12 + ruta_ciudadB_offset]
mov rsi, [r13 + ruta_ciudadB_offset]
call c_cmp ; si son la misma ciudad, comparo por el nombre de ciudad B

rutasComparadas:
pop r13
pop r12
pop rbx
pop rbp
ret

global r_borrar
r_borrar:
call free WRT ..plt
ret

; RED CAMINERA

global rc_crear
rc_crear:
push rbp
mov rbp, rsp
push rbx

call str_copy

mov rbx, rax

mov rdi, redCaminera_size
call malloc WRT ..plt

mov [rax + redCaminera_nombre_offset], rbx

mov rbx, rax

call l_crear

mov [rbx + redCaminera_ciudades_offset], rax

call l_crear

mov [rbx + redCaminera_rutas_offset], rax

mov rax, rbx

pop rbx
pop rbp
ret

global rc_agregarCiudad
rc_agregarCiudad:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov rbx, rdi
mov r12, rsi
mov r13, rdx

call obtenerCiudad

cmp rax, 0
jne rc_agregarCiudad_done

mov rdi, r12
mov rsi, r13

call c_crear

mov rdi, rbx
add rdi, redCaminera_ciudades_offset
mov rsi, rax
mov rdx, c_borrar
mov rcx, c_cmp

call l_agregarOrdenado

rc_agregarCiudad_done:

pop r13
pop r12
pop rbx
pop rbp
ret

global rc_agregarRuta
rc_agregarRuta:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15

mov rbx, rdi
mov r12, rsi
mov r13, rdx
movq r14, xmm0

call obtenerRuta
cmp rax, 0
jne rc_agregarRuta_done ; si la ruta existe, no crear ruta

mov rdi, rbx
mov rsi, r12
call obtenerCiudad
cmp rax, 0
je rc_agregarRuta_done ; si la ciudad A no existe, no crear ruta
mov r12, rax

mov rdi, rbx
mov rsi, r13
call obtenerCiudad
cmp rax, 0
je rc_agregarRuta_done ; si la ciudad B no existe, no crear ruta
mov r13, rax

mov rdi, r12
mov rsi, r13
movq xmm0, r14
call r_crear
cmp rax, 0
je rc_agregarRuta_done ; si la ruta no es valida, no agregar ruta

mov rdi, rbx
add rdi, redCaminera_rutas_offset
mov rsi, rax
mov rdx, r_borrar
mov rcx, r_cmp

call l_agregarOrdenado

rc_agregarRuta_done:

pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

global rc_borrarTodo
rc_borrarTodo:
push rbp
mov rbp, rsp
push rbx

mov rbx, rdi ; me guardo la red a borrar

mov rdi, [rbx + redCaminera_ciudades_offset]
call l_borrarTodo ; borro las ciudades

mov rdi, [rbx + redCaminera_rutas_offset]
call l_borrarTodo ; borro las rutas

mov rdi, [rbx + redCaminera_nombre_offset]
call free WRT ..plt

mov rdi, rbx
call free WRT ..plt

pop rbx
pop rbp
ret

; OTRAS DE RED CAMINERA

global obtenerCiudad
obtenerCiudad:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15

mov r12, rsi

mov rbx, [rdi + redCaminera_ciudades_offset]
mov rbx, [rbx + lista_primero_offset]

obtenerCiudad_loop:
cmp rbx, 0
je ciudadNoExiste
mov rdi, r12
mov rsi, [rbx + nodo_dato_offset]
mov rsi, [rsi + ciudad_nombre_offset]

call str_cmp
cmp rax, 0
je encontreCiudad
mov rbx, [rbx + nodo_siguiente_offset]
jmp obtenerCiudad_loop

ciudadNoExiste:
xor rax, rax
jmp obtenerCiudad_done

encontreCiudad:
mov rax, [rbx + nodo_dato_offset]

obtenerCiudad_done:

pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

global obtenerRuta
obtenerRuta:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov r12, rsi
mov r13, rdx

mov rbx, [rdi + redCaminera_rutas_offset]
mov rbx, [rbx + lista_primero_offset]

obtenerRuta_loop:
cmp rbx, 0
je rutaNoExiste
mov rdi, r12
mov rsi, [rbx + nodo_dato_offset]
mov rsi, [rsi + ruta_ciudadA_offset]
mov rsi, [rsi + ciudad_nombre_offset]

call str_cmp
cmp rax, 0
jne noEncontreRuta
mov rdi, r13
mov rsi, [rbx + nodo_dato_offset]
mov rsi, [rsi + ruta_ciudadB_offset]
mov rsi, [rsi + ciudad_nombre_offset]
call str_cmp
cmp rax, 0
je encontreRuta

noEncontreRuta:
mov rbx, [rbx + nodo_siguiente_offset]
jmp obtenerRuta_loop

rutaNoExiste:
xor rax, rax
jmp obtenerRuta_done

encontreRuta:
mov rax, [rbx + nodo_dato_offset]

obtenerRuta_done:

pop r13
pop r12
pop rbx
pop rbp
ret

global ciudadMasPoblada
ciudadMasPoblada:
push rbp
mov rbp, rsp
push rbx

mov rbx, [rdi + redCaminera_ciudades_offset]
mov rbx, [rbx + lista_primero_offset]

mov rax, rbx

cmp rbx, 0
je ciudadMasPoblada_done

ciudadMasPoblada_loop:
mov rbx, [rbx + nodo_siguiente_offset]
cmp rbx, 0
je ciudadMasPoblada_done
mov r8, [rax + nodo_dato_offset]
mov r8, [r8 + ciudad_poblacion_offset]
mov r9, [rbx + nodo_dato_offset]
mov r9, [r9 + ciudad_poblacion_offset]
cmp r8, r9
jge ciudadMasPoblada_loop
mov rax, rbx
jmp ciudadMasPoblada_loop

ciudadMasPoblada_done:
cmp rax, 0
je ciudadMasPoblada_empty
mov rax, [rax + nodo_dato_offset]

ciudadMasPoblada_empty:

pop rbx
pop rbp
ret

global rutaMasLarga
rutaMasLarga:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov rbx, [rdi + redCaminera_rutas_offset]
mov rbx, [rbx + lista_primero_offset]

mov rax, rbx
cmp rbx, 0
je rutaMasLarga_done

rutaMasLarga_loop:
mov rbx, [rbx + nodo_siguiente_offset]
cmp rbx, 0
je rutaMasLarga_done
mov r8, [rax + nodo_dato_offset]
movq xmm0, [r8 + ruta_distancia_offset]
mov r9, [rbx + nodo_dato_offset]
movq xmm1, [r9 + ruta_distancia_offset]

comisd xmm0, xmm1
jnb rutaMasLarga_loop
mov rax, rbx
jmp rutaMasLarga_loop

rutaMasLarga_done:
cmp rax, 0
je rutaMasLarga_empty
mov rax, [rax + nodo_dato_offset]

rutaMasLarga_empty:
pop r13
pop r12
pop rbx
pop rbp
ret

global ciudadesMasLejanas
ciudadesMasLejanas:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov rbx, rdi
mov r12, rsi
mov r13, rdx

call rutaMasLarga

cmp rax, 0
je ciudadesMasLejanas_done

mov r8, [rax + ruta_ciudadA_offset]
mov r9, [rax + ruta_ciudadB_offset]
mov [r12], r8
mov [r13], r9

ciudadesMasLejanas_done:

pop r13
pop r12
pop rbx
pop rbp
ret

global totalDeDistancia
totalDeDistancia:
; TODO
ret

global totalDePoblacion
totalDePoblacion:
push rbp
mov rbp, rsp
push rbx

mov rbx, rdi
mov rbx, [rbx + redCaminera_ciudades_offset]
mov rbx, [rbx + lista_primero_offset]

xor rax, rax
totalDePoblacion_loop:
cmp rbx, 0
jmp totalDePoblacion_done
mov r8, [rbx + nodo_dato_offset]
mov r8, [r8 + ciudad_poblacion_offset]
add rax, r8
mov rbx, [rbx + nodo_siguiente_offset]
jmp totalDePoblacion_loop
totalDePoblacion_done:

pop rbx
pop rbp
ret

global cantidadDeCaminos
cantidadDeCaminos:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15

mov rbx, [rdi + redCaminera_rutas_offset]
mov rbx, [rbx + lista_primero_offset]
mov r12, rsi

xor r13, r13
cantidadDeCaminos_loop:
cmp rbx, 0
je cantidadDeCaminos_done

mov r14, [rbx + nodo_dato_offset]
mov rdi, [r14 + ruta_ciudadA_offset]
mov rsi, r12

call str_cmp
cmp rax, 0
je encontreUnCamino

mov rdi, [r14 + ruta_ciudadB_offset]
mov rsi, r12

call str_cmp
cmp rax, 0
je encontreUnCamino

jmp noEsUnCamino

encontreUnCamino:
inc r13
noEsUnCamino:
mov rbx, [rbx + nodo_siguiente_offset]
jmp cantidadDeCaminos_loop

cantidadDeCaminos_done:

mov rax, r13

pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

global ciudadMasComunicada
ciudadMasComunicada:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15

mov rbx, rdi

mov r12, [rbx + redCaminera_ciudades_offset]
mov r12, [r12 + lista_primero_offset]

xor r13, r13
cmp r12, 0
je ciudadMasComunicada_done

mov r13, [r12 + nodo_dato_offset]

mov rdi, rbx
mov rsi, r13
call cantidadDeCaminos

mov r14, rax

mov r12, [r12 + nodo_siguiente_offset]

ciudadMasComunicada_loop:
cmp r12, 0
je ciudadMasComunicada_done

mov r15, [r12 + nodo_dato_offset]
mov rdi, rbx
mov rsi, r15
call cantidadDeCaminos

mov r12, [r12 + nodo_siguiente_offset]

cmp r14, rax
jge ciudadMasComunicada_loop
mov r14, rax
mov r13, r15
jmp ciudadMasComunicada_loop

ciudadMasComunicada_done:

mov rax, r13

pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

; AUXILIARES

global str_copy
str_copy:
push rbp
mov rbp, rsp
push rbx
push r12
push r13

mov r12, rdi ; me guardo la vieja string

xor rdi, rdi

str_count_loop: ; cuento el tamaño
cmp [r12 + rdi], byte 0
je str_count_end
inc rdi
jmp str_count_loop

str_count_end:
inc rdi ; siempre cuento uno más, para tener en cuenta el caracter nulo

mov r13, rdi

call malloc WRT ..plt ; pido memoria para la copia

str_copy_loop: ; copio en reversa
dec r13 ; siempre decremento primero poruqe el tamaño es mayor a la ult pos
mov bl, [r12 + r13]
mov [rax + r13], bl
cmp r13, 0
jne str_copy_loop

pop r13
pop r12
pop rbx
pop rbp
ret

global str_cmp
str_cmp:
xor rdx, rdx
xor rcx, rcx
xor rax, rax

str_cmp_loop:
mov r8b, [rdi + rdx]
mov r9b, [rsi + rcx]
cmp r8b, r9b
jg str_cmp_greater
jl str_cmp_lower
cmp r8b, byte 0
je str_cmp_end
inc rdx
inc rcx
jmp str_cmp_loop

str_cmp_greater:
dec rax
jmp str_cmp_end
str_cmp_lower:
inc rax

str_cmp_end:
ret