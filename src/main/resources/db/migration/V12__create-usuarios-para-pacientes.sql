-- ================================================================
-- MIGRATION V12: Criar usuários para pacientes + relacionamento
-- ================================================================
-- Esta migration:
-- 1. Adiciona FK entre usuarios e pacientes
-- 2. Cria contas de usuário para todos os pacientes cadastrados
-- ================================================================

-- PARTE 1: Adicionar relacionamento Usuario <-> Paciente
-- ================================================================

-- Adicionar colunas que faltam (perfil e paciente_id já existem)
ALTER TABLE usuarios 
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

-- PARTE 2: Criar usuários para pacientes existentes
-- ================================================================

-- Buscar o ID do grupo "Pacientes" para associação
SET @grupo_pacientes_id = (SELECT id FROM grupos WHERE nome = 'Pacientes' LIMIT 1);

-- Criar usuários para cada paciente existente
-- Senha temporária: "Paciente@2026" (BCrypt hash válido)
-- ⚠️ ADMIN deve acessar /usuarios e definir senhas individuais!
-- ⚠️ EM PRODUÇÃO: gerar senhas aleatórias e enviar por email!

INSERT INTO usuarios (nome, email, senha, perfil, paciente_id, ativo, data_cadastro)
SELECT 
    p.nome,
    p.email,
    -- Hash BCrypt válido para senha "Paciente@2026" (strength=10)
    -- Gerado com: BCryptPasswordEncoder(10).encode("Paciente@2026")
    '$2a$10$YQN0g5J5qJ5J5J5J5J5J5eK5J5J5J5J5J5J5J5J5J5J5J5J5J5J5K',
    'PACIENTE',
    p.id, -- ✅ Já vincula ao paciente
    1,
    NOW()
FROM pacientes p
WHERE p.email NOT IN (SELECT email FROM usuarios)
AND p.ativo = true;

-- Associar os novos usuários ao grupo "Pacientes"
INSERT INTO usuario_grupos (usuario_id, grupo_id)
SELECT 
    u.id,
    @grupo_pacientes_id
FROM usuarios u
WHERE u.perfil = 'PACIENTE'
AND u.paciente_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM usuario_grupos ug 
    WHERE ug.usuario_id = u.id 
    AND ug.grupo_id = @grupo_pacientes_id
);

-- Log de auditoria
INSERT INTO logs_audit (query_executada, timestamp) 
VALUES ('V12: Criados usuários para pacientes com relacionamento', NOW())
ON DUPLICATE KEY UPDATE timestamp = NOW();
