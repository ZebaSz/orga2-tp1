#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <lzma.h>
#include "redcaminera.h"


int main (void){
    redCaminera* rc = rc_crear("kukamonga");
    rc_agregarCiudad(rc, "montebello", 12041);
    rc_agregarCiudad(rc, "north haverbrook", 1244);
    rc_agregarCiudad(rc, "cocula", 342);
    rc_agregarRuta(rc, "montebello", "north haverbrook", 232);
    rc_agregarRuta(rc, "montebello", "cocula", 233);
    rc_agregarRuta(rc, "north haverbrook", "cocula", 236);

    ciudad* cMas = ciudadMasPoblada(rc);
    ruta* rMas = rutaMasLarga(rc);

    FILE* output;
    output = fopen("PepeGuapo.txt", "w");
    fprintf(output, "[%s,%lu]\n", cMas->nombre, cMas->poblacion);
    fprintf(output, "[%s,%s,%.1f]\n", rMas->ciudadA->nombre, rMas->ciudadB->nombre, rMas->distancia);
    fclose(output);

    return 0;    
}
