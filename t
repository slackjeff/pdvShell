#!/bin/bash

function replicate() {
    local Var
    printf -v Var %"$2"s " "
    echo "${Var// /$1}"
}

function mabox() {
    # Parâmetros da função
    ntop=$1
    nleft=$2
    nbottom=$3
    nright=$4

	((ntop++))
	((nleft++))
#	((nbottom++))
#	((nright++))
    # Criação da moldura superior e inferior
       frame_top="┌$(replicate "─" "$((nright-2))")┐"
    frame_bottom="└$(replicate "─" "$((nright-2))")┘"

    # Desenha a moldura superior
    printf "\e[%s;%sH%s" $ntop $nleft "$frame_top"

    # Desenha os lados do menu
    for ((i = 1; i <= nbottom-ntop; i++)); do
        printf "\e[$((ntop+i));%sH%s" $nleft "│$(replicate " " $((nright-2)))│"
		echo $i
    done

    # Desenha a moldura inferior
    printf "\e[$((nbottom));%sH%s" $nleft "$frame_bottom"

    # Move o cursor para a última linha para evitar problemas de exibição
#    printf "\e[$((nbottom - 1));1H"
}

clear
#echo "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
mabox 10 10 25 20
#tput cup 0 11; echo -n "0000000000000"
