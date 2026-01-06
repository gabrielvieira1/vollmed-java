CREATE TABLE pacientes (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    endereco VARCHAR(500),
    plano_saude VARCHAR(100),
    numero_carteirinha VARCHAR(50),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    INDEX idx_nome (nome),
    INDEX idx_cpf (cpf),
    INDEX idx_email (email),
    INDEX idx_ativo (ativo)
);
