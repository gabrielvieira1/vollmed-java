-- Remove apenas as contas geradas automaticamente pela versão antiga da V12.
-- Contas com senhas alteradas posteriormente não são afetadas.
DELETE FROM usuario_grupos
WHERE usuario_id IN (
    SELECT id
    FROM usuarios
    WHERE paciente_id IS NOT NULL
      AND senha = '$2a$10$YQN0g5J5qJ5J5J5J5J5J5eK5J5J5J5J5J5J5J5J5J5J5J5J5J5J5K'
);

DELETE FROM usuarios
WHERE paciente_id IS NOT NULL
  AND senha = '$2a$10$YQN0g5J5qJ5J5J5J5J5J5eK5J5J5J5J5J5J5J5J5J5J5J5J5J5J5K';
