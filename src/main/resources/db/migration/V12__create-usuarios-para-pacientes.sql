-- ================================================================
-- MIGRATION V12: Criar usuários para pacientes + relacionamento
-- ================================================================
-- Esta migration:
-- 1. Adiciona FK entre usuarios e pacientes
-- 2. Prepara o relacionamento usado por contas de pacientes
-- ================================================================

-- PARTE 1: Adicionar relacionamento Usuario <-> Paciente
-- ================================================================

-- Adicionar relacionamento e colunas de controle que ainda não existem
ALTER TABLE usuarios
ADD COLUMN paciente_id BIGINT NULL AFTER perfil,
ADD COLUMN ativo BOOLEAN NOT NULL DEFAULT 1 AFTER paciente_id,
ADD COLUMN data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER ativo;

-- Criar foreign key constraint (pode já existir, então ignorar erro)
SET @constraint_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
    WHERE CONSTRAINT_SCHEMA = 'vollmed_web' 
    AND TABLE_NAME = 'usuarios' 
    AND CONSTRAINT_NAME = 'fk_usuario_paciente');

SET @sql = IF(@constraint_exists = 0,
    'ALTER TABLE usuarios ADD CONSTRAINT fk_usuario_paciente FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE SET NULL',
    'SELECT "FK já existe"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Criar índice para performance (pode já existir)
SET @index_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS 
    WHERE TABLE_SCHEMA = 'vollmed_web' 
    AND TABLE_NAME = 'usuarios' 
    AND INDEX_NAME = 'idx_usuario_paciente');

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_usuario_paciente ON usuarios(paciente_id)',
    'SELECT "Index já existe"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Atualizar usuários existentes com perfis (baseado em padrões de email/nome)
UPDATE usuarios SET perfil = 'ADMIN' WHERE email LIKE '%admin%';
UPDATE usuarios SET perfil = 'MEDICO' WHERE perfil = 'PACIENTE' AND (email LIKE '%dr%' OR email LIKE '%medico%');

-- Log de auditoria
INSERT INTO logs_audit (query_executada, timestamp) 
VALUES ('V12: Relacionamento entre usuarios e pacientes criado', NOW())
ON DUPLICATE KEY UPDATE timestamp = NOW();
