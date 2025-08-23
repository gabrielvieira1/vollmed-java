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

-- Comentários explicando as vulnerabilidades intencionais da estrutura:

-- VULNERABILIDADE 1: Armazenamento de dados sensíveis sem hash adequado
-- Os campos 'cpf_paciente' e 'numero_sus' estão armazenados em texto claro
-- Em um sistema seguro, estes dados deveriam ser hasheados ou criptografados adequadamente

-- VULNERABILIDADE 2: Índices em dados sensíveis
-- Os índices em 'cpf_paciente' e 'numero_sus' facilitam buscas, mas também
-- tornam estes dados mais expostos a ataques de inferência

-- VULNERABILIDADE 3: Campo para criptografia insegura
-- O campo 'dados_criptografados' será usado para demonstrar falhas de criptografia
-- utilizando algoritmos obsoletos (DES) e modos inseguros (ECB)

-- VULNERABILIDADE 4: Cascade delete inadequado
-- O CASCADE DELETE no médico pode causar perda de dados históricos importantes
-- Em sistemas de saúde, dados históricos devem ser preservados

-- VULNERABILIDADE 5: Falta de auditoria
-- Não há campos para rastreamento de modificações (created_by, updated_by, etc.)
-- Isso dificulta a auditoria e compliance com regulamentações de saúde
