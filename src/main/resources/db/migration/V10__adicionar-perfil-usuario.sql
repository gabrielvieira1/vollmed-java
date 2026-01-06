-- Adiciona coluna de perfil na tabela de usuários
ALTER TABLE usuarios ADD COLUMN perfil VARCHAR(20) NOT NULL DEFAULT 'PACIENTE';




