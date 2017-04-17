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
push rbp
mov rbp, rsp
mov rdi, lista_size
call malloc WRT ..plt ; pido memoria para la lista
xor rsi, rsi
mov [rax + lista_longitud_offset], dword 0 ; longitud vacia
mov [rax + lista_primero_offset], rsi ; primero nulo
mov [rax + lista_ultimo_offset], rsi ; ultimo nulo
pop rbp
ret


global l_agregarAdelante
l_agregarAdelante:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
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
je l_agregarUnico
mov [rdi + nodo_anterior_offset], rax ; si había, le agrego este de anterior
mov [rbx + lista_primero_offset], rax ; ahora es el primero

jmp terminarInsercion


global l_agregarAtras
l_agregarAtras:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
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
je l_agregarUnico
mov [rdi + nodo_siguiente_offset], rax
jmp agregarAtras

l_agregarUnico:
mov [rbx + lista_primero_offset], rax ; si no había, también es el primero
agregarAtras:
mov [rbx + lista_ultimo_offset], rax ; ahora es el ultimo

jmp terminarInsercion


global l_agregarOrdenado
l_agregarOrdenado:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
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
mov [r15 + nodo_siguiente_offset], rdi ; seteo nodos a null por default
mov [r15 + nodo_anterior_offset], rdi

lea r12, [rbx + lista_primero_offset] ; tomo el puntero doble al primero de la lista
lea r13, [rbx + lista_ultimo_offset] ; y al ultimo de la lista
xor rdi, rdi
cmp [r12], rdi ; si no hay primero
je l_agregarOrdenado_unico ; entonces lo agrego adelante y atras

l_agregarOrdenado_loop:
mov r13, [r12]
add r13, nodo_anterior_offset ; avanzo el doble puntero siguiente

mov rdi, [r12]
mov rdi, [rdi + nodo_dato_offset] ; tomo el dato del siguiente
mov rsi, [r15 + nodo_dato_offset] ; y del nuevo nodo

call r14 ; los comparo con la funcion provista
cmp rax, 1 ; si el siguiente es mayor o igual
jl l_agregarOrdenado_done ; inserto aca

mov r12, [r12]
add r12, nodo_siguiente_offset ; avanzo el doble puntero anterior
xor rdi, rdi
cmp [r12], rdi ; si el siguiente es nulo
je l_agregarOrdenado_ultimo ; inserto al final

jmp l_agregarOrdenado_loop

l_agregarOrdenado_ultimo:
lea r13, [rbx + lista_ultimo_offset] ; recupero el puntero doble del ultimo de la lista
mov r8, [r13] ; el anterior es el viejo ultimo
xor r9, r9 ; no hay siguiente
jmp l_agregarOrdenado_guardarPrevios

l_agregarOrdenado_primero:
xor r8, r8 ; no hay anterior
mov r9, [r12] ; el siguiente es el viejo primero
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
mov [r15 + nodo_anterior_offset], r8 ; guardo el nuevo anterior
mov [r15 + nodo_siguiente_offset], r9 ; y siguiente del nodo a insertar
l_agregarOrdenado_unico:
mov [r12], r15 ; inserto el nodo donde corresponde
mov [r13], r15

pop r15
pop r14

terminarInsercion: ; al final de todas las inserciones
mov r8d, [rbx + lista_longitud_offset]
inc r8d
mov [rbx + lista_longitud_offset], r8d ; aumento la longitud de la lista

pop r13
pop r12
pop rbx
add rsp, 8 ; deshacer alineamiento de stack frame
pop rbp
ret

global l_borrarTodo
l_borrarTodo:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
push rbx
push r12
push r13

mov rbx, rdi ; me guardo la lista
mov r12, [rbx + lista_primero_offset]
borrar_while:
cmp r12, 0
je borrar_done ; si el nodo es nulo, termine
mov r13, [r12 + nodo_siguiente_offset]

mov rdi, [r12 + nodo_dato_offset]
mov r8, [r12 + nodo_borrar_offset]

call r8 ; borro el dato con su funcion de borrado

