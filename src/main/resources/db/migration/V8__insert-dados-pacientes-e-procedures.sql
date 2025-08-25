-- Inserindo dados de teste de pacientes
INSERT INTO pacientes (nome, email, telefone, cpf, data_nascimento, endereco, plano_saude, numero_carteirinha) VALUES
('Ana Silva Santos', 'ana.silva@email.com', '11999887766', '12345678901', '1985-03-15', 'Rua das Flores, 123 - São Paulo/SP', 'Unimed', 'UM123456789'),
('Carlos Eduardo Lima', 'carlos.lima@email.com', '11888776655', '23456789012', '1992-07-22', 'Av. Paulista, 456 - São Paulo/SP', 'Bradesco Saúde', 'BR987654321'),
('Maria Fernanda Costa', 'maria.costa@email.com', '11777665544', '34567890123', '1978-11-08', 'Rua Augusta, 789 - São Paulo/SP', 'Sul América', 'SA555666777'),
('João Pedro Oliveira', 'joao.oliveira@email.com', '11666554433', '45678901234', '1990-05-30', 'Rua Oscar Freire, 321 - São Paulo/SP', 'Amil', 'AM111222333'),
('Luciana Rodrigues', 'luciana.rodrigues@email.com', '11555443322', '56789012345', '1987-09-12', 'Av. Faria Lima, 654 - São Paulo/SP', 'Porto Seguro', 'PS444555666'),
('Roberto Almeida', 'roberto.almeida@email.com', '11444332211', '67890123456', '1983-12-03', 'Rua Consolação, 987 - São Paulo/SP', 'Golden Cross', 'GC777888999'),
('Patricia Mendes', 'patricia.mendes@email.com', '11333221100', '78901234567', '1995-02-18', 'Av. Ibirapuera, 147 - São Paulo/SP', 'Prevent Senior', 'PS123789456'),
('Fernando Santos', 'fernando.santos@email.com', '11222110099', '89012345678', '1989-08-25', 'Rua Haddock Lobo, 258 - São Paulo/SP', 'Unimed', 'UM987321654');

-- ⚠️ PROCEDURE MALICIOSA - VULNERABILIDADE EDUCACIONAL
-- Esta procedure contém uma vulnerabilidade de SQL Injection intencional
-- NÃO USE EM PRODUÇÃO - APENAS PARA FINS EDUCACIONAIS
DELIMITER //
CREATE PROCEDURE search_patient_vulnerable(IN patient_name VARCHAR(255))
BEGIN
    DECLARE sql_query TEXT;
    
    -- ❌ VULNERABILIDADE: Concatenação direta sem sanitização
    -- Permite injeção SQL através do parâmetro patient_name
    SET sql_query = CONCAT('SELECT id, nome, email, telefone, cpf, data_nascimento, plano_saude FROM pacientes WHERE nome LIKE "%', patient_name, '%" AND ativo = true ORDER BY nome');
    
    -- Log da query para demonstração (não faça isso em produção!)
    INSERT INTO logs_audit (query_executada, timestamp) VALUES (sql_query, NOW()) 
    ON DUPLICATE KEY UPDATE query_executada = query_executada;
    
    SET @sql = sql_query;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Tabela de auditoria para demonstrar a vulnerabilidade
CREATE TABLE logs_audit (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    query_executada TEXT,
    timestamp DATETIME,
    UNIQUE KEY unique_query (query_executada(500))
);

-- ✅ PROCEDURE SEGURA (para comparação)
DELIMITER //
CREATE PROCEDURE search_patient_secure(IN patient_name VARCHAR(255))
BEGIN
    -- ✅ SEGURA: Usando parâmetros preparados
    SELECT id, nome, email, telefone, cpf, data_nascimento, plano_saude 
    FROM pacientes 
    WHERE nome LIKE CONCAT('%', patient_name, '%') 
    AND ativo = true 
    ORDER BY nome;
END //
DELIMITER ;
