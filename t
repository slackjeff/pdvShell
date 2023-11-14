#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1091,SC2039,SC2166

function setpos() {
	local row="$1"
	local col="$2"
	tput cup "$row" "$col"
}

function print() {
	local row="$1"
	local col="$2"
	local msg="$3"
	local color="$4"

	[[ -z "$color" ]] && color="${Acores[box]}"
	setpos "$row" "$col"
	printf "${color}${msg}"
}

function replicate() {
	local Var
	printf -v Var %"$2"s " "
	echo "${Var// /$1}"
}

function mabox() {
	# Parâmetros da função
	local ntop="$1"
	local nleft="$2"
	local nbottom="$3"
	local nright="$4"
	local color="$5"

	((ntop++))
	((nleft++))
	nbottom=$((ntop + nbottom - 1))

	if ((color > 15)); then
		tput setab $color
	else
		tput setaf $color
	fi

	# Criação da moldura superior e inferior
	local frame_top="┌$(replicate "─" "$((nright - 2))")┐"
	local frame_bottom="└$(replicate "─" "$((nright - 2))")┘"

	# Desenha a moldura superior
	printf "\e[%s;%sH%s" $ntop $nleft "$frame_top"

	# Desenha os lados do menu
	for ((i = 1; i <= nbottom - ntop; i++)); do
		printf "\e[$((ntop + i));%sH%s" $nleft "│$(replicate " " $((nright - 2)))│"
	done

	# Desenha a moldura inferior
	printf "\e[$((nbottom));%sH%s" $nleft "$frame_bottom"

	# Move o cursor para a última linha para evitar problemas de exibição
	#    printf "\e[$((nbottom - 1));1H"
}

clear
sair_do_menu=false
selecionado=1

while ! $sair_do_menu; do
    tput sgr0
    mabox 10 10 8 40 "$selecionado"
    print 11 20 "COR ATUAL : $selecionado"
    print 13 12 "ESC         : CANCELAR"
    print 14 12 "ENTER       : ACEITAR ESCOLHA"
    print 15 12 "SETA ACIMA  : MUDA COR"
    print 16 12 "SETA ABAIXO : MUDA COR"

    read -s -n 1 tecla

    case $tecla in
    "A")
        selecionado=$((selecionado > 1 ? selecionado - 1 : 255))
        ;;
    "B")
        selecionado=$((selecionado < 255 ? selecionado + 1 : 1))
        ;;
    $'\x1b')  # Tecla Escape
        read -s -n 2 -t 0.1 restante
        if [[ $restante == "[A" ]]; then
            selecionado=$((selecionado > 1 ? selecionado - 1 : 255))
        elif [[ $restante == "[B" ]]; then
            selecionado=$((selecionado < 255 ? selecionado + 1 : 1))
        else
            sair_do_menu=true
        fi
        ;;
    "")
        tput sgr0
        if ((selecionado > 15)); then
            tput setab $selecionado | cat -v
        else
            tput setaf $selecionado | cat -v
        fi
        break
        ;;
    esac
done

