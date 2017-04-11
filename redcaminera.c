#include "redcaminera.h"

void rc_imprimirTodo(redCaminera* rc, FILE *pFile) {
	fprintf(pFile, "Nombre:\n");
	// TODO imprimir nombre
	fprintf(pFile, "Ciudades:\n");
	// TODO imprimir ciudades
	fprintf(pFile, "Rutas:\n");
	// TODO imprimir rutas
}

redCaminera* rc_combinarRedes(char* nombre, redCaminera* rc1, redCaminera* rc2) {
	redCaminera* nueva = rc_crear(nombre);
    return nueva;
}

redCaminera* rc_obtenerSubRed(char* nombre, redCaminera* rc, lista* ciudades) {
	redCaminera* nueva = rc_crear(nombre);
    return nueva;
}
