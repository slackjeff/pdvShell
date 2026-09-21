# 🧾 PDVShell

<p 對齊=“中心”>
<img src="assets/demo.gif" alt="PDVShell 示範" width="700"/>
</p>

<p 對齊=“中心”>
<img src="https://img.shields.io/badge/shell-bash-blue?style=flat-square"/>
<img src="https://img.shields.io/badge/database-sqlite-lightgrey?style=flat-square"/>
<img src="https://img.shields.io/badge/license-MIT-green?style=flat-square"/>
<img src="https://img.shields.io/badge/platform-linux-orange?style=flat-square"/>
<img src="https://img.shields.io/badge/focus-low--end%20systems-red?style=flat-square"/>
</p>

---

## 📌關於

**PDVShell**是一個輕量、高效率的收銀機（POS）系統，採用**Shell Script + SQLite**開發。

非常適合需要簡單、快速和可靠的小型雜貨店。

---

## 🚀 特點

- 📦 產品註冊與管理
- 🏪 供應商控制
- 💰 銷售記錄
- 📊 報告
- ⚙️ 設定
- 🧾 庫存控制

---

## 🧠 哲學

- 簡單直接
- 
- 根終端
- 它甚至可以在舊機器上運行

---

## 📦 安裝

選擇以下選項之一：

### 🔹方法1－捲髮（快速、直接）
```bash
curl -LO https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹方法 2 — wget（curl 的替代方法）
```bash
wget https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹方法三——git（推薦用於開發）
```bash
git clone --depth=1 https://github.com/slackjeff/pdvShell
cd pdvShell
sudo bash install.sh
```

---

## ⚠️觀察

- 該腳本**必須以 root 身分執行** (`sudo`)。
- 為了提高安全性，請在運行前查看內容：
  ```bash
  less install.sh
  ```
- 建議在生產中使用之前在開發環境中進行測試。

---

## 🧠實用技巧

如果您打算稍後更新或修改項目，請使用 **git**。
如果您只是想快速安裝，**curl** 或 **wget** 將在幾秒鐘內完成任務。

---

## ▶️ 使用/執行

```bash
pdvshell.sh
```
---

# 🖥️接口完整

## 📋 選單

![Menu Produtos](assets/mercearia-menu-produtos.png)
![Menu Fornecedores](assets/mercearia-menu-fornecedores.png)
![Menu Movimento](assets/mercearia-menu-movimento.png)
![Menu Relatório](assets/mercearia-menu-relatorio.png)
![Menu Consultas](assets/mercearia-menu-consultas.png)
![Menu Manutenção](assets/mercearia-menu-manutencao.png)
![Menu Configuração](assets/mercearia-menu-configuracao.png)
![Menu Sobre](assets/mercearia-menu-sobre.png)

---

## 📦 產品

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

## 🏪 供應商

![Cadastro fornecedor](assets/mercearia-fornecedor-cadastro.png)
![Lista fornecedor](assets/mercearia-fornecedor-listagem.png)

---

## 📊 報告

![Vendas diárias](assets/mercearia-exibir-vendas-diarias.png)

---

## ⚙️ 設定

![Menu config](assets/mercearia-menu-configuracao.png)
![Cores](assets/configuracao-de-cores.png)
![Empresa](assets/mercearia-configuracao-dados-empresa.png)

---

## ℹ️ 我️關於

![Sobre](assets/mercearia-sobre-sobre.png)
![Sair](assets/mercearia-menu-sair.png)

---

## 🛠️路線圖

- [ ] 自動備份
- [ ] 多用戶
- [ ] 列印
- [ ] CSV/PDF 匯出

---

## 📄 許可證

MIT
