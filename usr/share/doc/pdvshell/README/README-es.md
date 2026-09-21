# 🧾PDVShell

<p align="centro">
<img src="assets/demo.gif" alt="Demostración de PDVShell" width="700"/>
</p>

<p align="centro">
<img src="https://img.shields.io/badge/shell-bash-blue?style=flat-square"/>
<img src="https://img.shields.io/badge/database-sqlite-lightgrey?style=flat-square"/>
<img src="https://img.shields.io/badge/license-MIT-green?style=flat-square"/>
<img src="https://img.shields.io/badge/platform-linux-orange?style=flat-square"/>
<img src="https://img.shields.io/badge/focus-low--end%20systems-red?style=flat-square"/>
</p>

---

## 📌 Acerca de

**PDVShell** es un sistema de caja registradora (POS) liviano y eficiente, desarrollado en **Shell Script + SQLite**.

Ideal para pequeñas tiendas de alimentación que necesitan algo sencillo, rápido y fiable.

---

## 🚀 Características

- 📦 Registro y gestión de productos
- 🏪 Control de proveedores
- 💰 Récord de ventas
- 📊 Informes
- ⚙️ Configuración
- 🧾 Control de inventario

---

## 🧠 Filosofía

- Sencillo y directo
- Sin grandes dependencias
- terminal raíz
- Funciona incluso en una máquina vieja.

---

## 📦 Instalación

Elija una de las siguientes opciones:

### 🔹 Método 1: rizo (rápido y directo)
```bash
curl -LO https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 Método 2: wget (alternativa a curl)
```bash
wget https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 Método 3: git (recomendado para desarrollo)
```bash
git clone --depth=1 https://github.com/slackjeff/pdvShell
cd pdvShell
sudo bash install.sh
```

---

## ⚠️ Observaciones

- El script **debe ejecutarse como root** (`sudo`).
- Para mayor seguridad, revise el contenido antes de ejecutar:
  ```bash
  less install.sh
  ```
- Se recomienda realizar pruebas en un entorno de desarrollo antes de utilizarlos en producción.

---

## 🧠 Consejo práctico

Si planea actualizar o modificar el proyecto más adelante, use **git**.
Si solo desea realizar una instalación rápida, **curl** o **wget** funcionarán en segundos.

---

## ▶️ Uso/Ejecución

```bash
pdvshell
```
---

# 🖥️ Interfaz completa

## 📋 Menús

![Menu Produtos](assets/mercearia-menu-produtos.png)
![Menu Fornecedores](assets/mercearia-menu-fornecedores.png)
![Menu Movimento](assets/mercearia-menu-movimento.png)
![Menu Relatório](assets/mercearia-menu-relatorio.png)
![Menu Consultas](assets/mercearia-menu-consultas.png)
![Menu Manutenção](assets/mercearia-menu-manutencao.png)
![Menu Configuração](assets/mercearia-menu-configuracao.png)
![Menu Sobre](assets/mercearia-menu-sobre.png)

---

## 📦 Productos

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

## 🏪 Proveedores

![Cadastro fornecedor](assets/mercearia-fornecedor-cadastro.png)
![Lista fornecedor](assets/mercearia-fornecedor-listagem.png)

---

## 📊 Informes

![Vendas diárias](assets/mercearia-exibir-vendas-diarias.png)

---

## ⚙️ Configuración

![Menu config](assets/mercearia-menu-configuracao.png)
![Cores](assets/configuracao-de-cores.png)
![Empresa](assets/mercearia-configuracao-dados-empresa.png)

---

## ℹ️ Sobre

![Sobre](assets/mercearia-sobre-sobre.png)
![Sair](assets/mercearia-menu-sair.png)

---

## 🛠️ Hoja de ruta

- [ ] Backup automático
- [ ] Multiusuario
- [ ] Imprimir
- [ ] Exportación CSV/PDF

---

## 📄 Licencia

MIT
