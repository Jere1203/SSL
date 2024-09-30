%{
#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
extern char *yytext;
extern int yyleng;
extern int yylex(void);
extern void yyerror(char*);
extern FILE *yyin;

void asignarIds(char* nombre, int valor);

struct Identificador{
   char* nombre;
   int valor;
}; 
struct Identificador identificadores[100];
int cantidadIdentificadores = 0;

%}
%union{
   char* cadena;
   int num;
} 

%token ASIGNACION PYCOMA RESTA SUMA PARENIZQUIERDO PARENDERECHO INICIO FIN LEER ESCRIBIR COMA FDT
%token <cadena> ID
%token <num> CONSTANTE

%%
// <objetivo> -> <programa> FDT
objetivo: programa FDT

// <programa> -> INICIO <listaSentencias> FIN
programa: INICIO listaSentencias FIN

// <listaSentencias> -> <sentencia> {<sentencia>}
listaSentencias: listaSentencias sentencia 
|sentencia

// Sentencia puede ser Asignacion, Leer o Escribir
// <sentencia> -> ID ASIGNACION <expresion> PYCOMA
sentencia: ID ASIGNACION expresion PYCOMA 
{
    char* nombre = $<cadena>1;
    int valor = $<num>3;
    asignarIds(nombre, valor);
}

// <sentencia> -> LEER PARENIZQUIERDO <listaIds> PARENDERECHO PYCOMA
|LEER PARENIZQUIERDO listaIds PARENDERECHO PYCOMA 
{
    int numero;
    char* cadena = $<cadena>3;
    char* token = strtok(cadena, ", ");
    while(token != NULL){
	printf("Ingresarle un valor a el id %s: ", token);
        scanf("%d", &numero);
	    asignarIds(token, numero);
        token = strtok(NULL, " ,");
    }
}

// <sentencia> -> ESCRIBIR PARENIZQUIERDO <listaExpresiones> PARENDERECHO PYCOMA
|ESCRIBIR PARENIZQUIERDO listaExpresiones PARENDERECHO PYCOMA
;

// <listaIds> -> <listaIds> COMA ID
listaIds: listaIds COMA ID 
{
	strcat($<cadena>1, ",");
	strcat($<cadena>1, $<cadena>3);
}
| ID
;

// <listaExpresiones> -> <listaExpresiones> COMA <expresion>
listaExpresiones: listaExpresiones COMA expresion
{
	printf("%d\n", $<num>3);
}

// <listaExpresiones> -> <expresion>
|expresion
{
	printf("%d\n", $<num>$);
}

// 
// 
expresion: primaria //Primaria es un ID, constante o parentesis
| expresion RESTA primaria 
{
    $<num>$ = $<num>1 - $<num>3;
}
| expresion SUMA primaria 
{
    $<num>$ = $<num>1 + $<num>3;
}

// <primaria> -> ID
primaria: ID 
{
    char* nombre = $<cadena>1;
    int i;
    for (i = 0; i < cantidadIdentificadores; i++) {
        if (strcmp(identificadores[i].nombre, nombre) == 0) {
            $<num>$ = identificadores[i].valor;
            break;
        }
    }
    if (i == cantidadIdentificadores) {
	char mensaje[100];
        sprintf(mensaje, "La variable %s no ha sido definida.\n", nombre);
	    yyerror(mensaje);
    }
}
|CONSTANTE // <primaria> -> CONSTANTE 
|PARENIZQUIERDO expresion PARENDERECHO  // <primaria> -> PARENIZQUIERDO <expresion> PARENDERECHO
{ 
    $<num>$ = $<num>2; 
}
;


%%
int main(int argc, char *argv[]){
    char nomArchi[50];
    int l=0;
    FILE *in;
    if (argc > 1)
    {
        if (argc != 2)
        {
            printf("Numero incorrecto de argumentos\n");
            return -1;
        } // los argumentos deben ser 2
        strcpy(nomArchi, argv[1]);
        l = strlen(nomArchi);
        // requiere para compilar un archivo de extensión.m archivo.m
        if (nomArchi[l - 1] != 'm' || nomArchi[l - 2] != '.')
        {
            printf("Nombre incorrecto del Archivo Fuente\n");
            return -1;
        }
        if ((in = fopen(nomArchi, "r")) == NULL)
        {
            printf("No se pudo abrir archivo fuente\n");
            return -1; // no pudo abrir archivo
        }
        yyin = in;
        yyparse();
        fclose(in);
        return 0;
    }
    else{
        yyin = stdin;
        yyparse();
        return 0;
    }

}

void yyerror (char *s){
    printf ("ERROR: %s\n",s);
    exit(1);
}
int yywrap(){
    return 1;
}

void asignarIds(char* nombre, int valor) { // Si no se encuentra el ID lo agrega
    int i;
    for (i = 0; i < cantidadIdentificadores; i++) {
        if (strcmp(identificadores[i].nombre, nombre) == 0) {
            identificadores[i].valor = valor;
            break;
        }
    }
    
    if (i == cantidadIdentificadores) {
        identificadores[cantidadIdentificadores].nombre = nombre; 
        identificadores[cantidadIdentificadores].valor = valor;
        cantidadIdentificadores++;
    }
}