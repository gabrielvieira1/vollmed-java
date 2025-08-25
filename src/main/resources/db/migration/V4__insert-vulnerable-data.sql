INSERT INTO usuarios (nome, email, senha) VALUES
('Administrador', 'admin@vollmed.com', 'admin123'),
('Sistema', 'system@vollmed.com', 'VollMed2024!@#');

INSERT INTO medicos (nome, email, telefone, crm, especialidade) VALUES
('Dr. João Silva', 'joao.silva@vollmed.com', '11999999999', '123456', 'CARDIOLOGIA'),
('Dra. Maria Santos', 'maria.santos@vollmed.com', '11888888888', '654321', 'DERMATOLOGIA');

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

INSERT INTO consultas (medico_id, paciente, data) VALUES
(1, 'João da Silva - CPF: 12345678901', '2024-08-20 10:00:00'),
(2, 'Maria Oliveira - CPF: 98765432100', '2024-08-20 14:00:00');
