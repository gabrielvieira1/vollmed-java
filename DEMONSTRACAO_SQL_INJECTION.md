# 🚨 Demonstração de SQL Injection - VollMed

## 📍 Localização da Vulnerabilidade

### 1. **Procedure Vulnerável**
📁 **Arquivo:** `src/main/resources/db/migration/V8__insert-dados-pacientes-e-procedures.sql`
📍 **Linhas:** 15-30

```sql
DELIMITER //
CREATE PROCEDURE search_patient_vulnerable(IN patient_name VARCHAR(255))
BEGIN
    DECLARE sql_query TEXT;
    
    -- ❌ VULNERABILIDADE: Concatenação direta sem sanitização
    SET sql_query = CONCAT('SELECT id, nome, email, telefone, cpf, data_nascimento, plano_saude FROM pacientes WHERE nome LIKE "%', patient_name, '%" AND ativo = true ORDER BY nome');
    
    -- Log da query para demonstração
    INSERT INTO logs_audit (query_executada, timestamp) VALUES (sql_query, NOW()) 
    ON DUPLICATE KEY UPDATE query_executada = query_executada;
    
    SET @sql = sql_query;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;
```

### 2. **Método Java Vulnerável**
📁 **Arquivo:** `src/main/java/med/voll/web_application/domain/paciente/PacienteRepository.java`
📍 **Linhas:** 33-35

```java
@Query(value = "CALL search_patient_vulnerable(:nome)", nativeQuery = true)
List<Object[]> buscarPacientePorNomeVulneravel(@Param("nome") String nome);
```

### 3. **Controller com Endpoint Vulnerável**
📁 **Arquivo:** `src/main/java/med/voll/web_application/controller/PacienteController.java`
📍 **Endpoint:** `/pacientes/buscar-vulneravel`

```java
@GetMapping("buscar-vulneravel")
@ResponseBody
public List<DadosListagemPaciente> buscarPacientesVulneravel(@RequestParam String nome) {
    // ⚠️ AVISO EDUCACIONAL
    System.out.println("🚨 DEMONSTRAÇÃO DE VULNERABILIDADE:");
    System.out.println("🔍 Parâmetro recebido: " + nome);
    System.out.println("📞 Chamando procedure vulnerável: search_patient_vulnerable");
    
    return service.buscarPacientePorNomeVulneravel(nome);
}
```

## 🧪 Exemplos de Demonstração

### ✅ **Busca Normal (Esperado)**
```
Campo de busca: Ana
Resultado: Retorna pacientes com nome contendo "Ana"
```

### 💀 **Payloads Maliciosos**

#### 1. **SQL Injection Básico**
```
Campo de busca: "; DROP TABLE logs_audit; SELECT * FROM pacientes WHERE "1"="1
```
**O que acontece:**
- A procedure executa: `SELECT ... WHERE nome LIKE "%"; DROP TABLE logs_audit; SELECT * FROM pacientes WHERE "1"="1%" AND ativo = true`
- Pode dropar a tabela `logs_audit`
- Retorna todos os pacientes

#### 2. **Union-Based SQL Injection**
```
Campo de busca: " UNION SELECT 1,2,3,4,5,6,7 FROM information_schema.tables WHERE "1"="1
```
**O que acontece:**
- Expõe estrutura do banco de dados
- Pode revelar outras tabelas

#### 3. **Time-Based SQL Injection**
```
Campo de busca: "; SELECT SLEEP(5); SELECT * FROM pacientes WHERE "1"="1
```
**O que acontece:**
- Adiciona delay de 5 segundos na resposta
- Confirma que há execução de SQL arbitrário

#### 4. **Information Disclosure**
```
Campo de busca: " UNION SELECT TABLE_NAME, TABLE_SCHEMA, NULL, NULL, NULL, NULL, NULL FROM information_schema.tables WHERE "1"="1
```
**O que acontece:**
- Expõe nomes de tabelas e schemas do banco

## 🔍 Como Demonstrar

### 1. **Acesse a Página**
- URL: `http://localhost:8080/pacientes`
- Interface limpa com campo de busca profissional

### 2. **Demonstração Passo a Passo**

#### **Passo 1: Busca Normal**
1. Digite: `Ana`
2. Clique em "Buscar"
3. **Resultado:** Lista pacientes normalmente

#### **Passo 2: Busca Maliciosa**
1. Digite: `"; DROP TABLE logs_audit; SELECT * FROM pacientes WHERE "1"="1`
2. Clique em "Buscar"
3. **Resultado:** 
   - Pode retornar erro (se a tabela for dropada)
   - Pode retornar todos os pacientes (bypass do filtro)

#### **Passo 3: Verificar Logs**
- Console da aplicação mostrará as queries executadas
- Tabela `logs_audit` (se não foi dropada) conterá as queries maliciosas

## 🛡️ Comparação com Versão Segura

### **Procedure Segura** (também implementada)
```sql
CREATE PROCEDURE search_patient_secure(IN patient_name VARCHAR(255))
BEGIN
    SELECT id, nome, email, telefone, cpf, data_nascimento, plano_saude 
    FROM pacientes 
    WHERE nome LIKE CONCAT('%', patient_name, '%') 
    AND ativo = true 
    ORDER BY nome;
END
```

### **Endpoint Seguro**
```java
@GetMapping("buscar-seguro")
@ResponseBody  
public List<DadosListagemPaciente> buscarPacientesSeguro(@RequestParam String nome) {
    return service.buscarPacientePorNomeSeguro(nome);
}
```

## 🎯 Pontos Importantes para a Demonstração

1. **Contexto Educacional:** Sempre enfatizar que é para fins educacionais
2. **Impacto Real:** Mostrar como a vulnerabilidade permite executar SQL arbitrário
3. **Logging:** As queries são logadas para análise posterior
4. **Comparação:** Mostrar diferença entre versão vulnerável e segura
5. **Mitigação:** Explicar como usar prepared statements e validação

## ⚠️ Avisos de Segurança

- ✅ **Ambiente Educacional:** Use apenas em ambiente de desenvolvimento
- ❌ **Não usar em Produção:** Nunca implemente código similar em produção
- 🔒 **Boas Práticas:** Sempre use prepared statements e validação de entrada
- 📚 **Objetivo:** Demonstrar riscos e ensinar práticas seguras

## 📊 Monitoramento

- **Console Logs:** Mostra queries executadas
- **Tabela logs_audit:** Armazena queries para análise (pode ser dropada pelos payloads)
- **Erro Handling:** Aplicação pode gerar erros reveladores

---
**🚨 Lembre-se:** Esta implementação contém vulnerabilidades intencionais para fins educacionais. Nunca use código similar em aplicações de produção!
