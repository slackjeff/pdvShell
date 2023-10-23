#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1091,SC2039,SC2166,SC2162,SC2155,SC2005,SC2034,SC2154,SC2229

# TODO
# - traducao para vários idiomas
# - listagem das entradas de produtos

export TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAIN=mercearia

declare APP="${0##*/}"
declare _VERSION_="1.0.0-20231020"
declare DEPENDENCIES=(tput gettext sqlite3)
declare database='estoque.db'

# BEGIN FUNCTIONS
sh_config() {
	declare COL_NC='\e[0m' # No Color
	declare COL_LIGHT_GREEN='\e[1;32m'
	declare COL_LIGHT_RED='\e[1;31m'
	declare -g TICK="${white}[${COL_LIGHT_GREEN}✓${COL_NC}${white}]"
	declare -g CROSS="${white}[${COL_LIGHT_RED}✗${COL_NC}${white}]"
	declare -gi lastrow=$(lastrow)
	declare -gi lastcol=$(lastcol)
	declare -gi LC_DEFAULT=0
	sh_setvarcolors
}

debug() {
	whiptail \
		--fb \
		--clear \
		--backtitle "[debug]$0" \
		--title "[debug]$0" \
		--yesno "${*}\n" \
		0 40
	result=$?
	if ((result)); then
		exit
	fi
	return $result
}

inkey() {
	tempo="$1"
	[[ -z "$tempo" ]] && tempo=-1
	IFS= read -t "$tempo" -n 1 -s lastkey
	[[ -z "$lastkey" ]] && lastkey=""
}

die() {
	local msg=$1
	shift
	printf "  %b %s\\n" "${CROSS}" "${bold}${red}${msg}"
	exit 1
}

info_msg() {
	local retval="${PIPESTATUS[0]}"

	if [[ $retval -eq 0 ]]; then
		printf "  %b %s\\n" "${TICK}" "${*}"
	else
		printf "  %b %s\\n" "${CROSS}" "${*}"
	fi
}

sh_setvarcolors() {
	# does the terminal support true-color?
	if [[ -n "$(command -v "tput")" ]]; then
		#tput setaf 127 | cat -v  #capturar saida
		# Definir a variável de controle para restaurar a formatação original
		reset=$(tput sgr0)

		# Definir os estilos de texto como variáveis
		bold=$(tput bold)
		underline=$(tput smul)   # Início do sublinhado
		nounderline=$(tput rmul) # Fim do sublinhado
		reverse=$(tput rev)      # Inverte as cores de fundo e texto

		# Definir as cores ANSI como variáveis
		black=$(tput bold)$(tput setaf 0)
		red=$(tput bold)$(tput setaf 196)
		green=$(tput bold)$(tput setaf 2)
		yellow=$(tput bold)$(tput setaf 3)
		blue=$(tput setaf 4)
		pink=$(tput setaf 5)
		magenta=$(tput setaf 5)
		cyan=$(tput setaf 6)
		white=$(tput setaf 7)
		gray=$(tput setaf 8)
		orange=$(tput setaf 202)
		purple=$(tput setaf 125)
		violet=$(tput setaf 61)
		light_red=$(tput setaf 9)
		light_green=$(tput setaf 10)
		light_yellow=$(tput setaf 11)
		light_blue=$(tput setaf 12)
		light_magenta=$(tput setaf 13)
		light_cyan=$(tput setaf 14)
		light_white=$(tput setaf 15)

		# Definir cores de fundo
		azul=$(tput setab 4)
		vermelho=$(tput setab 196)
		roxo=$(tput setab 5)
		ciano=$(tput setab 6)

		# Definição de cores para formatação de texto
		cor_vermelha=$(tput setaf 1)
		cor_verde=$(tput setaf 2)
		cor_amarela=$(tput setaf 3)
		cor_reset=$(tput sgr0)
	else
		sh_unsetVarColors
	fi
}

sh_unsetVarColors() {
	unset reset bold underline nounderline reverse
	unset black red green yellow blue pink magenta cyan white gray orange purple violet
	unset light_red light_yellow light_blue light_magenta light_cyan light_white
	unset azul vermelho roxo ciano
	unset cor_vermelha cor_verde cor_amarela cor_reset
}

# Função para posicionar o cursor em uma linha e coluna específicas
setpos() {
	local row="$1"
	local col="$2"
	tput cup "$row" "$col"
}

lastrow() {
	echo "$(tput lines)"
}

lastcol() {
	echo "$(tput cols)"
}

