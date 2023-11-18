#!/bin/bash

function setpos() {
	local row="$1"
	local col="$2"

	Prow="$row"
	Pcol="$col"
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

	if [[ -n "$color" ]]; then
		if ((color > 15)); then
			tput setab $color
		else
			tput setaf $color
		fi
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

function yesno() {
	local linha=$1
	local coluna=$2
	local titulo="$3"
	local itens=("Sim" "Não")
	local tamanho_maximo=${#titulo}
	local quantidade_itens="${#itens[@]}"
	local i tecla selecionado item_formatado
	local sair_do_menu=false
	local color="$(tput setab 52)"
	local reverse="$(tput rev)"
	local reset="$(tput sgr0)"

	tamanho_maximo=$((tamanho_maximo))
	for item in "${itens[@]}"; do
		((tamanho_maximo = tamanho_maximo < ${#item} ? ${#item} : tamanho_maximo))
	done

	mabox "$linha" "$coluna" "$((quantidade_itens + 4))" "$((tamanho_maximo + 2))" 52
	print $((linha + 1)) $((coluna + 1)) "$titulo"
	print $((linha + 2)) $((coluna)) "├$(replicate "─" "$((tamanho_maximo))")┤"

	while ! $sair_do_menu; do
		for i in "${!itens[@]}"; do
			local item="${itens[i]}"
			local padding=$((tamanho_maximo - ${#item} -2))
			[[ -n "${aCorItemMenu[i]}" ]] && color="${aCorItemMenu[i]}"
			if [[ $i -eq $selecionado ]]; then
				item_formatado="${reverse}${color}►${item^^}◄%${padding}s${reset}"
			else
				item_formatado="${color} ${item^} %${padding}s${reset}"
			fi
			printf "\e[$((linha + i + 4));%sH${item_formatado}${rst}" "$((coluna + 2))"
		done

		read -r -n 1 -s tecla
		case $tecla in
		"A") ((selecionado = selecionado > 0 ? selecionado - 1 : quantidade_itens - 1)) ;;
		"B") ((selecionado = selecionado < quantidade_itens - 1 ? selecionado + 1 : 0)) ;;
		"") return $((selecionado)) ;;
		esac
	done
}
clear
yesno 10 10 "Pergunta: Deseja realmente sair ?"
