-- ⚠️ MIGRATION EDUCACIONAL - ADICIONA DADOS SENSÍVEIS PARA DEMONSTRAÇÃO DE SQL INJECTION
-- Esta migration adiciona colunas com dados sensíveis propositalmente para fins educacionais

ALTER TABLE medicos 
ADD COLUMN cpf VARCHAR(14),
ADD COLUMN rg VARCHAR(20),
ADD COLUMN data_nascimento DATE,
ADD COLUMN endereco VARCHAR(255),
ADD COLUMN salario DECIMAL(10,2),
ADD COLUMN numero_conta VARCHAR(20),
ADD COLUMN senha_sistema VARCHAR(100);

-- Atualizar dados existentes com informações sensíveis FAKE
UPDATE medicos SET 
    cpf = '123.456.789-01',
    rg = '12.345.678-9',
    data_nascimento = '1980-05-15',
    endereco = 'Rua das Flores, 123 - São Paulo/SP',
    salario = 15000.00,
    numero_conta = '12345-6',
    senha_sistema = 'senha123'
WHERE id = 1;

UPDATE medicos SET 
    cpf = '987.654.321-00',
    rg = '98.765.432-1',
    data_nascimento = '1985-08-20',
    endereco = 'Av. Paulista, 456 - São Paulo/SP',
    salario = 18000.00,
    numero_conta = '98765-4',
    senha_sistema = 'maria2024'
WHERE id = 2;

-- Inserir mais médicos com dados sensíveis para demonstração
INSERT INTO medicos (nome, email, telefone, crm, especialidade, cpf, rg, data_nascimento, endereco, salario, numero_conta, senha_sistema) VALUES
('Dr. Carlos Mendes', 'carlos.mendes@vollmed.com', '11777777777', '789012', 'ORTOPEDIA', '111.222.333-44', '11.222.333-4', '1978-03-10', 'Rua Augusta, 789 - São Paulo/SP', 16500.00, '11111-2', 'carlos@2024'),
('Dra. Ana Paula Costa', 'ana.costa@vollmed.com', '11666666666', '345678', 'GINECOLOGIA', '555.666.777-88', '55.666.777-8', '1990-11-25', 'Rua Oscar Freire, 321 - São Paulo/SP', 19000.00, '55555-6', 'ana#secure'),

-- CARDIOLOGIA (5 médicos adicionais)
('Dr. Roberto Cardoso', 'roberto.cardoso@vollmed.com', '11955555555', '111111', 'CARDIOLOGIA', '222.333.444-55', '22.333.444-5', '1975-02-14', 'Av. Rebouças, 1000 - São Paulo/SP', 17500.00, '22222-3', 'roberto123'),
('Dra. Juliana Ferreira', 'juliana.ferreira@vollmed.com', '11944444444', '222222', 'CARDIOLOGIA', '333.444.555-66', '33.444.555-6', '1982-07-22', 'Rua Haddock Lobo, 200 - São Paulo/SP', 16800.00, '33333-4', 'juliana@pass'),
('Dr. Fernando Lima', 'fernando.lima@vollmed.com', '11933333333', '333333', 'CARDIOLOGIA', '444.555.666-77', '44.555.666-7', '1988-12-03', 'Av. Faria Lima, 500 - São Paulo/SP', 18200.00, '44444-5', 'fernando2024'),
('Dra. Patricia Rocha', 'patricia.rocha@vollmed.com', '11922222222', '444444', 'CARDIOLOGIA', '555.666.777-11', '55.666.777-1', '1979-04-18', 'Rua Estados Unidos, 300 - São Paulo/SP', 17000.00, '55555-7', 'patricia#321'),
('Dr. Marcos Alves', 'marcos.alves@vollmed.com', '11911111111', '555555', 'CARDIOLOGIA', '666.777.888-22', '66.777.888-2', '1983-09-30', 'Av. Brigadeiro Faria Lima, 1500 - São Paulo/SP', 19500.00, '66666-8', 'marcos@secure'),

