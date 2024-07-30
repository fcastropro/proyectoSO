BOLD="\e[1m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"
BACK_GREEN="\e[102m"
BACK_YELLOW="\e[103m"
TPUT_BLUE=$(tput setaf 123)
TPUT_RESET=$(tput sgr0)
TPUT_BG_COLOR=$(tput setab 31)
echo -e  "${TPUT_BG_COLOR}Proyecto de Sistemas Operativos\nAlumno: Fernando Castro.\nParalelo: A.${TPUT_RESET}"
echo "     Para usar las opciones del sistema recomendamos estar logeado como usuario administrador"
echo "Es necesario que se encuentre instalado net-tools si no lo esta ejecute sudo apt install net-tools"
echo "Como tambien estar instalado geoiplookup si no lo esta ejecute sudo apt-get install geoip-bin"
while true
do
cat <<-EOF
1	Comprobar procesos y rendimiento del sistema
2	Monitorizar un proceso específico
3	Terminar un proceso específico
4       Listar los procesos actualmente ejecutandose
5	Listar Usuarios del sistema
6	Ver las ips conectadas al servidor al puerto http: y https:
7	Saber el número de ips conectadas al servidor al puerto http: y https:
8       Número de paises conectados al servidor.
9       Número de ips conectadas por país
10	Salir
EOF
  read respuesta
  case $respuesta in
    1)
    echo "${TPUT_BG_COLOR}Para salir precionar CTRL+C${TPUT_RESET}" 
    top;;

    2)
    echo "Introduce nombre o el pid del proceso a controlar"
    read idproceso
        if [ -z "$idproceso" ]
            then
                echo "Debes introducir el nombre o pid del proceso"
        fi
        top | grep $idproceso
        ;;
    3)
    echo "Introduce el nombre del proceso a eliminar"
    read idproceso
        if [ -z "$idproceso" ]
            then
                echo "Debes introducir el nombre"
        fi
        id=$(pgrep $idproceso)
        sudo kill $id
        ;;
    4)
    ps -eo pid,comm --no-header | awk '{print $1, $2}'
	;;
    5)
    getent passwd | awk -F: '{ print $1}'
    	;;
    6)
    netstat -tnp | grep -E '(:80|:443)\s' | awk '{print $5}' | cut -d: -f1 | sort | uniq
    ;;
    7)
    count=$(ss -tnp 'sport = :80 or sport = :443' | awk 'NR > 1 {split($5, a, ":"); print a[1]}' | sort | uniq | wc -l)
    echo "El número de ips concectadas es: $count"
    ;;
    8)
    # Ejecutar el comando para obtener las IPs conectadas en puertos 80 y 443
    ips=$(netstat -tnp | grep -E '(:80|:443)\s' | awk '{print $5}' | cut -d: -f1 | sort | uniq)
    # Inicializar un array para almacenar los países únicos
    declare -A paises
    # Iterar sobre cada IP y determinar el país usando geoiplookup
    for ip in $ips; do
        pais=$(geoiplookup $ip | awk -F ": " '{print $2}')
        if [[ ! -z $pais ]]; then
            paises["$pais"]=1
        fi
    done
    # Contar el número de países únicos
    num_paises=${#paises[@]}
    # Imprimir el resultado
    echo "Número de países conectados: $num_paises"
    ;;
    9)
    # Ejecutar el comando para obtener las IPs conectadas en puertos 80 y 443
    ips=$(netstat -tnp | grep -E '(:80|:443)\s' | awk '{print $5}' | cut -d: -f1 | sort | uniq)
    # Inicializar un array para almacenar los países únicos
    declare -A paises
    # Iterar sobre cada IP y determinar el país usando geoiplookup
    for ip in $ips; do
        pais=$(geoiplookup $ip | awk -F ": " '{print $2}')
        if [[ ! -z $pais ]]; then
            if [[ -z ${paises["$pais"]} ]]; then
                paises["$pais"]=1
            else
                paises["$pais"]=$(( ${paises["$pais"]} + 1))
            fi
        fi
    done
    #Imprimir Paises y numeros de ips conectadas
    echo "País                 IPs Conectadas"
    for pais in "${!paises[@]}"; do
        printf "%-20s %d\n" "$pais" "${paises["$pais"]}"
    done
    ;;
    10)
    echo "Gracias por usar nuestro sistema"
        exit
       	;;
    *) echo "Introduce una opción correcta"
        exit
        ;;
    esac
done
