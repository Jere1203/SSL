#include <stdio.h>
#include <string.h>

int main()
{
    char palabra[20] = "Hola Mundo";
    char token [4] = "Al";
    strtok(palabra,token);
    printf("%s",&palabra);
    return 0;
}