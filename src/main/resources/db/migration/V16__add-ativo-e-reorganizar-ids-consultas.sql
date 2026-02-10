-- Migration para adicionar deleção lógica e reorganizar IDs das consultas

-- Adicionar coluna ativo à tabela de consultas (verificando se não existe)
SET @col_exists = (SELECT COUNT(*) 
                   FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA = 'vollmed_web' 
                   AND TABLE_NAME = 'consultas' 
                   AND COLUMN_NAME = 'ativo');

SET @sql = IF(@col_exists = 0, 
              'ALTER TABLE consultas ADD COLUMN ativo TINYINT(1) NOT NULL DEFAULT 1',
              'SELECT ''Column ativo already exists'' AS message');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Reorganizar os IDs das consultas existentes
-- Primeiro, criar uma tabela temporária com os dados ordenados
CREATE TEMPORARY TABLE consultas_temp AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY data, id) as novo_id,
    id as id_antigo,
    medico_id,
    paciente_id,
    data,
    ativo
FROM consultas
ORDER BY data, id;

-- Desabilitar verificação de chaves estrangeiras temporariamente
SET FOREIGN_KEY_CHECKS = 0;

-- Limpar a tabela original
DELETE FROM consultas;

-- Resetar o auto_increment
ALTER TABLE consultas AUTO_INCREMENT = 1;

-- Inserir os dados com os novos IDs sequenciais
INSERT INTO consultas (id, medico_id, paciente_id, data, ativo)
SELECT novo_id, medico_id, paciente_id, data, ativo
FROM consultas_temp
ORDER BY novo_id;

-- Reabilitar verificação de chaves estrangeiras
SET FOREIGN_KEY_CHECKS = 1;

-- Remover tabela temporária
DROP TEMPORARY TABLE consultas_temp;

-- Ajustar o AUTO_INCREMENT para o próximo ID disponível
SET @max_id = (SELECT COALESCE(MAX(id), 0) + 1 FROM consultas);
SET @alter_sql = CONCAT('ALTER TABLE consultas AUTO_INCREMENT = ', @max_id);
PREPARE stmt FROM @alter_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