imprimir_quadro() {
	local linha="$1"
	local col="$2"
	local altura="$3"
	local largura="$4"
	local mensagem="$5"
	local color="$6"
	local tamanho=$((largura - 2))
	local largura_mensagem=${#mensagem}
	local coluna_inicio=$(((largura - largura_mensagem) / 2 + col))

	# Imprime o quadro com base nas coordenadas, largura e altura
	for ((i = 0; i < altura; i++)); do
		tput cup $((linha + i)) "$col"
		if [ $i -eq 0 ]; then
			echo "┌$(printf '─%.0s' $(seq 1 $((largura - 2))))┐"
		elif [ $i -eq $((altura - 1)) ]; then
			echo "└$(printf '─%.0s' $(seq 1 $((largura - 2))))┘"
		else
			echo "│$(printf ' %.0s' $(seq 1 $((largura - 2))))│"
		fi
	done

	if [[ -n "$mensagem" ]]; then
		setpos "$linha" "$((col + 1))"
		printf "$color%-${tamanho}s" " "
		setpos "$linha" "$coluna_inicio"
		echo -e "$bold$white$mensagem"
	fi
	tput sgr0
}

print() {
	local row="$1"
	local col="$2"
	local msg="$3"
	local color="$4"

	setpos "$row" "$col"
	printf "%s" "$color"
	echo -e -n "$bold$white$msg"
	echo -e "$reset"
}

get() {
	local row="$1"
	local col="$2"
	local msg="$3"
	local prompt="$4"
	local old_value="$5"

	setpos "$row" "$col"
	#	read -p "$msg$reverse" "$prompt"
	read -p "$msg$reverse" -e -i "$old_value" "$prompt"
	tput sc # Salva a posição atual do cursor
	echo -e "$reset"
}

readconf() {
	tput el
	if [[ $LC_DEFAULT -eq 0 ]]; then
		read -n1 -s -r -p "$1 [S/n]"
	else
		read -n1 -s -r -p "$1 [Y/n]"
	fi
	[[ ${REPLY^} == $'\e' ]] && return 1
	[[ ${REPLY^} == "" ]] && return 0
	[[ ${REPLY^} == N ]] && return 1 || return 0
}

titulo() {
	local row="$1"
	local mensagem="$2"
	local color="$3"
	local extra_left="$4"
	local extra_right="$5"
	local largura_terminal=$(tput cols)
	local largura_mensagem=${#mensagem}
	local coluna_inicio=$(((largura_terminal - largura_mensagem) / 2))
	local nlen

	[[ -z "$color" ]] && color=$black
	tput sc # Salva a posição atual do cursor

	setpos "$row" 0
	printf "$color%-${largura_terminal}s" " "

	if [[ -n "$extra_left" ]]; then
		setpos "$row" 0
		echo -e "$bold$white$extra_left"
	fi

	if [[ -n "$extra_right" ]]; then
		nlen=${#extra_right}
		setpos "$row" $((largura_terminal - nlen))
		echo -e "$bold$white$extra_right"
	fi

	setpos "$row" "$coluna_inicio"
	echo -e "$bold$white$mensagem"
	tput sgr0
	tput rc
}

mensagem() {
	local row="$1"
	local msg="$2"
	local color="$3"
	local tempo="$4"

	msg+=" Tecle algo"
	local largura_terminal=$(tput cols)
	local largura_mensagem=${#msg}
	local coluna_inicio=$(((largura_terminal - largura_mensagem) / 2))

	[[ -z "$color" ]] && color=$green
	[[ -z "$tempo" ]] && tempo=1
	tput sc
	setpos "$row" 0
	printf "$reverse$color%-${largura_terminal}s" " "
	setpos "$row" "$coluna_inicio"
	printf "$reverse$color%s" "$msg"
	tput sgr0
	inkey "$tempo"
	setpos "$row" 0
	tput el
	tput rc
}

clear_eol() {
	local coluna_inicial="$1"
	local coluna_final="$2"

	# Posiciona o cursor na coluna_inicial
	echo -en "\033[6;${coluna_inicial}H"

	# Limpa o conteúdo até a coluna_final
	for ((i = coluna_inicial; i <= coluna_final; i++)); do
		setpos $i 0
		tput el
	done

	# Retorna o cursor para a posição inicial
	echo -en "\033[6;${coluna_inicial}H"
}

sh_checkDependencies() {
	local d
	local errorFound=0
	declare -a missing

	for d in "${DEPENDENCIES[@]}"; do
		[[ -z $(command -v "$d") ]] && missing+=("$d") && errorFound=1 && info_msg "${red}$(gettext "ERRO: não consegui encontrar o comando")${reset}: ${cyan}'$d'${reset}"
	done

	if ((errorFound)); then
		echo "${yellow}---------------$(gettext "IMPOSSÍVEL CONTINUAR")-------------${reset}"
		echo "$(gettext "Este script precisa dos comandos listados acima")"
		echo "$(gettext "Instale-os e/ou verifique se eles estão em seu") ${red}\$PATH${reset}"
		echo "${yellow}---------------$(gettext "IMPOSSÍVEL CONTINUAR")-------------${reset}"
		die "$(gettext "Instalação abortada!")"
	fi
}
# END FUNCTIONS

# BEGIN PROCEDURES
logo() {
	setpos 1 0
	echo -e "$red"
	cat <<-'EOF'
		  __  __                              _
		 |  \/  |                            (_)
		 | \  / | ___ _ __ ___ ___  __ _ _ __ _  __ _
		 | |\/| |/ _ \ '__/ __/ _ \/ _` | '__| |/ _` |
		 | |  | |  __/ | | (_|  __/ (_| | |  | | (_| |
		 |_|  |_|\___|_|  \___\___|\__,_|_|  |_|\__,_|
	EOF
	echo "$reset"
}

tela() {
	clear
	titulo 0 "SISTEMA PDV" "$roxo" "$(date)"
	titulo 1 "MENU PRINCIPAL" "$ciano"
	titulo "$(($(lastrow) - 2))" "MERCEARIA TEMDTUDO" "$azul" "$PWD" "$USER"
	logo
}

# Função para criar a tabela de produtos se não existir
criar_tabela_produtos() {
	query="CREATE TABLE IF NOT EXISTS produtos (
        id INTEGER PRIMARY KEY,
        nome TEXT,
        un TEXT,
        quantidade INTEGER,
        preco REAL,
        codebar TEXT
    );"
	sqlite3 "$database" "$query"
}

# Função para criar a tabela de vendas se não existir
criar_tabela_vendas() {
	query="CREATE TABLE IF NOT EXISTS vendas (
        id INTEGER,
        data DATE,
        quantidade INTEGER,
        preco REAL,
        total REAL,
        docnr TEXT
    );"
	sqlite3 "$database" "$query"
}

# Função para criar a tabela de compras se não existir
criar_tabela_compras() {
	query="CREATE TABLE IF NOT EXISTS compras (
        id INTEGER,
        fornecedor INTEGER,
        data DATE,
        docnr TEXT,
        quantidade INTEGER,
        custo REAL,
        total REAL
    );"
	sqlite3 "$database" "$query"
}

# Função para criar a tabela de fornecedores se não existir
criar_tabela_fornecedor() {
	query="CREATE TABLE IF NOT EXISTS fornecedor (
        id INTEGER PRIMARY KEY,
        data DATE,
        nome TEXT,
        ende TEXT,
        cida TEXT,
        esta TEXT,
        cnpj TEXT
    );"
	sqlite3 "$database" "$query"
}

# Função para pausar a execução e aguardar um pressionamento de tecla
pressione_para_continuar() {
	tput cuu1 # Move o cursor para a linha anterior
	tput sc   # Salva a posição do cursor
	echo ""
	read -n 1 -s -p "========> Pressione qualquer tecla para continuar..."
	tput rc # Restaura a posição do cursor
}

# função para retornar o ultimo registro de uma determinada tabela passada por parâmetro
lastrec() {
	local tabela="$1"
	local consulta_sql
	local resultado_info

	consulta_sql="SELECT * FROM '$tabela' ORDER BY id DESC LIMIT 1;"
	resultado_info="$(sqlite3 "$database" "$consulta_sql")"
	echo "$resultado_info"
}

# Função para encontrar um produto
seek() {
	local tabela="$1"
	local campo="$2"
	local search="$3"
	local result_info
	local retval=1

	if [[ $search =~ ^[0-9]+$ ]]; then
		if result_info=$(sqlite3 $database "SELECT * FROM '$tabela' WHERE $campo=$search;") && [[ -n "$result_info" ]]; then
			retval=0
		fi
	else
		if result_info=$(sqlite3 $database "SELECT * FROM $tabela WHERE $campo LIKE '%$search%';") && [[ -n "$result_info" ]]; then
			retval=0
		fi
	fi
	echo "$result_info"
	return $retval
}

# Função para adicionar um novo produto ao banco de dados
adicionar_produto() {
	local produto_info
	local ultimo_registro

	while true; do
		produto_info=
		ultimo_registro="$(lastrec 'produtos')"
		tela
		titulo 1 "CADASTRO DE PRODUTO" "$ciano"
		imprimir_quadro 11 10 6 100 "CADASTRO DE PRODUTO" "$ciano"
		print 10 11 "$ultimo_registro"
		print 12 11 "Descrição            : "
		print 13 11 "Codigo Barras        : "
		print 14 11 "Unidade              : "
		print 15 11 "Preço (ex: 4.40 ou 5): "

		while true; do
			get 12 11 "Descrição            : " nome
			if [[ -n "$nome" ]]; then
				if produto_info=$(seek produtos nome "$nome") && [ -n "$produto_info" ]; then
					IFS='|' read -r produto_id produto_nome produto_unidade produto_quantidade produto_preco produto_codebar <<<"$produto_info"
					get 12 11 "Descrição            : " nome "$produto_nome"
					if [[ -z "$nome" ]]; then
						mensagem 2 "Descrição não pode ser em branco" "$red"
						continue
					fi
				fi
				break
			else
				setpos 18 10
				if readconf "A descrição não pode ser em branco. Cancelar?"; then
					return
				fi
			fi
		done

		get 13 11 "Codigo Barras        : " codebar "$produto_codebar"
		get 14 11 "Unidade              : " un "$produto_unidade"

		# Solicita o preço como número inteiro ou decimal com ponto (ex: 4.40) e verifica se não está em branco
		while true; do
			get 15 11 "Preço (ex: 4.40 ou 5): " preco "$produto_preco"
			if [[ -n "$preco" ]] && [[ $preco =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
				break
			else
				mensagem 2 "Formato de preço inválido. Use ponto decimal (ex: 4.40) ou número inteiro." "$red"
			fi
		done

		setpos 18 10
		if readconf "Confirma inclusão/atualização do produto?"; then
			nome=${nome^^}
			un=${un^^}
			query="INSERT OR REPLACE INTO produtos (id, nome, un, preco, codebar) VALUES (
		        (SELECT id FROM produtos WHERE id='$produto_id'),
		        '$nome', '$un', $preco, $codebar
		    );"

			if sqlite3 "$database" "$query"; then
				mensagem 2 "Produto cadastrado/atualizado com sucesso!" "$green"
			else
				mensagem 2 "Erro no cadastro/atualização do produto." "$red"
			fi
		else
			mensagem 2 "Inclusão/alteração não efetuada." "$red"
		fi
	done
}

adicionar_fornecedor() {
	local date_time=$(date +"%Y-%m-%d %H:%M:%S")
	local fornecedor_info
	local ultimo_registro

	while true; do
		fornecedor_info=
		ultimo_registro="$(lastrec 'fornecedor')"
		tela
		titulo 1 "CADASTRO DE FORNECEDOR" "$ciano"
		imprimir_quadro 11 10 7 80 "CADASTRO DE FORNECEDOR" "$ciano"
		print 10 11 "$ultimo_registro"
		print 12 11 "Nome                 : "
		print 13 11 "Endereco             : "
		print 14 11 "Cidade               : "
		print 15 11 "Estado               : "
		print 16 11 "Cnpj                 : "

		while true; do
			get 12 11 "Nome                 : " nome
			if [[ -n "$nome" ]]; then
				if fornecedor_info=$(seek fornecedor nome "$nome") && [ -n "$fornecedor_info" ]; then
					IFS='|' read -r fornecedor_id fornecedor_data fornecedor_nome fornecedor_ende fornecedor_cida fornecedor_esta fornecedor_cnpj <<<"$fornecedor_info"
					get 12 11 "Nome                 : " nome "$fornecedor_nome"
					if [[ -z "$nome" ]]; then
						mensagem 2 "Nome não pode ser em branco" "$red"
						continue
					fi
				fi
				break
			else
				setpos 18 10
				if readconf "O nome não pode ser em branco. Cancelar?"; then
					return
				fi
			fi
		done

		get 13 11 "Endereco             : " ende "$fornecedor_ende"
		get 14 11 "Cidade               : " cida "$fornecedor_cida"
		get 15 11 "Estado               : " esta "$fornecedor_esta"
		get 16 11 "Cnpj                 : " cnpj "$fornecedor_cnpj"

		setpos 18 10
		if readconf "Confirma inclusão/atualização do fornecedor?"; then
			nome=${nome^^}
			ende=${ende^^}
			cida=${cida^^}
			esta=${esta^^}
			query="INSERT OR REPLACE INTO fornecedor (id,data, nome, ende, cida, esta, cnpj) VALUES (
		        (SELECT id FROM fornecedor WHERE id='$fornecedor_id'),
				'$date_time', '$nome', '$ende', '$cida', '$esta', '$cnpj'
			);"

			if sqlite3 "$database" "$query"; then
				mensagem 2 "Fornecedore cadastrado/atualizado com sucesso!" "$green"
			else
				mensagem 2 "Erro no cadastro/atualização do fornecedor" "$red"
			fi
		else
			mensagem 2 "Inclusão/alteração não efetuada." "$red"
		fi
	done
}

# Função para alterar dados de produtos
alterar_produto() {
	local produto_info
	local ultimo_registro
	local produto_info

	while true; do
		produto_info=
		identificador=
		ultimo_registro="$(lastrec 'produtos')"
		tela
		titulo 1 "ALTERAÇÃO DE PRODUTO" "$ciano"
		imprimir_quadro 11 10 7 100 "ALTERAÇÃO DE PRODUTO" "$ciano"
		print 10 11 "$ultimo_registro"
		print 12 11 "ID/Nome              : "
		print 13 11 "Descrição            : "
		print 14 11 "Codigo Barras        : "
		print 15 11 "Unidade              : "
		print 16 11 "Preço (ex: 4.40 ou 5): "

		get 12 11 "ID/Nome              : " identificador
		setpos 18 10

		if [[ -z "$identificador" ]]; then
			if readconf "ID/Nome não pode ser em branco. Cancelar?"; then
				return
			fi
		fi
		if [[ $identificador =~ ^[0-9]+$ ]]; then
			produto_info=$(seek produtos id "$identificador")
		else
			produto_info=$(seek produtos nome "$identificador")
		fi
		if [[ -z "$produto_info" ]]; then
			mensagem 2 "Produto não encontrado nos parâmetros informados" "$red"
			continue
		fi
		IFS='|' read -r produto_id produto_nome produto_unidade produto_quantidade produto_preco produto_codebar <<<"$produto_info"

		while true; do
			get 13 11 "Descrição            : " nome "$produto_nome"
			if [[ -n "$nome" ]]; then
				break
			else
				setpos 18 10
				if readconf "A descrição não pode ser em branco. Cancelar?"; then
					return
				fi
			fi
		done

		get 14 11 "Codigo Barras        : " codebar "$produto_codebar"
		get 15 11 "Unidade              : " un "$produto_unidade"

		# Solicita o preço como número inteiro ou decimal com ponto (ex: 4.40) e verifica se não está em branco
		while true; do
			get 16 11 "Preço (ex: 4.40 ou 5): " preco "$produto_preco"
			if [[ -n "$preco" ]] && [[ $preco =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
				break
			else
				mensagem 2 "Formato de preço inválido. Use ponto decimal (ex: 4.40) ou número inteiro." "$red"
			fi
		done

		setpos 18 10
		if readconf "Confirma inclusão/atualização do produto?"; then
			nome=${nome^^}
			un=${un^^}
			query="INSERT OR REPLACE INTO produtos (id, nome, un, preco, codebar) VALUES (
		        (SELECT id FROM produtos WHERE id='$produto_id'),
		        '$nome', '$un', $preco, $codebar
		    );"

			if sqlite3 "$database" "$query"; then
				mensagem 2 "Produto cadastrado/atualizado com sucesso!" "$green"
			else
				mensagem 2 "Erro no cadastro/atualização do produto." "$red"
			fi
		else
			mensagem 2 "Inclusão/alteração não efetuada." "$red"
		fi
	done
}

alterar_fornecedor() {
	local date_time=$(date +"%Y-%m-%d %H:%M:%S")
	local fornecedor_info
	local ultimo_registro

	while true; do
		fornecedor_info=
		ultimo_registro="$(lastrec 'fornecedor')"
		tela
		titulo 1 "ALTERAÇÃO DE FORNECEDOR" "$ciano"
		imprimir_quadro 11 10 8 80 "ALTERACÃO DE FORNECEDOR" "$ciano"
		print 10 11 "$ultimo_registro"
		print 12 11 "ID/Nome              : "
		print 13 11 "Nome                 : "
		print 14 11 "Endereco             : "
		print 15 11 "Cidade               : "
		print 16 11 "Estado               : "
		print 17 11 "Cnpj                 : "

		get 12 11 "ID/Nome              : " identificador
		setpos 19 10

		if [[ -z "$identificador" ]]; then
			if readconf "ID/Nome não pode ser em branco. Cancelar?"; then
				return
			fi
		fi
		if [[ $identificador =~ ^[0-9]+$ ]]; then
			fornecedor_info=$(seek fornecedor id "$identificador")
		else
			fornecedor_info=$(seek fornecedor nome "$identificador")
		fi
		if [[ -z "$fornecedor_info" ]]; then
			mensagem 2 "Fornecedor não encontrado nos parâmetros informados" "$red"
			continue
		fi
		IFS='|' read -r fornecedor_id fornecedor_data fornecedor_nome fornecedor_ende fornecedor_cida fornecedor_esta fornecedor_cnpj <<<"$fornecedor_info"

		while true; do
			get 13 11 "Nome                 : " nome "$fornecedor_nome"
			if [[ -n "$nome" ]]; then
				break
			else
				setpos 19 10
				if readconf "O nome não pode ser em branco. Cancelar?"; then
					return
				fi
			fi
		done

		get 14 11 "Endereco             : " ende "$fornecedor_ende"
		get 15 11 "Cidade               : " cida "$fornecedor_cida"
		get 16 11 "Estado               : " esta "$fornecedor_esta"
		get 17 11 "Cnpj                 : " cnpj "$fornecedor_cnpj"

		setpos 19 10
		if readconf "Confirma inclusão/atualização do fornecedor?"; then
			nome=${nome^^}
			ende=${ende^^}
			cida=${cida^^}
			esta=${esta^^}
			query="INSERT OR REPLACE INTO fornecedor (id,data, nome, ende, cida, esta, cnpj) VALUES (
		        (SELECT id FROM fornecedor WHERE id='$fornecedor_id'),
				'$date_time', '$nome', '$ende', '$cida', '$esta', '$cnpj'
			);"

			if sqlite3 "$database" "$query"; then
				mensagem 2 "Fornecedore cadastrado/atualizado com sucesso!" "$green"
			else
				mensagem 2 "Erro no cadastro/atualização do fornecedor" "$red"
			fi
		else
			mensagem 2 "Inclusão/alteração não efetuada." "$red"
		fi
	done
}

# Função para remover um produto do banco de dados
remover_produto() {
	local resultado

	while true; do
		tela
		titulo 1 "REMOÇÃO DE PRODUTO" "$ciano"
		imprimir_quadro 10 0 4 $(($(lastcol) - 1))

		get 11 01 "Digite o ID ou nome do produto que deseja remover: " identificador
		identificador=${identificador^^}

		if [[ -z "$identificador" ]]; then
			setpos 14 01
			if readconf "O ID não pode ser em branco. Cancelar?"; then
				return
			fi
		fi
		if [[ $identificador =~ ^[0-9]+$ ]]; then
			consulta_sql="SELECT * FROM produtos WHERE id='$identificador'"
			resultado="$(sqlite3 "$database" "$consulta_sql")"
		else
			consulta_sql="SELECT * FROM produtos WHERE nome='$identificador'"
			resultado="$(sqlite3 "$database" "$consulta_sql")"
		fi
		if [[ -n "$resultado" ]]; then
			print 12 01 "$resultado" "$azul"
			setpos 14 01
			if readconf "Confirma exclusão do produto?"; then
				# Verifica se o identificador é um número (ID) ou uma string (nome)
				if [[ $identificador =~ ^[0-9]+$ ]]; then
					query="DELETE FROM produtos WHERE id='$identificador';"
				else
					query="DELETE FROM produtos WHERE nome='$identificador';"
				fi
				sqlite3 "$database" "$query"
				mensagem 2 "Produtor removido com sucesso!" "$green"
			fi
		else
			mensagem 2 "Nenhum produto encontrado nos parâmetros informados" "$red" 10
		fi
	done
}

# Função para exibir as vendas diárias
exibir_vendas_diarias() {
	tela
	titulo 1 "TOTAL VENDAS DIÁRIAS" "$ciano"
	sqlite3 -column -header "$database" "SELECT date(data) AS DATA, SUM(total) AS 'TOTAL DIA' FROM vendas GROUP BY date(data) ORDER BY data DESC"
	mensagem 2 "" "$green" 10
}

pesquisar_produto() {
	while true; do
		tela
		titulo 1 "PESQUISAR PRODUTOS" "$ciano"
		imprimir_quadro 10 0 3 $(($(lastcol) - 1)) "PESQUISAR PRODUTOS" "$ciano"
		get 11 1 "Pesquisar por (nome, id ou *=tudo) : " produto

		[[ -z "$produto" ]] && return
		[[ "$produto" == "*" ]] && produto=

		if [[ $produto =~ ^[0-9]+$ ]]; then
			QUERY_SEARCH_PRODUCT="SELECT * FROM produtos WHERE id='$produto'"
		else
			QUERY_SEARCH_PRODUCT="SELECT * FROM produtos WHERE nome LIKE '%$produto%'"
		fi
		if resultado_sqlite=$(sqlite3 -column -header "$database" "$QUERY_SEARCH_PRODUCT") && [[ -n "$resultado_sqlite" ]]; then
			# Imprimir o resultado dentro do quadro
			#imprimir_quadro 13 0 $(($(lastrow)-3)) $(($(lastcol)-1))

			setpos 13 1
			nRow=13
			while IFS='|' read -r id nome un quantidade preco; do
				setpos $nRow 1
				printf "%-s %s %s %s %s" "$id" "$nome" "$un" "$quantidade" "$preco"
				((++nRow))
			done < <(tr '\t' '|' <<<"$resultado_sqlite")
			mensagem 2 "" "$green" 10
		else
			mensagem 2 "Nenhum produto encontrado nos parâmetros informados" "$red" 10
		fi
	done
}

listagem_produtos_vendidos() {
	while true; do
		tela
		titulo 1 "LISTAR PRODUTOS VENDIDOS" "$ciano"
		imprimir_quadro 10 0 3 $(($(lastcol) - 1)) "LISTAR PRODUTOS VENDIDOS" "$ciano"
		get 11 1 "Pesquisar por (id, docnr, data ou *=tudo) : " identificador

		[[ -z "$identificador" ]] && return
		[[ "$identificador" == "*" ]] && identificador=

		# por id
		if [[ $identificador =~ ^[0-9]+$ ]]; then
			query="SELECT vendas.docnr AS 'Doc. Número', produtos.nome AS 'Produto', vendas.quantidade AS 'Quantidade', vendas.preco AS 'Preço', vendas.total AS 'Total'
				FROM vendas
				JOIN produtos ON vendas.id = produtos.id
				WHERE vendas.id = '$identificador'
				ORDER BY vendas.docnr;"
			result=$(sqlite3 "$database" "$query")

		# por data
		elif [[ $identificador =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ || $identificador =~ ^[0-9]{2}-[0-9]{2}-[0-9]{4}$ || $identificador =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}$ ]]; then
			# Remove caracteres não numéricos da data de entrada
			identificador=$(echo "$identificador" | tr -cd '0-9')

			# Converte a data para o formato "2023-10-23" aceito pelo banco de dados
			if [[ ${#identificador} -eq 8 ]]; then
				data_banco="${identificador:4}-${identificador:2:2}-${identificador:0:2}"
			else
				mensagem 2 "Formato de data inválido." "$red"
				continue
			fi
			query="SELECT vendas.docnr AS 'Doc. Número', produtos.nome AS 'Produto', vendas.quantidade AS 'Quantidade', vendas.preco AS 'Preço', vendas.total AS 'Total'
				FROM vendas
				JOIN produtos ON vendas.id = produtos.id
				WHERE strftime('%Y-%m-%d', vendas.data) = '$data_banco'
				ORDER BY vendas.docnr;"
			result=$(sqlite3 "$database" "$query")

		# por docnr
		elif [[ $identificador =~ ^[0-9]{8}-[0-9]{8}$ ]]; then
			query="SELECT vendas.docnr AS 'Doc. Número', produtos.nome AS 'Produto', vendas.quantidade AS 'Quantidade', vendas.preco AS 'Preço', vendas.total AS 'Total'
				FROM vendas
				JOIN produtos ON vendas.id = produtos.id
				WHERE vendas.docnr = '$identificador'
				ORDER BY vendas.docnr;"
			result=$(sqlite3 "$database" "$query")

		# todos
		else
			query="SELECT vendas.docnr AS 'Doc. Número', produtos.nome AS 'Produto', vendas.quantidade AS 'Quantidade', vendas.preco AS 'Preço', vendas.total AS 'Total'
				FROM vendas
				JOIN produtos ON vendas.id = produtos.id
				ORDER BY vendas.docnr;"
			result=$(sqlite3 "$database" "$query")
		fi

		# Verifica se há dados no resultado da consulta
		if [ -n "$result" ]; then
			current_docnr=""
			while IFS='|' read -r docnr produto quantidade preco total; do
				if [[ "$docnr" != "$current_docnr" ]]; then
					echo
					echo "Doc. Número: $docnr"
					current_docnr="$docnr"
				fi
				total_formatado=$(echo "scale=2; $quantidade * $preco" | bc)
				printf "%-30s %-10s %-7s %-7s %-6s\n" "$produto" "$quantidade" "$preco" "$total_formatado" "$total"
			done <<<"$result"
			mensagem 2 "" "$green" 10
		else
			mensagem 2 "Nenhum produto vendido nos parâmetros informados" "$red" 10
		fi
	done
}

pesquisar_fornecedor() {
	local identificador
	local resultado_sqlite

	while true; do
		tela
		titulo 1 "PESQUISAR FORNECEDOR" "$ciano"
		imprimir_quadro 10 0 3 $(($(lastcol) - 1)) "PESQUISAR FORNECEDOR" "$ciano"
		get 11 1 "Pesquisar por (nome, id ou *=tudo) : " identificador

		[[ -z "$identificador" ]] && return
		[[ "$identificador" == "*" ]] && identificador=

		if [[ $identificador =~ ^[0-9]+$ ]]; then
			QUERY_SEARCH_PRODUCT="SELECT * FROM fornecedor WHERE id='$identificador'"
		else
			QUERY_SEARCH_PRODUCT="SELECT * FROM fornecedor WHERE nome LIKE '%$identificador%'"
		fi
		if resultado_sqlite=$(sqlite3 -column -header "$database" "$QUERY_SEARCH_PRODUCT") && [[ -n "$resultado_sqlite" ]]; then
			setpos 13 1
			nRow=13
			while IFS='|' read -r id data nome ende cida esta cnpj; do
				setpos $nRow 1
				printf "%-s %s %s %s %s %s %s" "$id" "$data" "$nome" "$ende" "$cida" "$esta" "$cnpj"
				((++nRow))
			done < <(tr '\t' '|' <<<"$resultado_sqlite")
			mensagem 2 "" "$green" 10
		else
			mensagem 2 "Nenhum fornecedor encontrado nos parâmetros informados" "$red" 10
		fi
	done
}

# Função para buscar informações do produto
buscar_produto() {
	local identificador="$1"
	local produto_info

	if [[ $identificador =~ ^[0-9]+$ ]]; then
		produto_info=$(sqlite3 "$database" "SELECT id, nome, quantidade, preco FROM produtos WHERE id='$identificador';")
	else
		produto_info=$(sqlite3 "$database" "SELECT id, nome, quantidade, preco FROM produtos WHERE nome LIKE '%$identificador%';")
	fi
	echo "$produto_info"
}

registrar_venda() {
	local total_venda="$1"
	local data_venda="$(date +"%Y-%m-%d %H:%M:%S")"
	local docnr="$(random_docnr)"

	for key in "${!lista_produtos[@]}"; do
		produto="${lista_produtos[$key]}"
		IFS='|' read -r id produto_nome quantidade valor <<<"$produto"
		sqlite3 "$database" "INSERT INTO vendas (id, data, quantidade, preco, total, docnr) VALUES ('$id', '$data_venda', '$quantidade', '$valor', '$total_venda', '$docnr');"
	done
	mensagem 2 "Registro de venda efetuado" "$green"
}

atualizar_estoque_vendas() {
	for key in "${!lista_produtos[@]}"; do
		produto="${lista_produtos[$key]}"
		IFS='|' read -r id produto_nome quantidade valor <<<"$produto"
		sqlite3 "$database" "UPDATE produtos SET quantidade = COALESCE(quantidade, 0) - $quantidade WHERE id='$id';"
	done
	mensagem 2 "Baixa de estoque efetuado" "$green"
}

# Função para realizar uma venda de múltiplos produtos
realizar_venda() {
	declare -A lista_produtos # Declarar um array associativo para armazenar produtos
	total_venda=0

	while true; do
		tela
		titulo 1 "VENDA" "$ciano"
		echo "==============================CUPOM PDV=============================="
		total_venda=0
		for key in "${!lista_produtos[@]}"; do
			produto="${lista_produtos[$key]}"
			IFS='|' read -r id produto_nome quantidade valor <<<"$produto"
			subtotal=$(echo "$quantidade * $valor" | bc -l | tr "." ",")
			valor_formatado=$(echo "$valor" | tr '.' ',')
			# Adicione espaços extras para alinhar os campos
			#			printf "${yellow}%s\t%s\t%s\t%8.2f\t%8.2f\n${reset}" "$id" "$produto_nome" "$quantidade" "$valor_formatado" "$subtotal"
			printf "${yellow}%2s  %-41s  %2s  %8.2f  %8.2f${reset}\n" "$id" "$produto_nome" "$quantidade" "$valor_formatado" "$subtotal"
			total_venda=$(echo "$total_venda + ( $quantidade * $valor)" | bc -l)
		done
		echo "====================================================================="
		printf "${red}%2s  %-41s  %2s  %8s  %8.2f${reset}\n" "" "SUBTOTAL R$" "" "" "$(tr '.' ',' <<<"$total_venda")"
		echo "====================================================================="

		read -p "ID/nome do produto (deixe em branco para concluir): " identificador
		identificador=${identificador^^}
		if [ -z "$identificador" ]; then
			break
		fi

		if produto_info=$(buscar_produto "$identificador") && [ -z "$produto_info" ]; then
			mensagem 2 "Produto não encontrado" "$red"
			continue
		fi
		IFS='|' read -r id produto_nome estoque valor <<<"$produto_info"

		# Solicita a quantidade e verifica se não está em branco
		read -p "Quantidade (0 para remover o item)                : " quantidade

		if [[ "$quantidade" = 0 ]]; then
			if [[ -v lista_produtos[$id] ]]; then
				unset lista_produtos[$id]
				continue
			else
				mensagem 2 "Quantidade inválida ou item não tem na lista" "$red"
				continue
			fi
		fi

		if [ "$estoque" -lt "$quantidade" ]; then
			mensagem 2 "Quantidade insuficiente de '$produto_nome' no estoque" "$red"
			continue
		fi
		subtotal=$(echo "$quantidade * $valor" | bc -l)

		# Atualiza o array associativo com informações do produto
		if [[ -v lista_produtos[$id] ]]; then
			# Se o produto já existe na lista, atualiza a quantidade
			produto="${lista_produtos[$id]}"
			IFS='|' read -r produto_id produto_nome produto_quantidade produto_valor <<<"$produto"
			nova_quantidade=$((produto_quantidade + quantidade))
			lista_produtos[$id]="$produto_id|$produto_nome|$nova_quantidade|$valor"
		else
			# Se o produto não existe na lista, adiciona
			lista_produtos[$id]="$id|$produto_nome|$quantidade|$valor"
		fi
		total_venda=$(echo "$total_venda + $subtotal" | bc -l)
	done

	if [[ "${#lista_produtos[@]}" -gt 0 ]]; then
		if readconf "Confirma o fetchamento do CUPOM?"; then
			registrar_venda "$total_venda"
			atualizar_estoque_vendas
		fi
	fi
}

registrar_compra() {
	local total_compra="$1"
	local data_compra=$(date +"%Y-%m-%d %H:%M:%S")
	local fornecedor="${notafiscal[fornecedor]}"
	local docnr="${notafiscal[docnr]}"

	# Itera sobre os produtos vendidos no array associativo
	for key in "${!lista_produtos[@]}"; do
		produto="${lista_produtos[$key]}"
		IFS='|' read -r id produto_nome quantidade custo <<<"$produto"
		sqlite3 "$database" "INSERT INTO compras (id, fornecedor, data, docnr, quantidade, custo, total) VALUES ('$id', '$fornecedor', '$data_compra', '$docnr', '$quantidade', '$custo','$total_compra');"
	done
	mensagem 2 "Registro de entradas efetuado" "$green"
}

atualizar_estoque_compras() {
	# Iterar sobre os elementos do array lista_produtos
	for key in "${!lista_produtos[@]}"; do
		produto="${lista_produtos[$key]}"
		IFS='|' read -r id nome quantidade custo <<<"$produto"
		sqlite3 "$database" "UPDATE produtos SET quantidade = COALESCE(quantidade, 0) + $quantidade WHERE id=$id;"
	done
	mensagem 2 "Ajuste de estoque efetuado" "$green"
}

buscar_fornecedor() {
	local identificador="$1"
	local fornecedor_info

	if [[ $identificador =~ ^[0-9]+$ ]]; then
		fornecedor_info=$(sqlite3 "$database" "SELECT id, nome, ende, cida, esta, cnpj FROM fornecedor WHERE id='$identificador';")
	else
		fornecedor_info=$(sqlite3 "$database" "SELECT id, nome, ende, cida, esta, cnpj FROM fornecedor WHERE nome LIKE '%$identificador%';")
	fi
	echo "$fornecedor_info"
}

entrada_produtos() {
	declare -gA lista_produtos=() # Declarar um array associativo para armazenar produtos
	declare -gA notafiscal=()
	total_compra=0

	while true; do
		tela
		titulo 1 "ENTRADAS DE PRODUTOS" "$ciano"
		imprimir_quadro 11 00 4 70 "DADOS DA NFF" "$ciano"
		# Solicita a descrição (nome) do produto e verifica se não está em branco
		print 12 01 "Fornecedor : "
		print 13 01 "Docnr/NFF  : "

		while true; do
			get 12 01 "Fornecedor : " identificador
			identificador=${identificador^^}
			if [[ -n "$identificador" ]]; then
				break
			else
				setpos 15 10
				if readconf "O ID/nome não pode ser em branco. Cancelar?"; then
					return
				fi
			fi
		done
		if fornecedor_info=$(buscar_fornecedor "$identificador") && [ -z "$fornecedor_info" ]; then
			mensagem 2 "Fornecedor não encontrado" "$red"
			continue
		fi
		IFS='|' read -r id nome ende cida esta cnpj <<<"$fornecedor_info"
		print 10 01 "${azul}${nome}${reset}"
		get 13 01 "Docnr/NFF  : " docnr
		notafiscal=([fornecedor]="$id" [nome]="$nome" [docnr]="$docnr")
		break
	done

	while true; do
		clear_eol 15 "$(($(lastrow) - 4))"
		setpos 15 00
		echo "========================RELAÇAO DAS ENTRADAS========================="
		total_compra=0
		for key in "${!lista_produtos[@]}"; do
			produto="${lista_produtos[$key]}"
			IFS='|' read -r id produto_nome quantidade custo <<<"$produto"
			subtotal=$(echo "$quantidade * $custo" | bc -l | tr "." ",")
			custo_formatado=$(echo "$custo" | tr '.' ',')
			# Adicione espaços extras para alinhar os campos
			printf "${yellow}%2s  %-41s  %2s  %8.2f  %8.2f${reset}\n" "$id" "$produto_nome" "$quantidade" "$custo_formatado" "$subtotal"
			total_compra=$(echo "$total_compra + ( $quantidade * $custo)" | bc -l)
		done
		echo "====================================================================="
		printf "${red}%2s  %-41s  %2s  %8s  %8.2f${reset}\n" "" "SUBTOTAL R$" "" "" "$(tr '.' ',' <<<"$total_compra")"
		echo "====================================================================="

		read -p "ID/nome do produto (deixe em branco para concluir): " identificador
		identificador=${identificador^^}
		if [ -z "$identificador" ]; then
			break
		fi

		if produto_info=$(buscar_produto "$identificador") && [ -z "$produto_info" ]; then
			mensagem 2 "Produto não encontrado" "$red"
			continue
		fi
		IFS='|' read -r id produto_nome estoque preco <<<"$produto_info"
		echo -e "$azul$produto_nome$reset"

		# Solicita a quantidade e verifica se não está em branco
		read -p "Quantidade (0 para remover o item)                : " quantidade

		if [[ "$quantidade" = 0 ]]; then
			if [[ -v lista_produtos[$id] ]]; then
				unset lista_produtos[$id]
				continue
			else
				mensagem 2 "Quantidade inválida ou item não tem na lista" "$red"
				continue
			fi
		fi

		# Solicita o preço como número inteiro ou decimal com ponto (ex: 4.40) e verifica se não está em branco
		while true; do
			read -p "Preço custo (ex: 4.40 ou 5)                       : " custo
			if [[ -n "$custo" ]] && [[ $custo =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
				break
			else
				mensagem 2 "Formato de preço inválido. Use ponto decimal (ex: 4.40) ou número inteiro." "$red"
			fi
		done
		subtotal=$(echo "$quantidade * $custo" | bc -l)

		# Atualiza o array associativo com informações do produto
		if [[ -v lista_produtos[$id] ]]; then
			# Se o produto já existe na lista, atualiza a quantidade
			produto="${lista_produtos[$id]}"
			IFS='|' read -r produto_id produto_nome produto_quantidade produto_custo <<<"$produto"
			nova_quantidade=$((produto_quantidade + quantidade))
			lista_produtos[$id]="$produto_id|$produto_nome|$nova_quantidade|$custo"
		else
			# Se o produto não existe na lista, adiciona
			lista_produtos[$id]="$id|$produto_nome|$quantidade|$custo"
		fi
		total_compra=$(echo "$total_venda + $subtotal" | bc -l)
	done

	if [[ "${#lista_produtos[@]}" -gt 0 ]]; then
		if readconf "Confirma a entrada desses produtos?"; then
			registrar_compra "$total_compra"
			atualizar_estoque_compras
		fi
	fi
}

menu_fornecedores() {
	while true; do
		tela
		titulo 1 "MENU FORNECEDORES" "$ciano"
		imprimir_quadro 11 10 8 80 "MENU FORNECEDORES" "$azul"
		print 12 11 " 1 - Cadastrar Fornecedor"
		print 13 11 " 2 - Alterar Fornecedor"
		print 14 11 " 3 - Pesquisar Fornecedor"
		print 15 11 " 0 - Voltar"
		get 17 12 "Opção: " opcao

		case "$opcao" in
		1)
			adicionar_fornecedor
			;;
		2)
			alterar_fornecedor
			;;
		3)
			pesquisar_fornecedor
			;;
		*)
			return
			;;
		esac
	done
}

menu_produtos() {
	while true; do
		tela
		titulo 1 "MENU PRODUTOS" "$ciano"
		imprimir_quadro 11 10 11 80 "MENU PRODUTOS" "$azul"
		print 12 11 " 1 - Cadastrar Produtos"
		print 13 11 " 2 - Alterar Produtos"
		print 14 11 " 3 - Remover Produtos"
		print 15 11 " 4 - Pesquisar Produtos"
		print 16 11 " 5 - Atualizar Estoque (conciliação)"
		print 17 11 " 6 - Listagem Produtos Vendidos"
		print 18 11 " 0 - Voltar"
		get 20 12 "Opção: " opcao

		case "$opcao" in
		1)
			adicionar_produto
			;;
		2)
			alterar_produto
			;;
		3)
			remover_produto
			;;
		4)
			pesquisar_produto
			;;
		5)
			conciliar_estoque
			;;
		6)
			listagem_produtos_vendidos
			;;
		*)
			return
			;;
		esac
	done
}

conciliar_estoque() {
	setpos 22 11
	if readconf "Confirma a atualização?"; then
		mensagem 2 "Aguarde... Atualizando estoque" "$red"

		sqlite3 estoque.db "UPDATE produtos
	SET quantidade = 0
	WHERE produtos.id IN (
    	SELECT produtos.id
	    FROM produtos
	    LEFT JOIN compras ON produtos.id = compras.id
	    GROUP BY produtos.id
	);"

		sqlite3 estoque.db "UPDATE produtos
	SET quantidade = quantidade + (
    	SELECT SUM(compras.quantidade)
	    FROM compras
	    WHERE produtos.id = compras.id
	)
	WHERE produtos.id IN (
    	SELECT produtos.id
	    FROM produtos
	    LEFT JOIN compras ON produtos.id = compras.id
	    GROUP BY produtos.id
	);"

		sqlite3 estoque.db "UPDATE produtos
	SET quantidade = quantidade - (
	    SELECT SUM(vendas.quantidade)
	    FROM vendas
	    WHERE produtos.id = vendas.id
	)
	WHERE produtos.id IN (
	    SELECT produtos.id
	    FROM produtos
	    LEFT JOIN vendas ON produtos.id = vendas.id
	    GROUP BY produtos.id
	);"
		mensagem 2 "Atualização concluída" "$green"
	fi
}

soma_teste() {
	sqlite3 estoque.db "SELECT produtos.nome, SUM(compras.quantidade) AS total_compras
	FROM produtos
	LEFT JOIN compras ON produtos.id = compras.id
	GROUP BY produtos.nome;"

	sqlite3 estoque.db "SELECT p.nome,
                            SUM(c.quantidade) AS total_compras,
                            SUM(v.quantidade) AS total_vendas
                    FROM produtos AS p
                    LEFT JOIN (SELECT id, SUM(quantidade) AS quantidade
                               FROM compras GROUP BY id) AS c ON p.id = c.id
                    LEFT JOIN (SELECT id, SUM(quantidade) AS quantidade
                               FROM vendas GROUP BY id) AS v ON p.id = v.id
                    GROUP BY p.nome;"
}

sh_criar_tabelas() {
	criar_tabela_produtos
	criar_tabela_vendas
	criar_tabela_compras
	criar_tabela_fornecedor
}

sh_manutencao_tabelas() {
	#	sqlite3 "$database" "DROP TABLE produtos;"
	#	sqlite3 "$database" "DROP TABLE vendas;"
	#	sqlite3 "$database" "DROP TABLE fornecedor;"
	#	sqlite3 "$database" "DROP TABLE compras;"
	:
}

sh_show_tabelas() {
	sqlite3 "$database" "SELECT * FROM produtos;"
	sqlite3 "$database" "SELECT * FROM fornecedor;"
	sqlite3 "$database" "SELECT * FROM vendas;"
	sqlite3 "$database" "SELECT * FROM compras;"
	inkey 10
}

random_docnr() {
	date "+%Y%m%d-%H%M%S"
}

# menu principal
main() {
	while true; do
		tela
		titulo 1 "MENU PRINCIPAL" "$ciano"
		imprimir_quadro 11 10 10 80 "MENU PRINCIPAL" "$azul"
		print 12 11 " 1 - Produtos"
		print 13 11 " 2 - Realizar Venda"
		print 14 11 " 3 - Exibir Vendas Diárias"
		print 15 11 " 4 - Entradas de Produtos"
		print 16 11 " 5 - Fornecedores"
		print 17 11 " 0 - Sair"
		get 19 12 "Opção: " opcao

		case "$opcao" in
		1)
			menu_produtos
			;;
		2)
			realizar_venda
			;;
		3)
			exibir_vendas_diarias
			;;
		4)
			entrada_produtos
			;;
		5)
			menu_fornecedores
			;;

		0)
			echo "Saindo do programa."
			exit 0
			;;
		*)
			mensagem 2 "Opção inválida. Tente novamente." "$red"
			;;
		esac
	done
}
# END PROCEDURES

sh_config
sh_checkDependencies
sh_criar_tabelas
main
