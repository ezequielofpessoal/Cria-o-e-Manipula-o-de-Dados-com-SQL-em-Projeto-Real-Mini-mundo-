-- #################################################################
-- 1. CRIAÇÃO DA ESTRUTURA (DDL)
-- #################################################################

-- NOTA: O 'SERIAL PRIMARY KEY' é usado para IDs auto-incrementáveis.
-- Se estiver usando MySQL, use 'INT PRIMARY KEY AUTO_INCREMENT'.

-- 1.1. TABELA USUÁRIOS
-------------------------------------------------------------------
CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    endereco VARCHAR(255),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 1.2. TABELA LIVROS
-------------------------------------------------------------------
CREATE TABLE livros (
    isbn VARCHAR(20) PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(150),
    ano_publicacao INTEGER,
    status VARCHAR(50) DEFAULT 'Disponível' 
    -- Possíveis valores: 'Disponível', 'Emprestado', 'Reservado'
);

-- 1.3. TABELA EMPRÉSTIMOS
-------------------------------------------------------------------
CREATE TABLE emprestimos (
    id_emprestimo SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    data_emprestimo DATE NOT NULL,
    data_prevista_devolucao DATE NOT NULL,
    data_devolucao DATE, -- Nulo se o empréstimo estiver ativo
    
    -- Chaves Estrangeiras e Regras de Integridade
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (isbn) REFERENCES livros(isbn) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 1.4. TABELA AVALIAÇÕES
-------------------------------------------------------------------
CREATE TABLE avaliacoes (
    id_avaliacao SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    nota INTEGER NOT NULL CHECK (nota BETWEEN 1 AND 5), -- Restrição de Nota entre 1 e 5
    comentario TEXT,
    data_avaliacao TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    
    -- Chaves Estrangeiras e Regras de Integridade
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (isbn) REFERENCES livros(isbn) ON DELETE CASCADE ON UPDATE CASCADE
);


-- #################################################################
-- 2. INSERÇÃO DE DADOS (INSERT DML)
-- #################################################################

-- 2.1. INSERTS NA TABELA USUÁRIOS (IDs 1, 2, 3, 4)
INSERT INTO usuarios (nome, email, endereco) VALUES
('Ana Silva', 'ana.silva@email.com', 'Rua A, 123, Centro'),
('Bruno Costa', 'bruno.costa@email.com', 'Av. Principal, 45, Bairro Novo'),
('Carla Oliveira', 'carla.o@email.com', 'Travessa da Paz, 78, Vila Antiga'),
('Daniel Santos', 'daniel.s@email.com', 'Estrada Velha, 99, Zona Rural');

-- 2.2. INSERTS NA TABELA LIVROS (ISBNS)
INSERT INTO livros (isbn, titulo, autor, ano_publicacao, status) VALUES
('978-8575225002', 'Código Limpo', 'Robert C. Martin', 2009, 'Emprestado'),
('978-8535914838', '1984', 'George Orwell', 2009, 'Disponível'),
('978-0321765723', 'The C++ Programming Language', 'Bjarne Stroustrup', 2013, 'Disponível'),
('978-8543105759', 'Sapiens: Uma Breve História da Humanidade', 'Yuval Noah Harari', 2015, 'Emprestado'),
('978-8533302251', 'Dom Casmurro', 'Machado de Assis', 1899, 'Disponível');

-- 2.3. INSERTS NA TABELA EMPRÉSTIMOS
INSERT INTO emprestimos (id_usuario, isbn, data_emprestimo, data_prevista_devolucao) VALUES
(1, '978-8575225002', '2025-10-20', '2025-11-20'); -- Ana empresta Código Limpo (Ativo, ID 1)

INSERT INTO emprestimos (id_usuario, isbn, data_emprestimo, data_prevista_devolucao) VALUES
(2, '978-8543105759', '2025-11-01', '2025-12-01'); -- Bruno empresta Sapiens (Ativo, ID 2)

INSERT INTO emprestimos (id_usuario, isbn, data_emprestimo, data_prevista_devolucao, data_devolucao) VALUES
(3, '978-8575225002', '2025-09-01', '2025-10-01', '2025-09-28'); -- Carla devolve Código Limpo (Finalizado, ID 3)

-- 2.4. INSERTS NA TABELA AVALIAÇÕES
INSERT INTO avaliacoes (id_usuario, isbn, nota, comentario) VALUES
(1, '978-8575225002', 5, 'Essencial para qualquer desenvolvedor!'); -- Ana avalia Código Limpo (ID 1)

INSERT INTO avaliacoes (id_usuario, isbn, nota, comentario) VALUES
(4, '978-8543105759', 4, 'Leitura densa, mas muito informativa.'); -- Daniel avalia Sapiens (ID 2)

INSERT INTO avaliacoes (id_usuario, isbn, nota, comentario) VALUES
(2, '978-8535914838', 5, 'Um clássico atemporal, a nota máxima é merecida.'); -- Bruno avalia 1984 (ID 3)


-- #################################################################
-- 3. CONSULTAS DE DADOS (SELECT DML)
-- #################################################################

-- 3.1. CONSULTA: Livros atualmente emprestados, com nome do usuário
SELECT 
    l.titulo AS "Título do Livro",
    u.nome AS "Nome do Usuário",
    e.data_emprestimo AS "Data de Empréstimo",
    e.data_prevista_devolucao AS "Devolução Prevista"
FROM 
    emprestimos e
JOIN 
    livros l ON e.isbn = l.isbn
JOIN 
    usuarios u ON e.id_usuario = u.id_usuario
WHERE 
    e.data_devolucao IS NULL -- Filtra apenas empréstimos ativos
ORDER BY 
    e.data_prevista_devolucao;

-- 3.2. CONSULTA: Avaliações excelentes (Nota 5) e seus detalhes
SELECT
    u.nome AS "Usuário",
    l.titulo AS "Livro Avaliado",
    a.nota AS "Nota",
    a.comentario AS "Comentário"
FROM
    avaliacoes a
JOIN
    usuarios u ON a.id_usuario = u.id_usuario
JOIN
    livros l ON a.isbn = l.isbn
WHERE
    a.nota = 5
ORDER BY
    a.data_avaliacao DESC;

-- 3.3. CONSULTA: Ranking dos 2 usuários com mais empréstimos realizados (incluindo devoluções)
SELECT
    u.nome AS "Nome do Usuário",
    COUNT(e.id_emprestimo) AS "Total de Empréstimos"
FROM
    emprestimos e
JOIN
    usuarios u ON e.id_usuario = u.id_usuario
GROUP BY
    u.id_usuario, u.nome
ORDER BY
    "Total de Empréstimos" DESC
LIMIT 2;

-- 3.4. CONSULTA: Livros "Disponíveis" que ainda não receberam nenhuma avaliação
SELECT
    l.titulo AS "Título Disponível e Não Avaliado",
    l.autor
FROM
    livros l
LEFT JOIN
    avaliacoes a ON l.isbn = a.isbn
WHERE
    l.status = 'Disponível' AND a.id_avaliacao IS NULL;


-- #################################################################
-- 4. MANIPULAÇÃO DE DADOS (UPDATE e DELETE DML)
-- #################################################################

-- 4.1. COMANDOS UPDATE

-- UPDATE 1: Atualiza o endereço do usuário 'Ana Silva' (id_usuario 1)
UPDATE usuarios
SET endereco = 'Rua B, 321, Centro, Bloco C'
WHERE id_usuario = 1;

-- UPDATE 2: Marca o empréstimo mais antigo em aberto (ID 1) como DEVOLVIDO na data atual
UPDATE emprestimos
SET 
    data_devolucao = CURRENT_DATE 
WHERE 
    id_emprestimo = 1 AND data_devolucao IS NULL;

-- UPDATE 3: Atualiza o status do livro "1984" para 'Reservado'
UPDATE livros
SET status = 'Reservado'
WHERE isbn = '978-8535914838';

-- 4.2. COMANDOS DELETE

-- DELETE 1: Remove a avaliação específica (ID 3)
DELETE FROM avaliacoes
WHERE id_avaliacao = 3;

-- DELETE 2: Remove o usuário 'Daniel Santos' (id_usuario 4)
-- A regra ON DELETE CASCADE garante que as avaliações deste usuário também sejam excluídas.
DELETE FROM usuarios
WHERE id_usuario = 4;

-- DELETE 3: Remove o livro "The C++ Programming Language" (978-0321765723)
-- A regra ON DELETE RESTRICT garante que a exclusão só ocorra se o livro não tiver empréstimos ativos.
DELETE FROM livros
WHERE isbn = '978-0321765723' AND status = 'Disponível';