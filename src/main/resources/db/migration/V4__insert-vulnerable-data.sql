-- MIGRATION VULNERÁVEL PARA FINS EDUCACIONAIS
-- Esta migration contém vulnerabilidades intencionais que o Semgrep deve detectar

-- VULNERABILIDADE 1: Usuário admin com senha hardcoded
INSERT INTO usuarios (nome, email, senha) VALUES
('Administrador', 'admin@vollmed.com', 'admin123'),
('Sistema', 'system@vollmed.com', 'VollMed2024!@#');

-- VULNERABILIDADE 2: Médicos com dados falsos mas credenciais expostas
INSERT INTO medicos (nome, email, telefone, crm, especialidade) VALUES
('Dr. João Silva', 'joao.silva@vollmed.com', '11999999999', '123456', 'CARDIOLOGIA'),
('Dra. Maria Santos', 'maria.santos@vollmed.com', '11888888888', '654321', 'DERMATOLOGIA');

-- VULNERABILIDADE 3: Tabela de configurações com chaves sensíveis
CREATE TABLE configuracoes_sistema (
    id BIGINT NOT NULL AUTO_INCREMENT,
    chave VARCHAR(100) NOT NULL,
    valor TEXT NOT NULL,
    PRIMARY KEY(id)
);

INSERT INTO configuracoes_sistema (chave, valor) VALUES
('database_password', 'VollMed2024DatabasePass'),
('api_secret_key', 'sk_live_vollmed_1234567890abcdef'),
('jwt_secret', 'myJWTSecretKeyThatShouldNotBeHardcoded123456789'),
('encryption_key', 'MyMasterEncryptionKey123!@#$%^&*()'),
('admin_token', 'admin_token_vollmed_secure_2024'),
('backup_credentials', 'user:vollmed_backup,pass:BackupPass2024!@#');

-- VULNERABILIDADE 4: Usuário de banco com privilégios excessivos
-- CREATE USER 'vollmed_app'@'%' IDENTIFIED BY 'VollMedAppPassword2024';
-- GRANT ALL PRIVILEGES ON vollmed_web.* TO 'vollmed_app'@'%';

-- VULNERABILIDADE 5: Dados de teste com informações reais simuladas
INSERT INTO consultas (medico_id, paciente, data) VALUES
(1, 'João da Silva - CPF: 12345678901', '2024-08-20 10:00:00'),
(2, 'Maria Oliveira - CPF: 98765432100', '2024-08-20 14:00:00');

-- VULNERABILIDADE 6: Comentários com informações sensíveis
-- Senha do servidor de produção: ProdServer2024!@#
-- IP do banco: 192.168.1.100
-- Usuário root: root / VollMedRoot2024