-- DERMATOLOGIA (5 médicos adicionais)
('Dr. Eduardo Santos', 'eduardo.santos@vollmed.com', '11900000000', '666666', 'DERMATOLOGIA', '777.888.999-33', '77.888.999-3', '1981-01-25', 'Rua Pamplona, 400 - São Paulo/SP', 15800.00, '77777-9', 'eduardo456'),
('Dra. Camila Souza', 'camila.souza@vollmed.com', '11899999999', '777777', 'DERMATOLOGIA', '888.999.000-44', '88.999.000-4', '1986-06-12', 'Av. Nove de Julho, 600 - São Paulo/SP', 16200.00, '88888-0', 'camila!pass'),
('Dr. Rafael Dias', 'rafael.dias@vollmed.com', '11888888887', '888888', 'DERMATOLOGIA', '999.000.111-55', '99.000.111-5', '1977-11-08', 'Rua Consolação, 700 - São Paulo/SP', 17800.00, '99999-1', 'rafael#2024'),
('Dra. Beatriz Costa', 'beatriz.costa@vollmed.com', '11877777777', '999999', 'DERMATOLOGIA', '000.111.222-66', '00.111.222-6', '1984-03-17', 'Av. Ipiranga, 800 - São Paulo/SP', 16500.00, '00000-2', 'beatriz@123'),
('Dr. Gustavo Ribeiro', 'gustavo.ribeiro@vollmed.com', '11866666666', '101010', 'DERMATOLOGIA', '111.222.333-77', '11.222.333-7', '1989-08-21', 'Rua da Consolação, 900 - São Paulo/SP', 18000.00, '11111-3', 'gustavo2024!'),

-- ORTOPEDIA (5 médicos adicionais)
('Dr. Lucas Martins', 'lucas.martins@vollmed.com', '11855555555', '121212', 'ORTOPEDIA', '222.333.444-88', '22.333.444-8', '1980-05-29', 'Av. Angélica, 1100 - São Paulo/SP', 17200.00, '22222-4', 'lucas@ortho'),
('Dra. Amanda Silva', 'amanda.silva@vollmed.com', '11844444444', '131313', 'ORTOPEDIA', '333.444.555-99', '33.444.555-9', '1985-10-14', 'Rua Vergueiro, 1200 - São Paulo/SP', 16900.00, '33333-5', 'amanda#secure'),
('Dr. Diego Pereira', 'diego.pereira@vollmed.com', '11833333333', '141414', 'ORTOPEDIA', '444.555.666-00', '44.555.666-0', '1978-02-07', 'Av. Pacaembu, 1300 - São Paulo/SP', 18500.00, '44444-6', 'diego123'),
('Dra. Renata Oliveira', 'renata.oliveira@vollmed.com', '11822222222', '151515', 'ORTOPEDIA', '555.666.777-22', '55.666.777-2', '1987-07-19', 'Rua Augusta, 1400 - São Paulo/SP', 17600.00, '55555-8', 'renata@2024'),
('Dr. Bruno Carvalho', 'bruno.carvalho@vollmed.com', '11811111111', '161616', 'ORTOPEDIA', '666.777.888-33', '66.777.888-3', '1982-12-24', 'Av. Ibirapuera, 1500 - São Paulo/SP', 19200.00, '66666-9', 'bruno!pass'),

-- GINECOLOGIA (5 médicos adicionais)
('Dr. Thiago Gomes', 'thiago.gomes@vollmed.com', '11800000000', '171717', 'GINECOLOGIA', '777.888.999-44', '77.888.999-4', '1976-04-11', 'Rua Bela Cintra, 1600 - São Paulo/SP', 18800.00, '77777-0', 'thiago@gyne'),
('Dra. Larissa Mendes', 'larissa.mendes@vollmed.com', '11799999999', '181818', 'GINECOLOGIA', '888.999.000-55', '88.999.000-5', '1983-09-05', 'Av. Paulista, 1700 - São Paulo/SP', 19500.00, '88888-1', 'larissa#123'),
('Dr. Felipe Barros', 'felipe.barros@vollmed.com', '11788888888', '191919', 'GINECOLOGIA', '999.000.111-66', '99.000.111-6', '1981-01-28', 'Rua Oscar Freire, 1800 - São Paulo/SP', 17900.00, '99999-2', 'felipe2024'),
('Dra. Gabriela Lima', 'gabriela.lima@vollmed.com', '11777777776', '202020', 'GINECOLOGIA', '000.111.222-77', '00.111.222-7', '1986-06-15', 'Av. Europa, 1900 - São Paulo/SP', 18300.00, '00000-3', 'gabriela@sec'),
('Dr. Ricardo Nunes', 'ricardo.nunes@vollmed.com', '11766666666', '212121', 'GINECOLOGIA', '111.222.333-88', '11.222.333-8', '1979-11-02', 'Rua Haddock Lobo, 2000 - São Paulo/SP', 19800.00, '11111-4', 'ricardo!2024');