mov rdi, r12
call free WRT ..plt ; borro el nodo

mov r12, r13
jmp borrar_while

borrar_done:

mov rdi, rbx
call free WRT ..plt ; borro la lista

pop r13
pop r12
pop rbx
add rsp, 8 ; deshacer alineamiento de stack frame
pop rbp
ret

; CIUDAD

global c_crear
c_crear:
push rbp
mov rbp, rsp
push rbx
push r12

mov r12, rsi ; me guardo la población

call str_copy

mov rbx, rax ; me guardo el nombre copiado

mov rdi, ciudad_size
call malloc WRT ..plt ; pido memoria para la ciudad

mov [rax + ciudad_nombre_offset], rbx ; le guardo su informacion
mov [rax + ciudad_poblacion_offset], r12

pop r12
pop rbx
pop rbp
ret

global c_cmp
c_cmp:
push rbp
mov rbp, rsp

mov rdi, [rdi + ciudad_nombre_offset]
mov rsi, [rsi + ciudad_nombre_offset]
call str_cmp ; comparo las ciudades por sus nombres

pop rbp
ret

global c_borrar
c_borrar:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
push rbx

mov rbx, rdi

mov rdi, [rbx + ciudad_nombre_offset]
call free WRT ..plt ; borro el nombre

mov rdi, rbx
call free WRT ..plt ; borro la ciudad

pop rbx
add rsp, 8 ; deshacer alineamiento de stack frame
pop rbp
ret

; RUTA

global r_crear
r_crear:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
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
mov r12, r9 ; invierto los nombres para que esten ordenados

r_crear_ordenado:
mov rdi, ruta_size
call malloc WRT ..plt ; pido memoria para la ruta

mov [rax + ruta_ciudadA_offset], rbx
mov [rax + ruta_distancia_offset], r13
mov [rax + ruta_ciudadB_offset], r12

r_crear_done:
pop r13
pop r12
pop rbx
add rsp, 8 ; deshacer alineamiento de stack frame
pop rbp
ret

global r_cmp
r_cmp:
push rbp
mov rbp, rsp
push rbx
push r12

mov rbx, rdi ; me guardo las rutas
mov r12, rsi

mov rdi, [rbx + ruta_ciudadA_offset]
mov rsi, [r12 + ruta_ciudadA_offset]
call c_cmp ; comparo por la ciudad A

cmp rax, 0
jne rutasComparadas ; si son distintas, termine la comparacion

mov rdi, [rbx + ruta_ciudadB_offset]
mov rsi, [r12 + ruta_ciudadB_offset]
call c_cmp ; si son la misma ciudad, comparo por la ciudad B

rutasComparadas:
pop r12
pop rbx
pop rbp
ret

global r_borrar
r_borrar:
push rbp
mov rbp, rsp
call free WRT ..plt
pop rbp
ret

; RED CAMINERA

global rc_crear
rc_crear:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
push rbx

call str_copy ; copio el nombre
mov rbx, rax ; y lo guardo

mov rdi, redCaminera_size
call malloc WRT ..plt ; creo la red

mov [rax + redCaminera_nombre_offset], rbx ; le guardo su nombre
mov rbx, rax

call l_crear
mov [rbx + redCaminera_ciudades_offset], rax ; creo una lista de cidudades vacia

call l_crear
mov [rbx + redCaminera_rutas_offset], rax ; creo una lista de rutas vacia

mov rax, rbx

pop rbx
add rsp, 8 ; deshacer alineamiento de stack frame
pop rbp
ret

global rc_agregarCiudad
rc_agregarCiudad:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
push rbx
push r12
push r13

mov rbx, rdi
mov r12, rsi
mov r13, rdx

call obtenerCiudad
cmp rax, 0
jne rc_agregarCiudad_done ; si la ciudad existe, no agregar

mov rdi, r12
mov rsi, r13

call c_crear ; creo la nueva ciudad

lea rdi, [rbx + redCaminera_ciudades_offset] ; puntero doble a lista de ciudades
mov rsi, rax
mov rdx, c_borrar
mov rcx, c_cmp

