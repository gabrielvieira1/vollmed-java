INSERT INTO relatorios (
    consulta_id,
    medico_id,
    diagnostico,
    procedimento,
    historico_familiar,
    medicacao,
    observacoes_medicas,
    data_geracao,
    numero_sus,
    cpf_paciente
) VALUES
(
    1,
    1,
    'Hipertensão arterial sistêmica - CID I10',
    'Consulta de rotina e ajuste de medicação anti-hipertensiva',
    'Pai: infarto do miocárdio aos 55 anos. Mãe: diabetes tipo 2. Avó paterna: AVC.',
    'Losartana 50mg - 1x ao dia pela manhã. Hidroclorotiazida 25mg - 1x ao dia.',
    'Paciente apresenta aderência boa ao tratamento. PA controlada. Orientações sobre dieta hipossódica reforçadas.',
    NOW(),
    '123456789012345',
    '12345678901'
),
(
    2,
    2,
    'Diabetes mellitus tipo 2 não controlado - CID E11.9',
    'Consulta de seguimento endocrinológico com ajuste de insulinoterapia',
    'Mãe: diabetes tipo 2. Irmão: diabetes tipo 1. Tia materna: retinopatia diabética.',
    'Metformina 850mg - 2x ao dia. Insulina NPH 20UI antes do café. Insulina Regular 8UI antes do almoço.',
    'HbA1c: 8.2%. Glicemia de jejum: 180mg/dl. Necessário intensificação do tratamento. Orientações dietéticas.',
    NOW(),
    '987654321098765',
    '98765432100'
),
(
    1,
    1,
    'Transtorno de ansiedade generalizada - CID F41.1',
    'Primeira consulta psiquiátrica - avaliação e prescrição inicial',
    'Pai: depressão maior. Mãe: transtorno bipolar. Histórico familiar significativo para transtornos mentais.',
    'Escitalopram 10mg - 1x ao dia pela manhã. Clonazepam 0,5mg - conforme necessário para crises.',
    'Paciente relata sintomas há 6 meses. Insônia, palpitações, preocupação excessiva. Indicada psicoterapia.',
    NOW(),
    '456789123456789',
    '45678912301'
),
(
    2,
    2,
    'Asma brônquica moderada persistente - CID J45.9',
    'Consulta pneumológica - ajuste de terapia inalatória',
    'Mãe: asma alérgica. Pai: rinite alérgica. Avô paterno: enfisema pulmonar.',
    'Budesonida/Formoterol 200/6mcg - 2 inalações 2x ao dia. Salbutamol spray - SOS para crises.',
    'Paciente com controle inadequado. Relatou 3 crises no último mês. Revisão da técnica inalatória realizada.',
    NOW(),
    '789123456789123',
    '78912345601'
);
