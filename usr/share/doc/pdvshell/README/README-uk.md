# 🧾PDVShell

<p alinhar="centro">
<img src="assets/demo.gif" alt="PDVShell Demo" width="700"/>
</p>

<p alinhar="centro">
<img src="https://img.shields.io/badge/shell-bash-blue?style=flat-square"/>
<img src="https://img.shields.io/badge/database-sqlite-lightgrey?style=flat-square"/>
<img src="https://img.shields.io/badge/license-MIT-green?style=flat-square"/>
<img src="https://img.shields.io/badge/platform-linux-orange?style=flat-square"/>
<img src="https://img.shields.io/badge/focus-low--end%20systems-red?style=flat-square"/>
</p>

---

## 📌 Про проєкт

**PDVShell** — це легка та ефективна система пункту продажу (POS), розроблена за допомогою **Shell Script** + **SQLite**.

Ідеально підходить для невеликих продуктових магазинів, яким потрібне просте, швидке та надійне рішення.

---

## 🚀 Функціональність

- 📦 Реєстрація та керування товарами
- 🏪 Керування постачальниками
- 💰 Реєстрація продажів
- 📊 Звіти
- ⚙️ Налаштування
- 🧾 Керування запасами

---

## 🧠 Філософія

- Просто та зрозуміло
- Без важких залежностей
- Робота безпосередньо в терміналі
- Працює навіть на старих комп'ютерах

---

## 📦 Встановлення

Виберіть один із наведених нижче способів:

### 🔹 Спосіб 1 — curl (швидко та просто)
```
curl -LO https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

### 🔹 Спосіб 2 — wget (альтернатива curl)
```
wget https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

### 🔹 Спосіб 3 — git (рекомендовано для розробки)
```
git clone --depth=1 https://github.com/slackjeff/pdvShell
cd pdvShell
sudo bash install.sh
```

## ⚠️ Примітки

Скрипт необхідно запускати від імені root (sudo).

Для більшої безпеки перевірте вміст скрипту перед запуском:
```
less install.sh
```

Рекомендується протестувати систему в середовищі розробки перед використанням у production.

## 🧠 Практична порада

Якщо ви плануєте надалі оновлювати або змінювати проєкт, використовуйте git.

Якщо вам потрібно лише швидко встановити систему, curl або wget виконають встановлення за кілька секунд.

## ▶️ Використання / запуск
```
pdvshell.sh
```

# 🖥️ Повний інтерфейс

## 📋 Меню

![Menu Produtos](assets/mercearia-menu-produtos.png)
![Menu Fornecedores](assets/mercearia-menu-fornecedores.png)
![Menu Movimento](assets/mercearia-menu-movimento.png)
![Menu Relatório](assets/mercearia-menu-relatorio.png)
![Menu Consultas](assets/mercearia-menu-consultas.png)
![Menu Manutenção](assets/mercearia-menu-manutencao.png)
![Menu Configuração](assets/mercearia-menu-configuracao.png)
![Menu Sobre](assets/mercearia-menu-sobre.png)

---

## 📦 Товари

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

## 🏪 Постачальники

![Cadastro fornecedor](assets/mercearia-fornecedor-cadastro.png)
![Lista fornecedor](assets/mercearia-fornecedor-listagem.png)

---


## 📊 Звіти

![Vendas diárias](assets/mercearia-exibir-vendas-diarias.png)

---

## ⚙️ Налаштування

![Menu config](assets/mercearia-menu-configuracao.png)
![Cores](assets/configuracao-de-cores.png)
![Empresa](assets/mercearia-configuracao-dados-empresa.png)

---

## ℹ️ Про програму

![Sobre](assets/mercearia-sobre-sobre.png)
![Sair](assets/mercearia-menu-sair.png)

---

## 🛠️ План розвитку

- [ ] Автоматичне резервне копіювання
- [ ] Підтримка кількох користувачів
- [ ] Друк
- [ ] Експорт у CSV/PDF

--- 

## 📄 Ліцензія

MIT
