#!/bin/bash
#####################################################################
# Autor: Slackjeff
# Descrição: Programinha simples para PDV de mercearia
# Faz as seguintes funcionalidades:
#
# * Adiciona produtos no banco
# * Faz venda
# * Remove uma venda
# * Da o subtotal
# * Visualiza a venda mensal.
#
# Depende de:
# sqlite
#####################################################################

# Cores para formatação de texto
cor_vermelha=$(tput setaf 1)
cor_verde=$(tput setaf 2)
cor_amarela=$(tput setaf 3)
cor_reset=$(tput sgr0)

logo() {
cat << 'EOF'
  __  __                              _
 |  \/  |                            (_)
 | \  / | ___ _ __ ___ ___  __ _ _ __ _  __ _
 | |\/| |/ _ \ '__/ __/ _ \/ _` | '__| |/ _` |
 | |  | |  __/ | | (_|  __/ (_| | |  | | (_| |
 |_|  |_|\___|_|  \___\___|\__,_|_|  |_|\__,_|
EOF
echo " Hoje dia $(date "+%d/%m/%Y")"
echo
}

# Função para criar a tabela de produtos se não existir
criar_tabela_produtos() {
  sqlite3 estoque.db <<EOF
  CREATE TABLE IF NOT EXISTS produtos (
    id INTEGER PRIMARY KEY,
    nome TEXT,
    quantidade INTEGER,
    preco REAL
  );
EOF
}

# Criar a tabela de vendas
criar_tabela_vendas() {
  sqlite3 estoque.db <<EOF
  CREATE TABLE IF NOT EXISTS vendas (
    id INTEGER PRIMARY KEY,
    data DATE,
    total REAL
  );
EOF
}

# Função para adicionar um novo produto ao banco de dados ou atualizar a quantidade se o produto já existir
adicionar_produto() {
  clear
  echo "==================== CADASTRO DE PRODUTO ===================="
  read -p "Nome: " nome
  nome=${nome,,}
  read -p "Quantidade: " quantidade
  read -p "Preço: " preco

  sqlite3 estoque.db <<EOF
  INSERT OR REPLACE INTO produtos (id, nome, quantidade, preco)
  VALUES ((SELECT id FROM produtos WHERE nome="$nome"), "$nome", COALESCE((SELECT quantidade FROM produtos WHERE nome="$nome"), 0) + $quantidade, $preco);
EOF

  echo "${cor_verde}Produto cadastrado/atualizado com sucesso!${cor_reset}"
  pressione_para_continuar
}

# Função para remover um produto do banco de dados
remover_produto() {
  clear
  echo "==================== REMOÇÃO DE PRODUTO ====================="
  read -p "Digite o ID ou nome do produto que deseja remover: " identificador
  identificado=${identificador,,}
  # Verifica se o identificador é um número (ID) ou uma string (nome)
  if [[ $identificador =~ ^[0-9]+$ ]]; then
    sqlite3 estoque.db <<EOF
    DELETE FROM produtos WHERE id=$identificador;
EOF
  else
    sqlite3 estoque.db <<EOF
    DELETE FROM produtos WHERE nome="$identificador";
EOF
  fi

  echo "${cor_verde}Produto removido com sucesso!${cor_reset}"
  pressione_para_continuar
}

# Função para realizar uma venda de múltiplos produtos
realizar_venda() {
  # Reinicia o valor total da venda
  total_venda=0

  lista_produtos=()

  while true; do
    clear
    echo "============================ VENDA ==========================="
    echo "Produtos na venda:"
    for produto in "${lista_produtos[@]}"; do
      IFS=',' read -r produto_nome quantidade subtotal <<< "$produto"
      echo "${cor_amarela}$produto_nome - Quantidade: $quantidade - Subtotal: R$ $subtotal${cor_reset}"
    done
    echo
    echo "------------------------------------------------------------"
    echo "========> SUBTOTAL: R$ $total_venda"
    echo "------------------------------------------------------------"
    echo

    read -p "Digite o ID ou nome do produto que deseja vender (ou deixe em branco para concluir a venda): " identificador
    identificador=${identificador,,}

    if [ -z "$identificador" ]; then
      break
    fi

    read -p "Quantidade: " quantidade

    # Verifica se o identificador é um número (ID) ou uma string (nome)
    if [[ $identificador =~ ^[0-9]+$ ]]; then
      # Busca o produto pelo ID
      produto_nome=$(sqlite3 estoque.db "SELECT nome FROM produtos WHERE id=$identificador;")
    else
      # Busca o produto pelo nome
      produto_nome=$identificador
    fi

    # Verifica se o produto existe e se há quantidade suficiente no estoque
    quantidade_disponivel=$(sqlite3 estoque.db "SELECT quantidade FROM produtos WHERE nome='$produto_nome';")
    if [ -z "$quantidade_disponivel" ]; then
      echo "${cor_vermelha}Produto '$produto_nome' não encontrado no estoque.${cor_reset}"
      pressione_para_continuar
      continue
    fi

    if [ "$quantidade_disponivel" -lt "$quantidade" ]; then
      echo "${cor_vermelha}Quantidade insuficiente de '$produto_nome' no estoque.${cor_reset}"
      pressione_para_continuar
      continue
    fi

    # Calcula o valor total da venda para esse produto
    preco_unitario=$(sqlite3 estoque.db "SELECT preco FROM produtos WHERE nome='$produto_nome';")
    subtotal=$(echo "$preco_unitario * $quantidade" | bc)

    # Atualiza a quantidade no estoque
    sqlite3 estoque.db "UPDATE produtos SET quantidade = quantidade - $quantidade WHERE nome='$produto_nome';"

    # Verifica se o produto já existe na lista de produtos vendidos
    produto_encontrado=0
    for i in "${!lista_produtos[@]}"; do
      IFS=',' read -r lista_produto_nome lista_quantidade lista_subtotal <<< "${lista_produtos[$i]}"
      if [ "$lista_produto_nome" == "$produto_nome" ]; then
        lista_quantidade=$((lista_quantidade + quantidade))
        lista_subtotal=$(echo "$preco_unitario * $lista_quantidade" | bc)
        lista_produtos[$i]="$produto_nome,$lista_quantidade,$lista_subtotal"
        produto_encontrado=1
        break
      fi
    done

    if [ "$produto_encontrado" -eq 0 ]; then
      lista_produtos+=("$produto_nome,$quantidade,$subtotal")
    fi

    total_venda=$(echo "$total_venda + $subtotal" | bc)
  done

  echo "Total da venda: R$ $total_venda"

  # Registra a venda no banco de dados
  registrar_venda "$total_venda"

  # Pergunta se deseja remover unidades de venda
  while true; do
    clear
    echo "================= REMOVER UNIDADE DE VENDA ==================="
    echo "Lista de produtos na venda:"
    for i in "${!lista_produtos[@]}"; do
      IFS=',' read -r produto_nome quantidade subtotal <<< "${lista_produtos[$i]}"
      echo "${cor_amarela}$i - $produto_nome - Quantidade: $quantidade - Subtotal: R$ $subtotal${cor_reset}"
    done

    echo
    echo "------------------------------------------------------------"
    echo "SUBTOTAL: R$ $total_venda"
    echo "------------------------------------------------------------"
    echo

    read -p "Informe o número do produto que deseja remover da venda (ou deixe em branco para sair): " escolha

    if [ -z "$escolha" ]; then
      break
    fi

    if [[ ! "$escolha" =~ ^[0-9]+$ ]] || [ "$escolha" -ge "${#lista_produtos[@]}" ]; then
      echo "${cor_vermelha}Opção inválida. Tente novamente.${cor_reset}"
      pressione_para_continuar
      continue
    fi

    IFS=',' read -r produto_nome quantidade subtotal <<< "${lista_produtos[$escolha]}"
    if [ "$quantidade" -gt 1 ]; then
      # Se houver mais de uma unidade do produto, apenas diminua a quantidade
      lista_quantidade=$((quantidade - 1))
      lista_subtotal=$(echo "$preco_unitario * $lista_quantidade" | bc)
      lista_produtos[$escolha]="$produto_nome,$lista_quantidade,$lista_subtotal"
    else
      # Se houver apenas uma unidade do produto, remova-o da lista
      unset lista_produtos[$escolha]
      lista_produtos=("${lista_produtos[@]}")  # Remove o elemento vazio
    fi
    total_venda=$(echo "$total_venda - $preco_unitario" | bc)
    echo "${cor_verde}Uma unidade de '$produto_nome' removida da venda.${cor_reset}"
    pressione_para_continuar
  done

  echo "TOTAL DA VENDA ATUALIZADO: R$ $total_venda"
  pressione_para_continuar
}


# Função para exibir as vendas diarias
exibir_vendas_diarias() {
  clear
  echo "==================== TOTAL VENDAS DIARIAS  ====================="
  sqlite3 -column -header estoque.db "SELECT date(data), SUM(total) AS subtotal FROM vendas GROUP BY date(data) ORDER BY date(data) DESC"
  pressione_para_continuar
}

# Função para registrar uma venda no banco de dados
registrar_venda() {
  data=$(date +%Y-%m-%d)
  total=$1

  sqlite3 estoque.db <<EOF
  INSERT INTO vendas (data, total) VALUES ("$data", $total);
EOF
}

# Função para visualizar todos os produtos cadastrados em formato de tabela
visualizar_produtos() {
  clear
  echo "================== LISTA DE PRODUTOS CADASTRADOS ================="
  echo "Opções de busca:"
  echo "1. Buscar por ID"
  echo "2. Buscar por Nome"
  echo "3. Mostrar todos os produtos"
  read -p "Escolha uma opção de busca: " busca_opcao

  case $busca_opcao in
    1)
      read -p "Digite o ID do produto que deseja buscar: " produto_id
      sqlite3 -column -header -separator " | " estoque.db <<EOF
      SELECT id, nome, quantidade, preco FROM produtos WHERE id=$produto_id;
EOF
      ;;
    2)
      read -p "Digite o nome do produto que deseja buscar: " produto_nome
      produto_nome=${produto_nome,,}
      sqlite3 -column -header -separator " | " estoque.db <<EOF
      SELECT id, nome, quantidade, preco FROM produtos WHERE nome LIKE '%$produto_nome%';
EOF
      ;;
    3)
      sqlite3 -column -header -separator " | " estoque.db <<EOF
      SELECT id, nome, quantidade, preco FROM produtos;
EOF
      ;;
    *)
      echo "${cor_vermelha}Opção inválida.${cor_reset}"
#      sqlite3 -separator " | " estoque.db <<EOF
#      SELECT id, nome, quantidade, preco FROM produtos;
#EOF
      ;;
  esac

  pressione_para_continuar
}




pesquisar_produto() {
    clear
  read -p "Digite o nome do produto que deseja pesquisar: " produto

  # Consulta SQL para pesquisar o produto pelo nome
  QUERY_SEARCH_PRODUCT="SELECT id, nome, quantidade, preco FROM produtos WHERE nome LIKE '%$produto%'"

  echo "Resultado da pesquisa:"
  echo "-------------------------------------------------------------------"

  sqlite3 -column -header -separator "|" "estoque.db" "$QUERY_SEARCH_PRODUCT"
  pressione_para_continuar
}


# Função para pausar a execução e aguardar um pressionamento de tecla
pressione_para_continuar() {
  echo ""
  read -n 1 -s -p "========> Pressione qualquer tecla para continuar..."
}

# Função principal
main() {
    if [ -f $(which sqlite3) ]; then
  criar_tabela_produtos
  criar_tabela_vendas

  while true; do
    clear
    logo
    echo "Escolha uma opção:"
    echo " (1) Adicionar Novo Produto"
    echo " (2) Remover Produto"
    echo " (3) Realizar Venda"
    echo " (4) Visualizar Todos Produtos"
    echo " (5) Exibir vendas Diarias"
    echo " (6) Pesquisar Produtos"
    echo " (7) Sair"
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
        visualizar_produtos
        ;;
      5)
        exibir_vendas_diarias
      ;;
      6)
        pesquisar_produto
      ;;
      7)
        echo "Saindo do programa."
        exit 0
        ;;
      *)
        echo "${cor_vermelha}Opção inválida. Tente novamente.${cor_reset}"
        pressione_para_continuar
        ;;
    esac
  done
else
    echo "Você precisa instalar sqlite3";
    fi
}

main
