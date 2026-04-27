# 🧾PDVShell

<p align="center">
<img src="assets/demo.gif" alt="Démo PDVShell" width="700"/>
</p>

<p align="center">
<img src="https://img.shields.io/badge/shell-bash-blue?style=flat-square"/>
<img src="https://img.shields.io/badge/database-sqlite-lightgrey?style=flat-square"/>
<img src="https://img.shields.io/badge/license-MIT-green?style=flat-square"/>
<img src="https://img.shields.io/badge/platform-linux-orange?style=flat-square"/>
<img src="https://img.shields.io/badge/focus-low--end%20systems-red?style=flat-square"/>
</p>

---

## 📌 À propos

**PDVShell** est un système de caisse enregistreuse (POS) léger et efficace, développé en **Shell Script + SQLite**.

Idéal pour les petites épiceries qui ont besoin de quelque chose de simple, rapide et fiable.

---

## 🚀 Caractéristiques

- 📦 Enregistrement et gestion des produits
- 🏪 Contrôle des fournisseurs
- 💰 Record de ventes
- 📊 Rapports
- ⚙️ Paramètres
- 🧾 Contrôle des stocks

---

## 🧠 Philosophie

- Simple et direct
- Pas de dépendances lourdes
- Terminal racine
- Cela fonctionne même sur une vieille machine

---

## 📦Installation

Choisissez l'une des options ci-dessous :

### 🔹 Méthode 1 — curl (rapide et directe)
```bash
curl -LO https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 Méthode 2 — wget (alternative à curl)
```bash
wget https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 Méthode 3 — git (recommandé pour le développement)
```bash
git clone --depth=1 https://github.com/slackjeff/pdvShell
cd pdvShell
sudo bash install.sh
```

---

## ⚠️ Observations

- Le script **doit être exécuté en tant que root** (`sudo`).
- Pour plus de sécurité, vérifiez le contenu avant d'exécuter :
  ```bash
  less install.sh
  ```
- Il est recommandé de tester dans un environnement de développement avant de l'utiliser en production.

---

## 🧠 Conseil pratique

Si vous prévoyez de mettre à jour ou de modifier le projet ultérieurement, utilisez **git**.
Si vous souhaitez simplement installer rapidement, **curl** ou **wget** feront l'affaire en quelques secondes.

---

## ▶️ Utilisation/Exécution

```bash
pdvshell
```
---

# 🖥️ Interface complète

## 📋Menus

![Menu Produtos](assets/mercearia-menu-produtos.png)
![Menu Fornecedores](assets/mercearia-menu-fornecedores.png)
![Menu Movimento](assets/mercearia-menu-movimento.png)
![Menu Relatório](assets/mercearia-menu-relatorio.png)
![Menu Consultas](assets/mercearia-menu-consultas.png)
![Menu Manutenção](assets/mercearia-menu-manutencao.png)
![Menu Configuração](assets/mercearia-menu-configuracao.png)
![Menu Sobre](assets/mercearia-menu-sobre.png)

---

## 📦 Produits

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

## 🏪 Fournisseurs

![Cadastro fornecedor](assets/mercearia-fornecedor-cadastro.png)
![Lista fornecedor](assets/mercearia-fornecedor-listagem.png)

---

## 📊 Rapports

![Vendas diárias](assets/mercearia-exibir-vendas-diarias.png)

---

## ⚙️ Paramètres

![Menu config](assets/mercearia-menu-configuracao.png)
![Cores](assets/configuracao-de-cores.png)
![Empresa](assets/mercearia-configuracao-dados-empresa.png)

---

## ️ À propos

![Sobre](assets/mercearia-sobre-sobre.png)
![Sair](assets/mercearia-menu-sair.png)

---

## 🛠️ Feuille de route

- [ ] Sauvegarde automatique
- [ ] Multi-utilisateur
- [ ] Imprimer
- [ ] Exportation CSV/PDF

---

## 📄 Licence

AVEC
