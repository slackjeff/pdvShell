# 🧾 PDV쉘

<p 정렬="중앙">
<img src="assets/demo.gif" alt="PDVShell 데모" width="700"/>
</p>

<p 정렬="중앙">
<img src="https://img.shields.io/badge/shell-bash-blue?style=flat-square"/>
<img src="https://img.shields.io/badge/database-sqlite-lightgrey?style=flat-square"/>
<img src="https://img.shields.io/badge/license-MIT-green?style=flat-square"/>
<img src="https://img.shields.io/badge/platform-linux-orange?style=flat-square"/>
<img src="https://img.shields.io/badge/focus-low--end%20systems-red?style=flat-square"/>
</p>

---

## 😀 소개

**PDVShell**은 **Shell Script + SQLite**로 개발된 가볍고 효율적인 현금 등록기(POS) 시스템입니다.

간단하고 빠르며 안정적인 제품이 필요한 소규모 식료품점에 이상적입니다.

---

## 🚀 특징

- 📦 상품 등록 및 관리
- 🏪 공급업체 관리
- 💰 판매 기록
- 📊 보고서
- ⚙️ 설정
- 🧾 재고 관리

---

## 🧠 철학

- 단순하고 직접적인
- 무거운 의존성 없음
- 루트 터미널
- 오래된 기계에서도 작동합니다

---

## 📦 설치

아래 옵션 중 하나를 선택하세요.

### 🔹 방법 1 — 컬(빠르고 직접적인)
```bash
curl -LO https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 방법 2 — wget(curl의 대안)
```bash
wget https://raw.githubusercontent.com/slackjeff/pdvShell/main/install.sh
sudo bash install.sh
```

---

### 🔹 방법 3 — git(개발에 권장)
```bash
git clone --depth=1 https://github.com/slackjeff/pdvShell
cd pdvShell
sudo bash install.sh
```

---

## ⚠️ 관찰

- 스크립트는 **루트**(`sudo`)로 실행되어야 합니다.
- 안전을 강화하려면 실행하기 전에 내용을 검토하세요.
  ```bash
  less install.sh
  ```
- 프로덕션 환경에서 사용하기 전에 개발 환경에서 테스트하는 것이 좋습니다.

---

## 🧠 실용적인 팁

나중에 프로젝트를 업데이트하거나 수정하려면 **git**을 사용하세요.
빠르게 설치하고 싶다면 **curl** 또는 **wget**을 사용하면 몇 초 만에 설치가 완료됩니다.

---

## ▶️ 이용/실행

```bash
pdvshell
```
---

# 🖥️ 인터페이스 완성

## 📋 메뉴

![Menu Produtos](assets/mercearia-menu-produtos.png)
![Menu Fornecedores](assets/mercearia-menu-fornecedores.png)
![Menu Movimento](assets/mercearia-menu-movimento.png)
![Menu Relatório](assets/mercearia-menu-relatorio.png)
![Menu Consultas](assets/mercearia-menu-consultas.png)
![Menu Manutenção](assets/mercearia-menu-manutencao.png)
![Menu Configuração](assets/mercearia-menu-configuracao.png)
![Menu Sobre](assets/mercearia-menu-sobre.png)

---

## 📦 제품

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

## 🏪 공급업체

![Cadastro fornecedor](assets/mercearia-fornecedor-cadastro.png)
![Lista fornecedor](assets/mercearia-fornecedor-listagem.png)

---

## 📊 보고서

![Vendas diárias](assets/mercearia-exibir-vendas-diarias.png)

---

## ⚙️ 설정

![Menu config](assets/mercearia-menu-configuracao.png)
![Cores](assets/configuracao-de-cores.png)
![Empresa](assets/mercearia-configuracao-dados-empresa.png)

---

## 나는 ️ 소개

![Sobre](assets/mercearia-sobre-sobre.png)
![Sair](assets/mercearia-menu-sair.png)

---

## 🛠️ 로드맵

- [ ] 자동 백업
- [ ] 다중 사용자
- [ ] 인쇄
- [ ] CSV/PDF 내보내기

---

## 📄 라이선스

와 함께
