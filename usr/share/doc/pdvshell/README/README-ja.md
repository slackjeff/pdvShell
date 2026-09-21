# 🧾 PDVシェル

<p align="center">
<img src="assets/demo.gif" alt="PDVShell デモ" width="700"/>
</p>

<p align="center">
<img src="チリ_REF_0_チリ
<img src="チリ_REF_0_チリ
<img src="チリ_REF_0_チリ
<img src="チリ_REF_0_チリ
<img src="チリ_REF_0_チリ
</p>

---

## 📌について

**PDVShell** は、**シェル スクリプト + SQLite** で開発された、軽量で効率的なレジ (POS) システムです。

シンプル、迅速、信頼性の高いものを必要とする小規模な食料品店に最適です。

---

## 🚀 特徴

- 📦 製品の登録と管理
- 🏪 サプライヤー管理
- 💰 販売実績
- 📊 レポート
- ⚙️設定
- 🧾 在庫管理

---

## 🧠哲学

- シンプルかつダイレクト
- 重い依存関係はありません
- ルート端子
- 古いマシンでも動作します

---

## 📦 インストール

以下のオプションのいずれかを選択します。

### 🔹 方法 1 — カール (素早く直接)
```bash
curl -LO https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 方法 2 — wget (curl の代替)
```bash
wget https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 方法 3 — git (開発に推奨)
```bash
git clone --depth=1 https://github.com/slackjeff/pdvShell
cd pdvShell
sudo bash install.sh
```

---

## ⚠️観察

- スクリプトは **root として実行する必要があります** (`sudo`)。
- 安全性を高めるため、実行する前に内容を確認してください。
  ```bash
  less install.sh
  ```
- 運用環境で使用する前に、開発環境でテストすることをお勧めします。

---

## 🧠 実践的なヒント

後でプロジェクトを更新または変更する予定がある場合は、**git** を使用してください。
すばやくインストールしたいだけの場合は、**curl** または **wget** を使用すると数秒でインストールできます。

---

## ▶️ 利用・実行

```bash
pdvshell
```
---

# 🖥️ インターフェースが完成しました

## 📋 メニュー

![Menu Produtos](assets/mercearia-menu-produtos.png)
![Menu Fornecedores](assets/mercearia-menu-fornecedores.png)
![Menu Movimento](assets/mercearia-menu-movimento.png)
![Menu Relatório](assets/mercearia-menu-relatorio.png)
![Menu Consultas](assets/mercearia-menu-consultas.png)
![Menu Manutenção](assets/mercearia-menu-manutencao.png)
![Menu Configuração](assets/mercearia-menu-configuracao.png)
![Menu Sobre](assets/mercearia-menu-sobre.png)

---

## 📦製品

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

## 🏪 サプライヤー

![Cadastro fornecedor](assets/mercearia-fornecedor-cadastro.png)
![Lista fornecedor](assets/mercearia-fornecedor-listagem.png)

---

## 📊 レポート

![Vendas diárias](assets/mercearia-exibir-vendas-diarias.png)

---

## ⚙️設定

![Menu config](assets/mercearia-menu-configuracao.png)
![Cores](assets/configuracao-de-cores.png)
![Empresa](assets/mercearia-configuracao-dados-empresa.png)

---

## 私は ️について

![Sobre](assets/mercearia-sobre-sobre.png)
![Sair](assets/mercearia-menu-sair.png)

---

## 🛠️ロードマップ

- [ ] 自動バックアップ
- [ ] マルチユーザー
- [ ] 印刷
- [ ] CSV/PDF エクスポート

---

## 📄ライセンス

と
