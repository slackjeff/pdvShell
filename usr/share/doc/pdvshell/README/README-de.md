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

## 📌 Über

**PDVShell** ist ein leichtes und effizientes Kassensystem (POS), entwickelt in **Shell Script + SQLite**.

Ideal für kleine Lebensmittelgeschäfte, die etwas Einfaches, Schnelles und Zuverlässiges benötigen.

---

## 🚀 Funktionen

- 📦 Produktregistrierung und -verwaltung
- 🏪 Lieferantenkontrolle
- 💰 Verkaufsrekord
- 📊 Berichte
- ⚙️ Einstellungen
- 🧾 Bestandskontrolle

---

## 🧠 Philosophie

- Einfach und direkt
- Keine starken Abhängigkeiten
- Root-Terminal
- Es funktioniert sogar auf einer alten Maschine

---

## 📦 Installation

Wählen Sie eine der folgenden Optionen:

### 🔹 Methode 1 – Locken (schnell und direkt)
```bash
curl -LO https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 Methode 2 – wget (Alternative zu Curl)
```bash
wget https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 Methode 3 – Git (für die Entwicklung empfohlen)
```bash
git clone --depth=1 https://github.com/slackjeff/pdvShell
cd pdvShell
sudo bash install.sh
```

---

## ⚠️ Beobachtungen

- Das Skript **muss als Root ausgeführt werden** (`sudo`).
- Für mehr Sicherheit lesen Sie den Inhalt vor dem Ausführen:
  ```bash
  less install.sh
  ```
- Es wird empfohlen, vor der Verwendung in der Produktion einen Test in einer Entwicklungsumgebung durchzuführen.

---

## 🧠 Praxistipp

Wenn Sie planen, das Projekt später zu aktualisieren oder zu ändern, verwenden Sie **git**.
Wenn Sie nur schnell installieren möchten, erledigen **curl** oder **wget** den Zweck in Sekundenschnelle.

---

## ▶️ Verwendung/Ausführung

```bash
pdvshell
```
---

# 🖥️ Schnittstelle vollständig

## 📋 Menüs

![Menu Produtos](assets/mercearia-menu-produtos.png)
![Menu Fornecedores](assets/mercearia-menu-fornecedores.png)
![Menu Movimento](assets/mercearia-menu-movimento.png)
![Menu Relatório](assets/mercearia-menu-relatorio.png)
![Menu Consultas](assets/mercearia-menu-consultas.png)
![Menu Manutenção](assets/mercearia-menu-manutencao.png)
![Menu Configuração](assets/mercearia-menu-configuracao.png)
![Menu Sobre](assets/mercearia-menu-sobre.png)

---

## 📦 Produkte

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

## 🏪 Lieferanten

![Cadastro fornecedor](assets/mercearia-fornecedor-cadastro.png)
![Lista fornecedor](assets/mercearia-fornecedor-listagem.png)

---

## 📊 Berichte

![Vendas diárias](assets/mercearia-exibir-vendas-diarias.png)

---

## ⚙️ Einstellungen

![Menu config](assets/mercearia-menu-configuracao.png)
![Cores](assets/configuracao-de-cores.png)
![Empresa](assets/mercearia-configuracao-dados-empresa.png)

---

## ich ️ Ungefähr

![Sobre](assets/mercearia-sobre-sobre.png)
![Sair](assets/mercearia-menu-sair.png)

---

## 🛠️ Roadmap

- [ ] Automatische Sicherung
- [ ] Mehrbenutzer
- [ ] Drucken
- [ ] CSV/PDF-Export

---

## 📄 Lizenz

MIT
