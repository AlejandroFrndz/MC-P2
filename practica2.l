%option noyywrap

%{
    #include <iostream>
    #include <fstream>
    #include <map>
    #include <string>
    
    using namespace std;

    //Variables para las estadísticas generales
    int num_pet, aciertos_totales, errores_totales;
    //Flujo de entrada para el fichero a leer
    ifstream fichero;
    //Flag para indicar la IP a la que corresponde la petición identificada
    string ip_activa = "";

    //Struct para almacenar las estadísticas de cada IP individual
    struct datos{
        int peticiones = 0;
        int errores = 0;
        int aciertos = 0;
    };

    //Estructura para almacenar los datos que se van extrayendo del fichero
    map<string,datos> data;

    //Función para imprimir los resultados
    void escribir_datos();
%}

PIP3D1 1[0-9][0-9]
PIP3D2 2[0-4][0-9] 
PIP3D25 25[0-5]
PIP2D [1-9]*[0-9]

RANGOIP {PIP3D1}|{PIP3D2}|{PIP3D25}|{PIP2D}

IP {RANGOIP}"."{RANGOIP}"."{RANGOIP}"."{RANGOIP}" - -"

EXITO [1-3][0-9][0-9]
ERROR [4-5][0-9][0-9]
HEADER "HTTP/1."[0-1]"\" "

%%

{IP} {
    //Obtener la IP activa
    ip_activa= YYText(); 
    //Y eliminar la cola
    ip_activa = ip_activa.substr(0,ip_activa.size()-4);
    //Si la IP no ha sido ya registrada se la inserta en el map
    if(data.find(ip_activa) == data.end()){
        datos d;
        data.insert({ip_activa,d});
        data[ip_activa].peticiones++;
    }else{
        //Si ya lo ha sido, simplemente actualizamos el número de peticiones que ha realizado
        data[ip_activa].peticiones++;
    }  
    num_pet++;  
}   
{HEADER}{EXITO} {
    if(data.find(ip_activa) != data.end()) 
        data[ip_activa].aciertos++;

}
{HEADER}{ERROR} {
    if(data.find(ip_activa) != data.end())
        data[ip_activa].errores++;
}
. {}

%%


    int main (int argc, char *argv[]){
        //Apertura del fichero de datos de entrada
        if(argc == 2){
            fichero.open(argv[1]);
            if(!fichero.is_open()){
                cout << "error de la lectura" << endl;
                exit(1);
            }
        } else exit(1);

        //Inicializacion de los contadores globales
        num_pet = aciertos_totales = errores_totales = 0;

        yyFlexLexer flujo (&fichero,0);
        flujo.yylex();
        escribir_datos();

        return 0;
    }

    void escribir_datos(){
        map<string,datos>::const_iterator cit = data.cbegin();

        for(cit; cit != data.cend(); ++cit){
            cout << "La IP " << cit->first << " ha realizado:\n";
            cout << "\t" << cit->second.peticiones << " peticiones\n";
            cout << "\t" <<  ((float) cit->second.aciertos / cit->second.peticiones)*100 << "% han sido exitosas\n";
            cout << "\t" <<  ((float)cit->second.errores / cit->second.peticiones)*100 << "% han sido erroneas\n";
            aciertos_totales += cit->second.aciertos;
            errores_totales += cit->second.errores;
        }
        cout << "Me han llegado " << num_pet << " peticiones de " << data.size() << " IPs\n";
        cout << "\tTasa de exito " << ((float)aciertos_totales/num_pet)*100 << "%\n";
        cout << "\tTasa de error " << ((float)errores_totales/num_pet)*100 << "%\n";
    }
