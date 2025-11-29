# Sistema de Gerenciamento de Biblioteca

## 1. Visão Geral do Projeto

Este repositório contém os scripts SQL para a implementação e manipulação de um **Sistema de Gerenciamento de Biblioteca** em um banco de dados relacional. O projeto integra o Modelo Lógico Normalizado (3FN) com a prática de manipulação de dados utilizando a Linguagem de Manipulação de Dados (DML).

### 1.1. Descrição do Minimundo

[cite_start]O sistema de gerenciamento de biblioteca registra **usuários**, gerencia **livros** disponíveis e controla **empréstimos** e **avaliações** feitas pelos usuários[cite: 4]. Os usuários podem realizar empréstimos, deixar avaliações e verificar a disponibilidade dos livros.

---

## 2. Modelo Lógico (Diagrama Entidade-Relacionamento - DER)

O modelo lógico foi revisado e normalizado (1FN, 2FN e 3FN) para garantir a integridade e a ausência de dependências parciais ou transitivas.



| Entidade | Chave Primária (PK) | Chaves Estrangeiras (FK) |
| :--- | :--- | :--- |
| **usuarios** | `id_usuario` | Nenhuma |
| **livros** | `isbn` | Nenhuma |
| **emprestimos** | `id_emprestimo` | `id_usuario`, `isbn` |
| **avaliacoes** | `id_avaliacao` | `id_usuario`, `isbn` |

---

## 3. Pré-requisitos e Configuração

Para executar os scripts, você precisará de:

* **Sistema Gerenciador de Banco de Dados (SGBD):** PostgreSQL (Recomendado) ou MySQL.
* **Ferramenta Cliente:** PgAdmin, MySQL Workbench ou DBeaver para executar o script.

### Instruções de Execução

1.  Crie um novo banco de dados vazio no seu ambiente SGBD (ex: `biblioteca_db`).
2.  Abra o arquivo `database_scripts.sql` no seu cliente de banco de dados.
3.  **Execute todo o script em sequência.** O arquivo está ordenado para:
    * Criar todas as tabelas e chaves (DDL).
    * Popular todas as tabelas (INSERT DML).
    * Executar consultas de teste (SELECT DML).
    * Executar comandos de manipulação (UPDATE/DELETE DML).

---

## 4. Detalhamento dos Scripts SQL (`database_scripts.sql`)

O script está dividido em quatro seções que cumprem os requisitos de avaliação:

### 4.1. Criação da Estrutura (DDL)

Define as quatro tabelas do modelo lógico. As restrições de chave estrangeira (`FOREIGN KEY`) foram configuradas com regras de integridade:
* **ON DELETE RESTRICT** (em `emprestimos`): Impede a exclusão de um usuário ou livro se houver um empréstimo ativo.
* **ON DELETE CASCADE** (em `avaliacoes`): Garante que, se um usuário for excluído, todas as suas avaliações sejam removidas automaticamente.

### 4.2. Comandos de Inserção (INSERT DML)

Contém comandos **INSERT** para popular todas as quatro tabelas (`usuarios`, `livros`, `emprestimos`, `avaliacoes`) com dados de exemplo.

### 4.3. Consultas e Análise de Dados (SELECT DML)

Contém **quatro consultas** que demonstram o uso avançado do `SELECT`:

| Consulta | Comando SQL Principal | Objetivo |
| :--- | :--- | :--- |
| 1 | `SELECT` com **JOIN** e **WHERE** | Lista empréstimos ativos, cruzando dados de usuário e livro. |
| 2 | `SELECT` com **JOIN** e **WHERE** | Exibe avaliações com nota 5, ordenadas pela data (**ORDER BY**). |
| 3 | `SELECT` com **GROUP BY** e **LIMIT** | Mostra o ranking dos 2 usuários com mais empréstimos. |
| 4 | `SELECT` com **LEFT JOIN** | Lista livros disponíveis que nunca foram avaliados. |

### 4.4. Manipulação de Dados (UPDATE e DELETE DML)

Demonstra a manipulação segura e condicional dos dados:

| Comando | Tipo | Condição |
| :--- | :--- | :--- |
| Atualização de endereço | **UPDATE** | Condição por `id_usuario` |
| Registro de devolução | **UPDATE** | Condição por `id_emprestimo` e `data_devolucao IS NULL` |
| Alteração de status de livro | **UPDATE** | Condição por `isbn` |
| Deleção de avaliação | **DELETE** | Condição por `id_avaliacao` |
| Deleção de usuário | **DELETE** | Condição por `id_usuario` (testando CASCADE) |
| Deleção de livro | **DELETE** | Condição por `isbn` e `status` (testando RESTRICT) |