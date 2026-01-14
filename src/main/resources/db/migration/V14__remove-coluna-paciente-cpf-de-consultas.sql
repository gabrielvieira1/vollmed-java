-- ================================================================
-- MIGRATION V14: Remover coluna paciente (CPF) de consultas
-- ================================================================
-- Agora que temos paciente_id como FK, a coluna paciente (CPF)
-- está redundante e pode ser removida
-- ================================================================

-- Antes de remover, garantir que todas as consultas têm paciente_id preenchido
-- Se houver consultas sem paciente_id, tentar preencher via CPF

UPDATE consultas c
INNER JOIN pacientes p ON c.paciente = p.cpf
SET c.paciente_id = p.id
WHERE c.paciente_id IS NULL 
AND c.paciente IS NOT NULL;

-- Remover a coluna paciente (CPF)
ALTER TABLE consultas DROP COLUMN paciente;

-- Log de auditoria
INSERT INTO logs_audit (query_executada, timestamp) 
VALUES ('V14: Removida coluna paciente (CPF) de consultas - usando apenas paciente_id', NOW())
ON DUPLICATE KEY UPDATE timestamp = NOW();
