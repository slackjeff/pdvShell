# 🧾 PDVShell

<p align="center">
  <img src="assets/demo.gif" alt="PDVShell Demo" width="700"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/shell-bash-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/database-sqlite-lightgrey?style=flat-square"/>
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square"/>
  <img src="https://img.shields.io/badge/platform-linux-orange?style=flat-square"/>
  <img src="https://img.shields.io/badge/focus-low--end%20systems-red?style=flat-square"/>
</p>

---

## 📌 Sobre

**PDVShell** é um sistema de frente de caixa (PDV) leve e eficiente, desenvolvido em **Shell Script + SQLite**.

Ideal para pequenas mercearias que precisam de algo simples, rápido e confiável.

---

## 🚀 Funcionalidades

- 📦 Cadastro e gerenciamento de produtos  
- 🏪 Controle de fornecedores  
- 💰 Registro de vendas  
- 📊 Relatórios  
- ⚙️ Configurações  
- 🧾 Controle de estoque  

---

## 🧠 Filosofia

- Simples e direto  
- Sem dependências pesadas  
- Terminal raiz  
- Funciona até em máquina velha  

---

## 📦 Instalação

Escolha uma das opções abaixo:

### 🔹 Método 1 — curl (rápido e direto)
```bash
curl -LO https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 Método 2 — wget (alternativa ao curl)
```bash
wget https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 Método 3 — git (recomendado para desenvolvimento)
```bash
git clone --depth=1 https://github.com/slackjeff/pdvShell
cd pdvShell
sudo bash install.sh
```

---

## ⚠️ Observações

- O script **deve ser executado como root** (`sudo`).
- Para maior segurança, revise o conteúdo antes de executar:
  ```bash
  less install.sh
  ```
- Recomendado testar em ambiente de desenvolvimento antes de usar em produção.

---

## 🧠 Dica prática

Se você pretende atualizar ou modificar o projeto depois, use **git**.  
Se quer apenas instalar rapidamente, **curl** ou **wget** resolvem em segundos.

---

## ▶️ Uso

```bash
pdvshell
```
---

# 🖥️ Interface completa

## 📋 Menus

![Menu Produtos](assets/mercearia-menu-produtos.png)
![Menu Fornecedores](assets/mercearia-menu-fornecedores.png)
![Menu Movimento](assets/mercearia-menu-movimento.png)
![Menu Relatório](assets/mercearia-menu-relatorio.png)
![Menu Consultas](assets/mercearia-menu-consultas.png)
![Menu Manutenção](assets/mercearia-menu-manutencao.png)
![Menu Configuração](assets/mercearia-menu-configuracao.png)
![Menu Sobre](assets/mercearia-menu-sobre.png)

---

## 📦 Produtos

![Cadastro](assets/mercearia-produtos-cadastro.png)
![Exclusão](assets/mercearia-produtos-exclusao.png)
![Pesquisar](assets/mercearia-produtos-pesquisar.png)
![Vendidos](assets/mercearia-produtos-vendidos.png)
![Compra](assets/mercearia-produtos-compra.png)
![Vendas](assets/mercearia-produtos-vendas.png)
![Entradas](assets/mercearia-produtos-entradas.png)
![Abaixo do mínimo](assets/mercearia-produtos-abaixo-do-minimo.png)
![Validade](assets/mercearia-produtos-fora-de-validade.png)

---

## 🏪 Fornecedores

![Cadastro fornecedor](assets/mercearia-fornecedor-cadastro.png)
![Lista fornecedor](assets/mercearia-fornecedor-listagem.png)

---

## 📊 Relatórios

![Vendas diárias](assets/mercearia-exibir-vendas-diarias.png)

---

## ⚙️ Configurações

![Menu config](assets/mercearia-menu-configuracao.png)
![Cores](assets/configuracao-de-cores.png)
![Empresa](assets/mercearia-configuracao-dados-empresa.png)

---

## ℹ️ Sobre

![Sobre](assets/mercearia-sobre-sobre.png)
![Sair](assets/mercearia-menu-sair.png)

---

## 🛠️ Roadmap

- [ ] Backup automático  
- [ ] Multiusuário  
- [ ] Impressão  
- [ ] Exportação CSV/PDF  

---

## 📄 Licença

MIT
