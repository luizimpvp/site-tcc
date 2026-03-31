-- =====================================================
-- BANCO DE DADOS - MERCADINHO PEREIRA
-- Sistema de Reserva Online
-- =====================================================

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS mercadinho_pereira;
USE mercadinho_pereira;

-- =====================================================
-- TABELA: categorias
-- =====================================================
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- TABELA: clientes
-- Campos: id (PK), nome, email, telefone, cpf, senha
-- =====================================================
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    status TINYINT DEFAULT 1 COMMENT '1=ativo, 0=inativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_cpf (cpf)
);

-- =====================================================
-- TABELA: funcionarios
-- =====================================================
CREATE TABLE funcionarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    cargo VARCHAR(100),
    status TINYINT DEFAULT 1 COMMENT '1=ativo, 0=inativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
);

-- =====================================================
-- TABELA: produtos
-- Campos: id (PK), categoria_id (FK), nome, descricao, preco, estoque, imagem, destaque, ativo
-- =====================================================
CREATE TABLE produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id INT NOT NULL,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    imagem VARCHAR(500),
    destaque TINYINT DEFAULT 0 COMMENT '1=destaque, 0=normal',
    ativo TINYINT DEFAULT 1 COMMENT '1=ativo, 0=inativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE RESTRICT,
    INDEX idx_categoria (categoria_id),
    INDEX idx_destaque (destaque),
    INDEX idx_ativo (ativo)
);

-- =====================================================
-- TABELA: reservas
-- =====================================================
CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    status ENUM('pendente', 'confirmada', 'finalizada', 'cancelada') DEFAULT 'pendente',
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
    INDEX idx_cliente (cliente_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- TABELA: itens_reserva
-- =====================================================
CREATE TABLE itens_reserva (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reserva_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reserva_id) REFERENCES reservas(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT,
    INDEX idx_reserva (reserva_id),
    INDEX idx_produto (produto_id)
);

-- =====================================================
-- TABELA: carrinho_temporario (para carrinhos não finalizados)
-- =====================================================
CREATE TABLE carrinho_temporario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_carrinho (cliente_id, produto_id),
    INDEX idx_cliente (cliente_id)
);

