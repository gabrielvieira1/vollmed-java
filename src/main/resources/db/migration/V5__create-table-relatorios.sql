CREATE TABLE relatorios (
    id BIGINT NOT NULL AUTO_INCREMENT,
    consulta_id BIGINT,
    medico_id BIGINT NOT NULL,
    diagnostico TEXT NOT NULL,
    procedimento TEXT,
    historico_familiar TEXT,
    medicacao TEXT,
    observacoes_medicas TEXT,
    dados_criptografados LONGTEXT,
    data_geracao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    numero_sus VARCHAR(15) NOT NULL,
    cpf_paciente VARCHAR(14) NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (consulta_id) REFERENCES consultas(id) ON DELETE SET NULL,
    FOREIGN KEY (medico_id) REFERENCES medicos(id) ON DELETE CASCADE,

    INDEX idx_medico_id (medico_id),
    INDEX idx_data_geracao (data_geracao),
    INDEX idx_cpf_paciente (cpf_paciente),
    INDEX idx_numero_sus (numero_sus)
);