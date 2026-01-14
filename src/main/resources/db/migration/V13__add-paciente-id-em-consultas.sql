-- ================================================================
-- MIGRATION V13: Adicionar FK paciente_id na tabela consultas
-- ================================================================
-- Relaciona consultas diretamente aos pacientes por ID
-- ================================================================

-- Adicionar coluna paciente_id
ALTER TABLE consultas 
ADD COLUMN paciente_id BIGINT NULL AFTER medico_id;

-- Tentar vincular consultas existentes aos pacientes pelo campo texto
-- (extrai CPF do campo paciente e busca na tabela pacientes)
UPDATE consultas c
INNER JOIN pacientes p ON SUBSTRING_INDEX(SUBSTRING_INDEX(c.paciente, 'CPF: ', -1), ' ', 1) = p.cpf
SET c.paciente_id = p.id
WHERE c.paciente_id IS NULL;

-- Criar foreign key constraint
ALTER TABLE consultas 
ADD CONSTRAINT fk_consulta_paciente 
FOREIGN KEY (paciente_id) REFERENCES pacientes(id) 
ON DELETE CASCADE;

-- Criar índice para performance
CREATE INDEX idx_consulta_paciente ON consultas(paciente_id);

-- Log de auditoria
INSERT INTO logs_audit (query_executada, timestamp) 
VALUES ('V13: FK paciente_id adicionada em consultas', NOW())
ON DUPLICATE KEY UPDATE timestamp = NOW();
