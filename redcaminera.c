#include <lzma.h>
#include "redcaminera.h"

void rc_imprimirTodo(redCaminera* rc, FILE *pFile) {
	fputs("Nombre:\n", pFile);
	fputs(rc->nombre, pFile);
	fputs("\nCiudades:\n", pFile);
	for(nodo* c = rc->ciudades->primero; c != NULL; c = c->siguiente) {
		ciudad* ciudad = c->dato;
		fprintf(pFile, "[%s,%lu]\n", ciudad->nombre, ciudad->poblacion);
	}
	fputs("Rutas:\n", pFile);
	for(nodo* r = rc->rutas->primero; r != NULL; r = r->siguiente) {
		ruta* ruta = r->dato;
		fprintf(pFile, "[%s,%s,%.1f]\n", ruta->ciudadA->nombre, ruta->ciudadB->nombre, ruta->distancia);
	}
}

redCaminera* rc_combinarRedes(char* nombre, redCaminera* rc1, redCaminera* rc2) {
	redCaminera* nueva = rc_crear(nombre);

	for(nodo* c1 = rc1->ciudades->primero; c1 != NULL; c1 = c1->siguiente) {
		rc_agregarCiudad(nueva, ((ciudad*)c1->dato)->nombre, ((ciudad*)c1->dato)->poblacion);
	}
	for(nodo* c2 = rc2->ciudades->primero; c2 != NULL; c2 = c2->siguiente) {
		rc_agregarCiudad(nueva, ((ciudad*)c2->dato)->nombre, ((ciudad*)c2->dato)->poblacion);
	}

	for(nodo* r1 = rc1->rutas->primero; r1 != NULL; r1 = r1->siguiente) {
		ciudad* a = ((ruta*)r1->dato)->ciudadA;
		ciudad* b = ((ruta*)r1->dato)->ciudadB;
		rc_agregarRuta(nueva, a->nombre, b->nombre, ((ruta*)r1->dato)->distancia);
	}
	for(nodo* r2 = rc2->rutas->primero; r2 != NULL; r2 = r2->siguiente) {
		ciudad* a = ((ruta*)r2->dato)->ciudadA;
		ciudad* b = ((ruta*)r2->dato)->ciudadB;
		rc_agregarRuta(nueva, a->nombre, b->nombre, ((ruta*)r2->dato)->distancia);
	}
	return nueva;
}

redCaminera* rc_obtenerSubRed(char* nombre, redCaminera* rc, lista* ciudades) {
	redCaminera* nueva = rc_crear(nombre);
	for(nodo* c = ciudades->primero; c != NULL; c = c->siguiente) {
		ciudad* anterior = obtenerCiudad(rc, ((ciudad*)c->dato)->nombre);
		if(anterior != NULL) {
			rc_agregarCiudad(nueva, ((ciudad*)c->dato)->nombre, ((ciudad*)c->dato)->poblacion);
		}
	}
	for(nodo* r = rc->rutas->primero; r != NULL; r = r->siguiente) {
		ciudad* a = ((ruta*)r->dato)->ciudadA;
		ciudad* b = ((ruta*)r->dato)->ciudadB;
		rc_agregarRuta(nueva, a->nombre, b->nombre, ((ruta*)r->dato)->distancia);
	}
	return nueva;
}
