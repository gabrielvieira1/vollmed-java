-- ======================================
-- Sistema de RBAC (Role-Based Access Control)
-- ======================================

-- Tabela de Recursos do Sistema
CREATE TABLE recursos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE COMMENT 'Nome do recurso (ex: medicos, pacientes)',
    descricao VARCHAR(255) NOT NULL COMMENT 'Descrição do recurso',
    icone VARCHAR(50) COMMENT 'Emoji ou ícone para exibição',
    ordem INT DEFAULT 0 COMMENT 'Ordem de exibição no menu',
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Permissões
CREATE TABLE permissoes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    recurso_id BIGINT NOT NULL,
    acao VARCHAR(50) NOT NULL COMMENT 'Ação (LISTAR, CRIAR, EDITAR, EXCLUIR, VISUALIZAR)',
    descricao VARCHAR(255) NOT NULL,
    FOREIGN KEY (recurso_id) REFERENCES recursos(id) ON DELETE CASCADE,
    UNIQUE KEY uk_recurso_acao (recurso_id, acao)
);

-- Tabela de Grupos (Perfis Personalizados)
CREATE TABLE grupos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    padrao BOOLEAN DEFAULT FALSE COMMENT 'Se é um grupo padrão do sistema',
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Permissões por Grupo
CREATE TABLE grupo_permissoes (
    grupo_id BIGINT NOT NULL,
    permissao_id BIGINT NOT NULL,
    PRIMARY KEY (grupo_id, permissao_id),
    FOREIGN KEY (grupo_id) REFERENCES grupos(id) ON DELETE CASCADE,
    FOREIGN KEY (permissao_id) REFERENCES permissoes(id) ON DELETE CASCADE
);

-- Tabela de Usuários-Grupos (um usuário pode ter múltiplos grupos)
CREATE TABLE usuario_grupos (
    usuario_id BIGINT NOT NULL,
    grupo_id BIGINT NOT NULL,
    data_atribuicao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, grupo_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (grupo_id) REFERENCES grupos(id) ON DELETE CASCADE
);

-- ======================================
-- Dados Iniciais
-- ======================================

-- Inserir Recursos do Sistema
INSERT INTO recursos (nome, descricao, icone, ordem) VALUES
('medicos', 'Gestão de Médicos', '👨‍⚕️', 1),
('pacientes', 'Gestão de Pacientes', '🏥', 2),
('consultas', 'Gestão de Consultas', '📅', 3),
('relatorios', 'Relatórios Médicos', '📊', 4),
('usuarios', 'Gestão de Usuários', '🔐', 5),
('grupos', 'Gestão de Grupos e Permissões', '👥', 6);

-- Inserir Permissões para cada Recurso
INSERT INTO permissoes (recurso_id, acao, descricao) VALUES
-- Médicos
(1, 'LISTAR', 'Visualizar lista de médicos'),
(1, 'CRIAR', 'Cadastrar novos médicos'),
(1, 'EDITAR', 'Editar dados de médicos'),
(1, 'EXCLUIR', 'Excluir médicos'),
(1, 'BUSCAR', 'Buscar médicos por nome'),

-- Pacientes
(2, 'LISTAR', 'Visualizar lista de pacientes'),
(2, 'CRIAR', 'Cadastrar novos pacientes'),
(2, 'EDITAR', 'Editar dados de pacientes'),
(2, 'EXCLUIR', 'Excluir pacientes'),
(2, 'BUSCAR', 'Buscar pacientes por nome'),

-- Consultas
(3, 'LISTAR', 'Visualizar lista de consultas'),
(3, 'CRIAR', 'Agendar novas consultas'),
(3, 'EDITAR', 'Editar consultas'),
(3, 'EXCLUIR', 'Cancelar consultas'),
(3, 'VISUALIZAR', 'Ver detalhes de consultas'),

-- Relatórios
(4, 'LISTAR', 'Visualizar lista de relatórios'),
(4, 'CRIAR', 'Criar novos relatórios'),
(4, 'EDITAR', 'Editar relatórios'),
(4, 'EXCLUIR', 'Excluir relatórios'),
(4, 'EXPORTAR', 'Exportar relatórios em PDF'),

-- Usuários
(5, 'LISTAR', 'Visualizar lista de usuários'),
(5, 'CRIAR', 'Cadastrar novos usuários'),
(5, 'EDITAR', 'Editar dados de usuários'),
(5, 'EXCLUIR', 'Excluir usuários'),

-- Grupos
(6, 'LISTAR', 'Visualizar grupos'),
(6, 'CRIAR', 'Criar novos grupos'),
(6, 'EDITAR', 'Editar grupos e permissões'),
(6, 'EXCLUIR', 'Excluir grupos');

-- Criar Grupos Padrão
INSERT INTO grupos (nome, descricao, padrao) VALUES
('Administradores', 'Acesso total ao sistema', TRUE),
('Médicos', 'Acesso a consultas, pacientes e relatórios', TRUE),
('Pacientes', 'Acesso apenas às próprias consultas', TRUE),
('Recepcionistas', 'Acesso a agendamento de consultas', TRUE);

-- Atribuir TODAS as permissões ao grupo Administradores
INSERT INTO grupo_permissoes (grupo_id, permissao_id)
SELECT 1, id FROM permissoes;

-- Atribuir permissões ao grupo Médicos
INSERT INTO grupo_permissoes (grupo_id, permissao_id)
SELECT 2, id FROM permissoes WHERE recurso_id IN (
    SELECT id FROM recursos WHERE nome IN ('medicos', 'pacientes', 'consultas', 'relatorios')
);

-- Atribuir permissões ao grupo Pacientes (apenas listar e visualizar consultas)
INSERT INTO grupo_permissoes (grupo_id, permissao_id)
SELECT 3, id FROM permissoes WHERE recurso_id = (
    SELECT id FROM recursos WHERE nome = 'consultas'
) AND acao IN ('LISTAR', 'VISUALIZAR');

-- Atribuir permissões ao grupo Recepcionistas (consultas completas)
INSERT INTO grupo_permissoes (grupo_id, permissao_id)
SELECT 4, id FROM permissoes WHERE recurso_id = (
    SELECT id FROM recursos WHERE nome = 'consultas'
);

-- Migrar usuários existentes para o novo sistema de grupos
-- Admin (assumindo que existe um admin com id específico)
INSERT INTO usuario_grupos (usuario_id, grupo_id)
SELECT id, 1 FROM usuarios WHERE perfil = 'ADMIN';

-- Médicos
INSERT INTO usuario_grupos (usuario_id, grupo_id)
SELECT id, 2 FROM usuarios WHERE perfil = 'MEDICO';

-- Pacientes
INSERT INTO usuario_grupos (usuario_id, grupo_id)
SELECT id, 3 FROM usuarios WHERE perfil = 'PACIENTE';

-- Recepcionistas
INSERT INTO usuario_grupos (usuario_id, grupo_id)
SELECT id, 4 FROM usuarios WHERE perfil = 'RECEPCIONISTA';