-- =====================================================
-- TABELA: logs_acesso (para auditoria)
-- =====================================================
CREATE TABLE logs_acesso (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_tipo ENUM('cliente', 'funcionario') NOT NULL,
    usuario_id INT NOT NULL,
    acao VARCHAR(100),
    ip VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_usuario (usuario_tipo, usuario_id),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- =====================================================
-- INSERÇÃO DE DADOS INICIAIS
-- =====================================================
-- =====================================================

-- 1. Inserir categorias
INSERT INTO categorias (id, nome, descricao) VALUES
(1, 'Alimentos', 'Alimentos não perecíveis e enlatados'),
(2, 'Bebidas', 'Refrigerantes, sucos, água e bebidas em geral'),
(3, 'Limpeza', 'Produtos de limpeza em geral'),
(4, 'Higiene', 'Produtos de higiene pessoal'),
(5, 'Hortifrúti', 'Frutas, verduras e legumes');

-- 2. Inserir funcionário (Ezequiel Araújo)
-- Senha: 250508 (hash em MD5 para demonstração)
INSERT INTO funcionarios (id, nome, email, senha, cargo, status) VALUES
(1, 'Ezequiel Araújo', 'ezequielaraujo008@gmail.com', MD5('250508'), 'Administrador', 1);

-- 3. Inserir clientes de exemplo
INSERT INTO clientes (id, nome, email, telefone, cpf, senha, status) VALUES
(1, 'Cliente Teste', 'cliente@teste.com', '(21) 99999-9999', '123.456.789-00', MD5('123456'), 1),
(2, 'Maria Silva', 'maria@email.com', '(21) 98888-7777', '111.222.333-44', MD5('maria123'), 1),
(3, 'João Santos', 'joao@email.com', '(21) 97777-6666', '555.666.777-88', MD5('joao123'), 1);

-- 4. Inserir produtos
INSERT INTO produtos (id, categoria_id, nome, descricao, preco, estoque, imagem, destaque, ativo) VALUES
(1, 1, 'Arroz Branco Tipo 1', 'Arroz branco tipo 1 - Pacote 5kg', 25.90, 50, 'https://images.unsplash.com/photo-1586201375761-83865001e8ac?w=300&h=200&fit=crop', 1, 1),
(2, 1, 'Feijão Carioca', 'Feijão carioca tipo 1 - Pacote 1kg', 8.90, 100, 'https://images.unsplash.com/photo-1584483766114-2cea6facdf57?w=300&h=200&fit=crop', 1, 1),
(3, 2, 'Refrigerante Cola', 'Refrigerante cola 2L', 9.90, 80, 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=300&h=200&fit=crop', 1, 1),
(4, 1, 'Macarrão Espaguete', 'Macarrão espaguete 500g', 4.90, 60, 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=300&h=200&fit=crop', 0, 1),
(5, 1, 'Óleo de Soja', 'Óleo de soja 900ml', 7.90, 40, 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=300&h=200&fit=crop', 0, 1),
(6, 1, 'Leite Integral', 'Leite integral 1L', 5.50, 70, 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=300&h=200&fit=crop', 1, 1),
(7, 1, 'Café Torrado', 'Café torrado e moído 500g', 12.90, 45, 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=300&h=200&fit=crop', 0, 1),
(8, 3, 'Sabão em Pó', 'Sabão em pó 1kg', 8.90, 35, 'https://images.unsplash.com/photo-1583947581927-860cda6ba47c?w=300&h=200&fit=crop', 1, 1),
(9, 4, 'Shampoo', 'Shampoo 350ml', 12.90, 30, 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=300&h=200&fit=crop', 0, 1),
(10, 5, 'Banana Prata', 'Banana prata - kg', 6.90, 50, 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=300&h=200&fit=crop', 1, 1),
(11, 5, 'Maçã Nacional', 'Maçã nacional - kg', 7.90, 40, 'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?w=300&h=200&fit=crop', 0, 1),
(12, 2, 'Água Mineral', 'Água mineral sem gás 500ml', 2.50, 200, 'https://images.unsplash.com/photo-1616118132534-38129cdc9a83?w=300&h=200&fit=crop', 1, 1);

-- 5. Inserir reservas de exemplo
INSERT INTO reservas (id, cliente_id, total, status, observacoes, created_at) VALUES
(1, 1, 35.80, 'confirmada', 'Retirar após as 18h', '2025-03-20 10:30:00'),
(2, 2, 27.40, 'pendente', NULL, '2025-03-21 14:15:00'),
(3, 1, 42.30, 'finalizada', 'Entregue no balcão', '2025-03-19 09:45:00'),
(4, 3, 15.50, 'cancelada', 'Cliente cancelou', '2025-03-18 16:20:00');

-- 6. Inserir itens das reservas
INSERT INTO itens_reserva (id, reserva_id, produto_id, quantidade, preco_unitario, subtotal) VALUES
-- Reserva 1
(1, 1, 1, 1, 25.90, 25.90),
(2, 1, 4, 2, 4.90, 9.80),
-- Reserva 2
(3, 2, 6, 2, 5.50, 11.00),
(4, 2, 10, 1, 6.90, 6.90),
(5, 2, 12, 2, 2.50, 5.00),
(6, 2, 7, 1, 12.90, 12.90),
-- Reserva 3
(7, 3, 2, 2, 8.90, 17.80),
(8, 3, 3, 1, 9.90, 9.90),
(9, 3, 5, 1, 7.90, 7.90),
(10, 3, 8, 1, 8.90, 8.90),
-- Reserva 4
(11, 4, 9, 1, 12.90, 12.90),
(12, 4, 12, 1, 2.50, 2.50);

-- 7. Inserir carrinho temporário de exemplo
INSERT INTO carrinho_temporario (cliente_id, produto_id, quantidade) VALUES
(2, 1, 1),
(2, 3, 2),
(2, 8, 1);

-- =====================================================
-- =====================================================
-- VIEWS PARA CONSULTAS COMUNS
-- =====================================================
-- =====================================================

-- VIEW: Produtos com nome da categoria
CREATE VIEW vw_produtos_completo AS
SELECT 
    p.id,
    p.nome,
    p.descricao,
    p.preco,
    p.estoque,
    p.imagem,
    p.destaque,
    p.ativo,
    p.categoria_id,
    c.nome AS categoria_nome,
    p.created_at,
    p.updated_at
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- VIEW: Reservas com dados do cliente
CREATE VIEW vw_reservas_completo AS
SELECT 
    r.id,
    r.cliente_id,
    c.nome AS cliente_nome,
    c.email AS cliente_email,
    c.telefone AS cliente_telefone,
    r.total,
    r.status,
    r.observacoes,
    r.created_at,
    r.updated_at
FROM reservas r
INNER JOIN clientes c ON r.cliente_id = c.id;

-- VIEW: Itens das reservas com detalhes do produto
CREATE VIEW vw_itens_reserva_completo AS
SELECT 
    ir.id,
    ir.reserva_id,
    ir.produto_id,
    p.nome AS produto_nome,
    p.imagem AS produto_imagem,
    ir.quantidade,
    ir.preco_unitario,
    ir.subtotal
FROM itens_reserva ir
INNER JOIN produtos p ON ir.produto_id = p.id;

-- =====================================================
-- =====================================================
-- PROCEDURES E FUNÇÕES
-- =====================================================
-- =====================================================

-- Procedure: Atualizar estoque após reserva
DELIMITER //
CREATE PROCEDURE sp_atualizar_estoque(IN p_reserva_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_produto_id INT;
    DECLARE v_quantidade INT;
    DECLARE cur CURSOR FOR SELECT produto_id, quantidade FROM itens_reserva WHERE reserva_id = p_reserva_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_produto_id, v_quantidade;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        UPDATE produtos SET estoque = estoque - v_quantidade WHERE id = v_produto_id;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;

-- Procedure: Criar nova reserva
DELIMITER //
CREATE PROCEDURE sp_criar_reserva(
    IN p_cliente_id INT,
    IN p_total DECIMAL(10,2),
    IN p_observacoes TEXT,
    OUT p_reserva_id INT
)
BEGIN
    INSERT INTO reservas (cliente_id, total, observacoes, status) 
    VALUES (p_cliente_id, p_total, p_observacoes, 'pendente');
    
    SET p_reserva_id = LAST_INSERT_ID();
END //
DELIMITER ;

-- Procedure: Adicionar item à reserva
DELIMITER //
CREATE PROCEDURE sp_adicionar_item_reserva(
    IN p_reserva_id INT,
    IN p_produto_id INT,
    IN p_quantidade INT,
    IN p_preco_unitario DECIMAL(10,2)
)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2);
    SET v_subtotal = p_quantidade * p_preco_unitario;
    
    INSERT INTO itens_reserva (reserva_id, produto_id, quantidade, preco_unitario, subtotal)
    VALUES (p_reserva_id, p_produto_id, p_quantidade, p_preco_unitario, v_subtotal);
    
    -- Atualizar total da reserva
    UPDATE reservas 
    SET total = (SELECT SUM(subtotal) FROM itens_reserva WHERE reserva_id = p_reserva_id)
    WHERE id = p_reserva_id;
END //
DELIMITER ;

-- Function: Calcular total do carrinho do cliente
DELIMITER //
CREATE FUNCTION fn_total_carrinho(p_cliente_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    
    SELECT SUM(p.preco * c.quantidade) INTO v_total
    FROM carrinho_temporario c
    INNER JOIN produtos p ON c.produto_id = p.id
    WHERE c.cliente_id = p_cliente_id;
    
    RETURN IFNULL(v_total, 0);
END //
DELIMITER ;

-- =====================================================
-- =====================================================
-- TRIGGERS
-- =====================================================
-- =====================================================

-- Trigger: Log de acesso de clientes
DELIMITER //
CREATE TRIGGER trg_log_cliente_login
AFTER INSERT ON logs_acesso
FOR EACH ROW
BEGIN
    -- Trigger para registrar logs de acesso
    -- Pode ser expandida conforme necessidade
END //
DELIMITER ;

-- =====================================================
-- =====================================================
-- CONSULTAS ÚTEIS
-- =====================================================

-- 1. Verificar login do funcionário
-- SELECT * FROM funcionarios WHERE email = 'ezequielaraujo008@gmail.com' AND senha = MD5('250508');

-- 2. Verificar login do cliente
-- SELECT * FROM clientes WHERE email = 'cliente@teste.com' AND senha = MD5('123456');

-- 3. Listar produtos em destaque e ativos
-- SELECT * FROM vw_produtos_completo WHERE destaque = 1 AND ativo = 1;

-- 4. Listar reservas pendentes
-- SELECT * FROM vw_reservas_completo WHERE status = 'pendente';

-- 5. Total de vendas por mês
-- SELECT DATE_FORMAT(created_at, '%Y-%m') AS mes, SUM(total) AS total_vendas 
-- FROM reservas WHERE status IN ('confirmada', 'finalizada') 
-- GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY mes DESC;

-- 6. Produtos com estoque baixo (< 10 unidades)
-- SELECT nome, estoque FROM produtos WHERE estoque < 10 AND ativo = 1;

-- 7. Ranking de produtos mais vendidos
-- SELECT p.nome, SUM(ir.quantidade) AS total_vendido 
-- FROM itens_reserva ir 
-- INNER JOIN produtos p ON ir.produto_id = p.id 
-- GROUP BY p.id ORDER BY total_vendido DESC LIMIT 10;

-- =====================================================
-- =====================================
================
-- USUÁRIOS E PERMISSÕES (opcional)
-- =====================================================
-- =====================================================

-- Criar usuário para a aplicação
-- CREATE USER 'app_mercadinho'@'localhost' IDENTIFIED BY 'senha_segura';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON mercadinho_pereira.* TO 'app_mercadinho'@'localhost';
-- FLUSH PRIVILEGES;

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================-- =====================================================
-- BANCO DE DADOS - MERCADINHO PEREIRA
-- Sistema de Reserva Online
-- =====================================================

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS mercadinho_pereira;
USE mercadinho_pereira;

-- =====================================================
-- TABELA: categorias
-- =====================================================
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- TABELA: clientes
-- Campos: id (PK), nome, email, telefone, cpf, senha
-- =====================================================
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    status TINYINT DEFAULT 1 COMMENT '1=ativo, 0=inativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_cpf (cpf)
);

-- =====================================================
-- TABELA: funcionarios
-- =====================================================
CREATE TABLE funcionarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    cargo VARCHAR(100),
    status TINYINT DEFAULT 1 COMMENT '1=ativo, 0=inativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
);

-- =====================================================
-- TABELA: produtos
-- Campos: id (PK), categoria_id (FK), nome, descricao, preco, estoque, imagem, destaque, ativo
-- =====================================================
CREATE TABLE produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id INT NOT NULL,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    imagem VARCHAR(500),
    destaque TINYINT DEFAULT 0 COMMENT '1=destaque, 0=normal',
    ativo TINYINT DEFAULT 1 COMMENT '1=ativo, 0=inativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE RESTRICT,
    INDEX idx_categoria (categoria_id),
    INDEX idx_destaque (destaque),
    INDEX idx_ativo (ativo)
);

-- =====================================================
-- TABELA: reservas
-- =====================================================
CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    status ENUM('pendente', 'confirmada', 'finalizada', 'cancelada') DEFAULT 'pendente',
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
    INDEX idx_cliente (cliente_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- TABELA: itens_reserva
-- =====================================================
CREATE TABLE itens_reserva (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reserva_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reserva_id) REFERENCES reservas(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT,
    INDEX idx_reserva (reserva_id),
    INDEX idx_produto (produto_id)
);

-- =====================================================
-- TABELA: carrinho_temporario (para carrinhos não finalizados)
-- =====================================================
CREATE TABLE carrinho_temporario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_carrinho (cliente_id, produto_id),
    INDEX idx_cliente (cliente_id)
);

-- =====================================================
-- TABELA: logs_acesso (para auditoria)
-- =====================================================
CREATE TABLE logs_acesso (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_tipo ENUM('cliente', 'funcionario') NOT NULL,
    usuario_id INT NOT NULL,
    acao VARCHAR(100),
    ip VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_usuario (usuario_tipo, usuario_id),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- =====================================================
-- INSERÇÃO DE DADOS INICIAIS
-- =====================================================
-- =====================================================

-- 1. Inserir categorias
INSERT INTO categorias (id, nome, descricao) VALUES
(1, 'Alimentos', 'Alimentos não perecíveis e enlatados'),
(2, 'Bebidas', 'Refrigerantes, sucos, água e bebidas em geral'),
(3, 'Limpeza', 'Produtos de limpeza em geral'),
(4, 'Higiene', 'Produtos de higiene pessoal'),
(5, 'Hortifrúti', 'Frutas, verduras e legumes');

-- 2. Inserir funcionário (Ezequiel Araújo)
-- Senha: 250508 (hash em MD5 para demonstração)
INSERT INTO funcionarios (id, nome, email, senha, cargo, status) VALUES
(1, 'Ezequiel Araújo', 'ezequielaraujo008@gmail.com', MD5('250508'), 'Administrador', 1);

-- 3. Inserir clientes de exemplo
INSERT INTO clientes (id, nome, email, telefone, cpf, senha, status) VALUES
(1, 'Cliente Teste', 'cliente@teste.com', '(21) 99999-9999', '123.456.789-00', MD5('123456'), 1),
(2, 'Maria Silva', 'maria@email.com', '(21) 98888-7777', '111.222.333-44', MD5('maria123'), 1),
(3, 'João Santos', 'joao@email.com', '(21) 97777-6666', '555.666.777-88', MD5('joao123'), 1);

-- 4. Inserir produtos
INSERT INTO produtos (id, categoria_id, nome, descricao, preco, estoque, imagem, destaque, ativo) VALUES
(1, 1, 'Arroz Branco Tipo 1', 'Arroz branco tipo 1 - Pacote 5kg', 25.90, 50, 'https://images.unsplash.com/photo-1586201375761-83865001e8ac?w=300&h=200&fit=crop', 1, 1),
(2, 1, 'Feijão Carioca', 'Feijão carioca tipo 1 - Pacote 1kg', 8.90, 100, 'https://images.unsplash.com/photo-1584483766114-2cea6facdf57?w=300&h=200&fit=crop', 1, 1),
(3, 2, 'Refrigerante Cola', 'Refrigerante cola 2L', 9.90, 80, 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=300&h=200&fit=crop', 1, 1),
(4, 1, 'Macarrão Espaguete', 'Macarrão espaguete 500g', 4.90, 60, 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=300&h=200&fit=crop', 0, 1),
(5, 1, 'Óleo de Soja', 'Óleo de soja 900ml', 7.90, 40, 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=300&h=200&fit=crop', 0, 1),
(6, 1, 'Leite Integral', 'Leite integral 1L', 5.50, 70, 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=300&h=200&fit=crop', 1, 1),
(7, 1, 'Café Torrado', 'Café torrado e moído 500g', 12.90, 45, 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=300&h=200&fit=crop', 0, 1),
(8, 3, 'Sabão em Pó', 'Sabão em pó 1kg', 8.90, 35, 'https://images.unsplash.com/photo-1583947581927-860cda6ba47c?w=300&h=200&fit=crop', 1, 1),
(9, 4, 'Shampoo', 'Shampoo 350ml', 12.90, 30, 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=300&h=200&fit=crop', 0, 1),
(10, 5, 'Banana Prata', 'Banana prata - kg', 6.90, 50, 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=300&h=200&fit=crop', 1, 1),
(11, 5, 'Maçã Nacional', 'Maçã nacional - kg', 7.90, 40, 'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?w=300&h=200&fit=crop', 0, 1),
(12, 2, 'Água Mineral', 'Água mineral sem gás 500ml', 2.50, 200, 'https://images.unsplash.com/photo-1616118132534-38129cdc9a83?w=300&h=200&fit=crop', 1, 1);

-- 5. Inserir reservas de exemplo
INSERT INTO reservas (id, cliente_id, total, status, observacoes, created_at) VALUES
(1, 1, 35.80, 'confirmada', 'Retirar após as 18h', '2025-03-20 10:30:00'),
(2, 2, 27.40, 'pendente', NULL, '2025-03-21 14:15:00'),
(3, 1, 42.30, 'finalizada', 'Entregue no balcão', '2025-03-19 09:45:00'),
(4, 3, 15.50, 'cancelada', 'Cliente cancelou', '2025-03-18 16:20:00');

-- 6. Inserir itens das reservas
INSERT INTO itens_reserva (id, reserva_id, produto_id, quantidade, preco_unitario, subtotal) VALUES
-- Reserva 1
(1, 1, 1, 1, 25.90, 25.90),
(2, 1, 4, 2, 4.90, 9.80),
-- Reserva 2
(3, 2, 6, 2, 5.50, 11.00),
(4, 2, 10, 1, 6.90, 6.90),
(5, 2, 12, 2, 2.50, 5.00),
(6, 2, 7, 1, 12.90, 12.90),
-- Reserva 3
(7, 3, 2, 2, 8.90, 17.80),
(8, 3, 3, 1, 9.90, 9.90),
(9, 3, 5, 1, 7.90, 7.90),
(10, 3, 8, 1, 8.90, 8.90),
-- Reserva 4
(11, 4, 9, 1, 12.90, 12.90),
(12, 4, 12, 1, 2.50, 2.50);

-- 7. Inserir carrinho temporário de exemplo
INSERT INTO carrinho_temporario (cliente_id, produto_id, quantidade) VALUES
(2, 1, 1),
(2, 3, 2),
(2, 8, 1);

-- =====================================================
-- =====================================================
-- VIEWS PARA CONSULTAS COMUNS
-- =====================================================
-- =====================================================

-- VIEW: Produtos com nome da categoria
CREATE VIEW vw_produtos_completo AS
SELECT 
    p.id,
    p.nome,
    p.descricao,
    p.preco,
    p.estoque,
    p.imagem,
    p.destaque,
    p.ativo,
    p.categoria_id,
    c.nome AS categoria_nome,
    p.created_at,
    p.updated_at
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- VIEW: Reservas com dados do cliente
CREATE VIEW vw_reservas_completo AS
SELECT 
    r.id,
    r.cliente_id,
    c.nome AS cliente_nome,
    c.email AS cliente_email,
    c.telefone AS cliente_telefone,
    r.total,
    r.status,
    r.observacoes,
    r.created_at,
    r.updated_at
FROM reservas r
INNER JOIN clientes c ON r.cliente_id = c.id;

-- VIEW: Itens das reservas com detalhes do produto
CREATE VIEW vw_itens_reserva_completo AS
SELECT 
    ir.id,
    ir.reserva_id,
    ir.produto_id,
    p.nome AS produto_nome,
    p.imagem AS produto_imagem,
    ir.quantidade,
    ir.preco_unitario,
    ir.subtotal
FROM itens_reserva ir
INNER JOIN produtos p ON ir.produto_id = p.id;

-- =====================================================
-- =====================================================
-- PROCEDURES E FUNÇÕES
-- =====================================================
-- =====================================================

-- Procedure: Atualizar estoque após reserva
DELIMITER //
CREATE PROCEDURE sp_atualizar_estoque(IN p_reserva_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_produto_id INT;
    DECLARE v_quantidade INT;
    DECLARE cur CURSOR FOR SELECT produto_id, quantidade FROM itens_reserva WHERE reserva_id = p_reserva_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_produto_id, v_quantidade;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        UPDATE produtos SET estoque = estoque - v_quantidade WHERE id = v_produto_id;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;

-- Procedure: Criar nova reserva
DELIMITER //
CREATE PROCEDURE sp_criar_reserva(
    IN p_cliente_id INT,
    IN p_total DECIMAL(10,2),
    IN p_observacoes TEXT,
    OUT p_reserva_id INT
)
BEGIN
    INSERT INTO reservas (cliente_id, total, observacoes, status) 
    VALUES (p_cliente_id, p_total, p_observacoes, 'pendente');
    
    SET p_reserva_id = LAST_INSERT_ID();
END //
DELIMITER ;

-- Procedure: Adicionar item à reserva
DELIMITER //
CREATE PROCEDURE sp_adicionar_item_reserva(
    IN p_reserva_id INT,
    IN p_produto_id INT,
    IN p_quantidade INT,
    IN p_preco_unitario DECIMAL(10,2)
)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2);
    SET v_subtotal = p_quantidade * p_preco_unitario;
    
    INSERT INTO itens_reserva (reserva_id, produto_id, quantidade, preco_unitario, subtotal)
    VALUES (p_reserva_id, p_produto_id, p_quantidade, p_preco_unitario, v_subtotal);
    
    -- Atualizar total da reserva
    UPDATE reservas 
    SET total = (SELECT SUM(subtotal) FROM itens_reserva WHERE reserva_id = p_reserva_id)
    WHERE id = p_reserva_id;
END //
DELIMITER ;

-- Function: Calcular total do carrinho do cliente
DELIMITER //
CREATE FUNCTION fn_total_carrinho(p_cliente_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    
    SELECT SUM(p.preco * c.quantidade) INTO v_total
    FROM carrinho_temporario c
    INNER JOIN produtos p ON c.produto_id = p.id
    WHERE c.cliente_id = p_cliente_id;
    
    RETURN IFNULL(v_total, 0);
END //
DELIMITER ;

-- =====================================================
-- =====================================================
-- TRIGGERS
-- =====================================================
-- =====================================================

-- Trigger: Log de acesso de clientes
DELIMITER //
CREATE TRIGGER trg_log_cliente_login
AFTER INSERT ON logs_acesso
FOR EACH ROW
BEGIN
    -- Trigger para registrar logs de acesso
    -- Pode ser expandida conforme necessidade
END //
DELIMITER ;

-- =====================================================
-- =====================================================
-- CONSULTAS ÚTEIS
-- =====================================================

-- 1. Verificar login do funcionário
-- SELECT * FROM funcionarios WHERE email = 'ezequielaraujo008@gmail.com' AND senha = MD5('250508');

-- 2. Verificar login do cliente
-- SELECT * FROM clientes WHERE email = 'cliente@teste.com' AND senha = MD5('123456');

-- 3. Listar produtos em destaque e ativos
-- SELECT * FROM vw_produtos_completo WHERE destaque = 1 AND ativo = 1;

-- 4. Listar reservas pendentes
-- SELECT * FROM vw_reservas_completo WHERE status = 'pendente';

-- 5. Total de vendas por mês
-- SELECT DATE_FORMAT(created_at, '%Y-%m') AS mes, SUM(total) AS total_vendas 
-- FROM reservas WHERE status IN ('confirmada', 'finalizada') 
-- GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY mes DESC;

-- 6. Produtos com estoque baixo (< 10 unidades)
-- SELECT nome, estoque FROM produtos WHERE estoque < 10 AND ativo = 1;

-- 7. Ranking de produtos mais vendidos
-- SELECT p.nome, SUM(ir.quantidade) AS total_vendido 
-- FROM itens_reserva ir 
-- INNER JOIN produtos p ON ir.produto_id = p.id 
-- GROUP BY p.id ORDER BY total_vendido DESC LIMIT 10;

-- =====================================================
-- =====================================
-- USUÁRIOS E PERMISSÕES (opcional)
-- =====================================================
-- =====================================================

-- Criar usuário para a aplicação
-- CREATE USER 'app_mercadinho'@'localhost' IDENTIFIED BY 'senha_segura';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON mercadinho_pereira.* TO 'app_mercadinho'@'localhost';
-- FLUSH PRIVILEGES;

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================