call l_agregarOrdenado ; la agrego en orden

rc_agregarCiudad_done:
pop r13
pop r12
pop rbx
add rsp, 8 ; deshacer alineamiento de stack frame
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

mov rbx, rdi
mov r12, rsi
mov r13, rdx
movq r14, xmm0

mov rdi, r12
mov rsi, r13
call str_cmp
cmp rax, 0
je rc_agregarRuta_done ; si son iguales, no crear ruta
jg rc_agregarRuta_verificar ; ordenar lexicograficamente

mov r8, r12
mov r12, r13
mov r13, r8

rc_agregarRuta_verificar:

mov rdi, rbx
mov rsi, r12
mov rdx, r13
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

lea rdi, [rbx + redCaminera_rutas_offset]
mov rsi, rax
mov rdx, r_borrar
mov rcx, r_cmp

call l_agregarOrdenado

rc_agregarRuta_done:
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
sub rsp, 8 ; alinear el stack frame
push rbx

mov rbx, rdi ; me guardo la red a borrar

mov rdi, [rbx + redCaminera_ciudades_offset]
call l_borrarTodo ; borro las ciudades

mov rdi, [rbx + redCaminera_rutas_offset]
call l_borrarTodo ; borro las rutas

mov rdi, [rbx + redCaminera_nombre_offset]
call free WRT ..plt ; borro el nombre

mov rdi, rbx
call free WRT ..plt ; borro la red

pop rbx
add rsp, 8 ; deshacer alineamiento de stack frame
pop rbp
ret

; OTRAS DE RED CAMINERA

global obtenerCiudad
obtenerCiudad:
push rbp
mov rbp, rsp
push rbx
push r12

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
pop r12
pop rbx
pop rbp
ret

global obtenerRuta
obtenerRuta:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
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
add rsp, 8 ; deshacer alineamiento de stack frame
pop rbp
ret

global ciudadMasPoblada
ciudadMasPoblada: ; esta funcion es una hoja y no requiere stackframe
mov rdi, [rdi + redCaminera_ciudades_offset]
mov rdi, [rdi + lista_primero_offset]

mov rax, rdi

cmp rdi, 0
je ciudadMasPoblada_empty

ciudadMasPoblada_loop:
mov rdi, [rdi + nodo_siguiente_offset]
cmp rdi, 0
je ciudadMasPoblada_done
mov r8, [rax + nodo_dato_offset]
mov r8, [r8 + ciudad_poblacion_offset]
mov r9, [rdi + nodo_dato_offset]
mov r9, [r9 + ciudad_poblacion_offset]
cmp r8, r9
jae ciudadMasPoblada_loop
mov rax, rdi
jmp ciudadMasPoblada_loop

ciudadMasPoblada_done:
cmp rax, 0
je ciudadMasPoblada_empty
mov rax, [rax + nodo_dato_offset]

ciudadMasPoblada_empty:
ret

global rutaMasLarga
rutaMasLarga: ; esta funcion es una hoja y no requiere stackframe
mov rdi, [rdi + redCaminera_rutas_offset]
mov rdi, [rdi + lista_primero_offset]

mov rax, rdi
cmp rdi, 0
je rutaMasLarga_done

rutaMasLarga_loop:
mov rdi, [rdi + nodo_siguiente_offset]
cmp rdi, 0
je rutaMasLarga_done
mov r8, [rax + nodo_dato_offset]
movq xmm0, [r8 + ruta_distancia_offset]
mov r9, [rdi + nodo_dato_offset]
movq xmm1, [r9 + ruta_distancia_offset]

comisd xmm0, xmm1
jnb rutaMasLarga_loop
mov rax, rdi
jmp rutaMasLarga_loop

rutaMasLarga_done:
cmp rax, 0
je rutaMasLarga_empty
mov rax, [rax + nodo_dato_offset]

rutaMasLarga_empty:
ret

global ciudadesMasLejanas
ciudadesMasLejanas:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
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
add rsp, 8 ; deshacer alineamiento de stack frame
pop rbp
ret

