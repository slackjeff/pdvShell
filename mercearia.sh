#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1091,SC2039,SC2166,SC2162,SC2155,SC2005,SC2034

#TODO
# - traducao para vários idiomas
# - listagem de fornecedores
# - listagem de entrada de produtos

export TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAIN=mercearia

declare APP="${0##*/}"
declare _VERSION_="1.0.0-20231020"
declare DEPENDENCIES=(tput gettext sqlite3)
declare database='estoque.db'

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

function run_cmd {
	info_msg "$APP: $(gettext "Rodando") $*"
	eval "$@"
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
        preco REAL
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
        total REAL
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
	linha="$1"
	col="$2"
	altura="$3"
	largura="$4"
	mensagem="$5"
	color="$6"
	tamanho=$((largura-2))
	local largura_mensagem=${#mensagem}
	local coluna_inicio=$(((largura - largura_mensagem ) / 2 + col ))

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
		setpos "$linha" "$((col+1))"
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

	setpos "$row" "$col"
	read -p "$msg$reverse" "$prompt"
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

# Função para adicionar um novo produto ao banco de dados ou atualizar o quantidade se o produto já existir
adicionar_produto() {
	while true; do
		consulta_sql="SELECT * FROM produtos ORDER BY id DESC LIMIT 1;"
		resultado="$(sqlite3 "$database" "$consulta_sql")"
		tela
		titulo 1 "CADASTRO DE PRODUTO" "$ciano"
		imprimir_quadro 11 10 6 80 "CADASTRO DE PRODUTO" "$ciano"

		# Solicita a descrição (nome) do produto e verifica se não está em branco
		print 10 11 "$resultado"
		print 12 11 "Descrição            : "
		print 13 11 "Unidade              : "
		print 14 11 "Quantidade           : "
		print 15 11 "Preço (ex: 4.40 ou 5): "

		while true; do
			get 12 11 "Descrição            : " nome
			if [[ -n "$nome" ]]; then
				break
			else
				setpos 17 10
				if readconf "A descrição não pode ser em branco. Cancelar?"; then
					return
				fi
			fi
		done

		while true; do
			get 13 11 "Unidade              : " un
			if [[ -n "$un" ]]; then
				break
			else
				setpos 17 10
				if readconf "A unidade não pode ser em branco. Cancelar?"; then
					return
				fi
			fi
		done

		# Solicita a quantidade e verifica se não está em branco
		while true; do
			get 14 11 "Quantidade           : " quantidade
			if [[ -n "$quantidade" ]]; then
				break
			else
				mensagem 2 "A quantidade não pode ser em branco." "$red"
			fi
		done

		# Solicita o preço como número inteiro ou decimal com ponto (ex: 4.40) e verifica se não está em branco
		while true; do
			get 15 11 "Preço (ex: 4.40 ou 5): " preco
			if [[ -n "$preco" ]] && [[ $preco =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
				break
			else
				mensagem 2 "Formato de preço inválido. Use ponto decimal (ex: 4.40) ou número inteiro." "$red"
			fi
		done

		setpos 17 10
		if readconf "Confirma inclusão/atualização do produto?"; then
			nome=${nome^^}
			un=${un^^}
			query="INSERT OR REPLACE INTO produtos (id, nome, un, quantidade, preco) VALUES (
            (SELECT id FROM produtos WHERE nome='$nome'),
            '$nome', '$un',
            COALESCE((SELECT quantidade FROM produtos WHERE nome='$nome'), 0) + $quantidade,
            $preco
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
	local data_venda=$(date +"%Y-%m-%d %H:%M:%S")

	# Itera sobre os produtos vendidos no array associativo
	for key in "${!lista_produtos[@]}"; do
		produto="${lista_produtos[$key]}"
		IFS='|' read -r id produto_nome quantidade valor <<<"$produto"
		sqlite3 "$database" "INSERT INTO vendas (id, data, quantidade, preco, total) VALUES ('$id', '$data_venda', '$quantidade', '$valor', '$total_venda');"
	done
	mensagem 2 "Registro de venda efetuado" "$green"
}

atualizar_estoque() {
	# Iterar sobre os elementos do array lista_produtos
	for key in "${!lista_produtos[@]}"; do
		produto="${lista_produtos[$key]}"
		IFS='|' read -r id produto_nome quantidade valor <<<"$produto"
		sqlite3 "$database" "UPDATE produtos SET quantidade = quantidade - $quantidade WHERE id='$id';"
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
		if readconf "Confirma a saida desses produtos?"; then
			registrar_venda "$total_venda"
			atualizar_estoque
		fi
	fi
}

cadastrar_fornecedor() {
	local date_time=$(date +"%Y-%m-%d %H:%M:%S")

	while true; do
		consulta_sql="SELECT * FROM fornecedor ORDER BY id DESC LIMIT 1;"
		resultado="$(sqlite3 "$database" "$consulta_sql")"
		tela
		titulo 1 "CADASTRO DE FORNECEDOR" "$ciano"
		imprimir_quadro 11 10 7 80 "CADASTRO DE FORNECEDOR" "$ciano"

		# Solicita a descrição (nome) do produto e verifica se não está em branco
		print 10 11 "$resultado"
		print 12 11 "Nome                 : "
		print 13 11 "Endereco             : "
		print 14 11 "Cidade               : "
		print 15 11 "Estado               : "
		print 16 11 "Cnpj                 : "

		while true; do
			get 12 11 "Nome                 : " nome
			if [[ -n "$nome" ]]; then
				break
			else
				setpos 18 10
				if readconf "O nome não pode ser em branco. Cancelar?"; then
					return
				fi
			fi
		done

		while true; do
			get 13 11 "Endereco             : " ende
			if [[ -n "$ende" ]]; then
				break
			else
				setpos 17 10
				if readconf "O Endereco não pode ser em branco. Cancelar?"; then
					return
				fi
			fi
		done

		while true; do
			get 14 11 "Cidade               : " cida
			if [[ -n "$cida" ]]; then
				break
			else
				mensagem 2 "A cidade não pode ser em branco." "$red"
			fi
		done

		while true; do
			get 15 11 "Estado               : " esta
			if [[ -n "$esta" ]]; then
				break
			else
				mensagem 2 "A UF não pode ser em branco." "$red"
			fi
		done

		# Solicita o preço como número inteiro ou decimal com ponto (ex: 4.40) e verifica se não está em branco
		while true; do
			get 16 11 "Cnpj                 : " cnpj
			if [[ -n "$cnpj" ]]; then
				break
			else
				mensagem 2 "Formato do cnpj inválido. Use ponto decimal (ex: 00.000.000/0000-00)" "$red"
			fi
		done

		setpos 18 10
		if readconf "Confirma inclusão/atualização do fornecedor?"; then
			nome=${nome^^}
			ende=${ende^^}
			cida=${cida^^}
			esta=${esta^^}
			query="INSERT OR REPLACE INTO fornecedor (data, nome, ende, cida, esta, cnpj) VALUES ('$date_time', '$nome', '$ende', '$cida', '$esta', '$cnpj');"
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

registrar_compra() {
	local total_compra="$1"
	local data_compra=$(date +"%Y-%m-%d %H:%M:%S")
	local fornecedor="${notafiscal[fornecedor]}"
	local docnr="${notafiscal[docnr]}"

	# Itera sobre os produtos vendidos no array associativo
	for key in "${!lista_produtos[@]}"; do
		produto="${lista_produtos[$key]}"
		IFS='|' read -r id produto_nome quantidade custo<<<"$produto"
		sqlite3 "$database" "INSERT INTO compras (id, fornecedor, data, docnr, quantidade, custo, total) VALUES ('$id', '$fornecedor', '$data_compra', '$docnr', '$quantidade', '$custo','$total_compra');"
	done
	mensagem 2 "Registro de entradas efetuado" "$green"
}

atualizar_estoque_compras() {
	# Iterar sobre os elementos do array lista_produtos
	for key in "${!lista_produtos[@]}"; do
		produto="${lista_produtos[$key]}"
		IFS='|' read -r id produto_nome quantidade custo <<<"$produto"
		sqlite3 "$database" "UPDATE produtos SET quantidade = quantidade + $quantidade WHERE id='$id';"
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

clear_eol() {
	local coluna_inicial="$1"
	local coluna_final="$2"

	# Posiciona o cursor na coluna_inicial
	echo -en "\033[6;${coluna_inicial}H"

	# Limpa o conteúdo até a coluna_final
	for ((i=$coluna_inicial; i<=$coluna_final; i++)); do
		setpos $i 0
		tput el
	done

	# Retorna o cursor para a posição inicial
	echo -en "\033[6;${coluna_inicial}H"
}

entrada_produtos() {
	declare -gA lista_produtos=() # Declarar um array associativo para armazenar produtos
	declare -gA notafiscal=()
	total_compra=0

	while true ; do
		tela
		titulo 1 "ENTRADA DE PRODUTOS" "$ciano"
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
		clear_eol 15 "$(( $(lastrow) - 4 ))"
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

# Função principal
main() {
	while true; do
		tela
		titulo 1 "MENU PRINCIPAL" "$ciano"
		echo " 1 - Adicionar Novo Produto"
		echo " 2 - Remover Produto"
		echo " 3 - Realizar Venda"
		echo " 4 - Exibir Vendas Diárias"
		echo " 5 - Pesquisar Produtos"
		echo " 6 - Entrada de Produtos"
		echo " 7 - Cadastrar Fornecedor"
		echo " 0 - Sair"
		echo ""
		read -p "Opção: " opcao

		case $opcao in
		1)
			adicionar_produto
			;;
		2)
			remover_produto
			;;
		3)
			realizar_venda
			;;
		4)
			exibir_vendas_diarias
			;;
		5)
			pesquisar_produto
			;;
		6)
			entrada_produtos
			;;
		7)
			cadastrar_fornecedor
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

sh_config
sh_checkDependencies
criar_tabela_produtos
#sqlite3 "$database" "DROP TABLE vendas;"
#sqlite3 "$database" "DROP TABLE fornecedor;"
#sqlite3 "$database" "DROP TABLE compras;"
criar_tabela_vendas
criar_tabela_compras
criar_tabela_fornecedor
#sqlite3 "$database" "SELECT * FROM produtos;"
#sqlite3 "$database" "SELECT * FROM vendas;"
#sqlite3 "$database" "SELECT * FROM fornecedor;"
#sqlite3 "$database" "SELECT * FROM compras;"
#inkey 10
main

