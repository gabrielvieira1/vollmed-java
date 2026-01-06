DROP PROCEDURE IF EXISTS search_patient_secure;

DROP PROCEDURE IF EXISTS search_patient_vulnerable;

DELIMITER //
CREATE PROCEDURE search_patient(IN patient_name VARCHAR(255))
BEGIN
    DECLARE sql_query TEXT;

    SET sql_query = CONCAT('SELECT id, nome, email, telefone, cpf, data_nascimento, plano_saude FROM pacientes WHERE nome LIKE "%', patient_name, '%" AND ativo = true ORDER BY nome');

    INSERT INTO logs_audit (query_executada, timestamp) VALUES (sql_query, NOW())
    ON DUPLICATE KEY UPDATE query_executada = query_executada;

    SET @sql = sql_query;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;