global totalDeDistancia
totalDeDistancia: ; esta funcion es una hoja y no requiere stackframe
pxor xmm0, xmm0

mov rdi, [rdi + redCaminera_rutas_offset]
mov rdi, [rdi + lista_primero_offset]

totalDeDistancia_loop:
cmp rdi, 0
je totalDeDistancia_done

mov r8, [rdi + nodo_dato_offset]

addsd xmm0, [r8 + ruta_distancia_offset]

mov rdi, [rdi + nodo_siguiente_offset]
jmp totalDeDistancia_loop

totalDeDistancia_done:
ret

global totalDePoblacion
totalDePoblacion: ; esta funcion es una hoja y no requiere stackframe
mov rdi, [rdi + redCaminera_ciudades_offset]
mov rdi, [rdi + lista_primero_offset]

xor rax, rax
totalDePoblacion_loop:
cmp rdi, 0
je totalDePoblacion_done
mov r8, [rdi + nodo_dato_offset]
add rax, [r8 + ciudad_poblacion_offset]
mov rdi, [rdi + nodo_siguiente_offset]
jmp totalDePoblacion_loop
totalDePoblacion_done:
ret

global cantidadDeCaminos
cantidadDeCaminos:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14

mov rbx, [rdi + redCaminera_rutas_offset]
mov rbx, [rbx + lista_primero_offset]
mov r12, rsi

xor r13, r13
cantidadDeCaminos_loop:
cmp rbx, 0
je cantidadDeCaminos_done

mov r14, [rbx + nodo_dato_offset]
mov rdi, [r14 + ruta_ciudadA_offset]
mov rdi, [rdi + ciudad_nombre_offset]
mov rsi, r12

call str_cmp
cmp rax, 0
je encontreUnCamino

mov rdi, [r14 + ruta_ciudadB_offset]
mov rdi, [rdi + ciudad_nombre_offset]
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
sub rsp, 8 ; alinear el stack frame
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
mov rsi, [r13 + ciudad_nombre_offset]
call cantidadDeCaminos

mov r14, rax

ciudadMasComunicada_loop:
mov r12, [r12 + nodo_siguiente_offset]
cmp r12, 0
je ciudadMasComunicada_done

mov r15, [r12 + nodo_dato_offset]
mov rdi, rbx
mov rsi, [r15 + ciudad_nombre_offset]
call cantidadDeCaminos

cmp r14, rax
jae ciudadMasComunicada_loop
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
add rsp, 8 ; deshacer alineamiento de stack frame
pop rbp
ret

; AUXILIARES

global str_copy
str_copy:
push rbp
mov rbp, rsp
sub rsp, 8 ; alinear el stack frame
push rbx

mov rbx, rdi ; me guardo la vieja string

xor rdi, rdi
str_count_loop: ; cuento el tamaño
cmp [rbx + rdi], byte 0 ; si era el caracter nulo, termine
je str_count_end
inc rdi
jmp str_count_loop

str_count_end:
inc rdi ; siempre cuento uno más, para tener en cuenta el caracter nulo

call malloc WRT ..plt ; pido memoria para la copia

xor rdi, rdi
str_copy_loop: ; copio la string
mov r8b, [rbx + rdi]
mov [rax + rdi], r8b
inc rdi
cmp r8b, 0 ; si era el caracter nulo, termine
jne str_copy_loop

pop rbx
add rsp, 8 ; deshacer alineamiento de stack frame
pop rbp
ret

global str_cmp
str_cmp: ; esta funcion es una hoja y no requiere stackframe
xor rcx, rcx
xor rax, rax

str_cmp_loop:
mov r8b, [rdi + rcx]
cmp r8b, [rsi + rcx]
jg str_cmp_greater
jl str_cmp_lower
cmp r8b, byte 0
je str_cmp_end
inc rcx
jmp str_cmp_loop

str_cmp_greater:
dec rax
jmp str_cmp_end
str_cmp_lower:
inc rax

str_cmp_end:
ret