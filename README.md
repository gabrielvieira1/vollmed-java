# Vollmed Java API

Este projeto é uma API REST desenvolvida em Java com Spring Boot, que simula um sistema de agendamento de consultas médicas. Ele gerencia informações de médicos e pacientes, permitindo o agendamento, cancelamento e listagem de consultas.

## Tecnologias Utilizadas

- **Java 17**
- **Spring Boot 3.x**: Framework para construção de aplicações Java.
- **Maven**: Ferramenta de automação de build e gerenciamento de dependências.
- **Spring Data JPA**: Para persistência de dados e interação com o banco de dados.
- **MySQL**: Banco de dados relacional.
- **Flyway**: Para controle de versão e migrações de banco de dados.
- **Lombok**: Para reduzir o boilerplate code.
- **Thymeleaf**: Motor de template para as páginas HTML (se houver alguma parte web renderizada pelo backend).
- **HTML/CSS/JavaScript**: Para o frontend (se houver).

## Como Rodar o Projeto

1.  **Pré-requisitos**:
    *   Java 17 ou superior instalado.
    *   Maven instalado.
    *   MySQL instalado e configurado.

2.  **Configuração do Banco de Dados**:
    *   Crie um banco de dados MySQL chamado `vollmed_api`.
    *   Configure as credenciais do banco de dados no arquivo `src/main/resources/application.properties`. Exemplo:
        ```properties
        spring.datasource.url=jdbc:mysql://localhost/vollmed_api
        spring.datasource.username=root
        spring.datasource.password=sua_senha
        spring.jpa.hibernate.ddl-auto=update
        spring.jpa.show-sql=true
        spring.flyway.enabled=true
        ```

3.  **Executar a Aplicação**:
    *   Navegue até o diretório raiz do projeto (`vollmed-java`).
    *   Execute o comando Maven para construir e rodar a aplicação:
        ```bash
        ./mvnw spring-boot:run
        ```
    *   A aplicação estará disponível em `http://localhost:8080` (ou na porta configurada).

## Desabilitando o Pre-Commit

Este projeto utiliza `pre-commit` hooks para garantir a qualidade do código antes de cada commit. Caso precise desabilitá-los temporariamente, você pode fazer isso de duas maneiras:

1.  **Para um único commit**:
    Adicione a flag `--no-verify` ao seu comando `git commit`:
    ```bash
    git commit -m "Sua mensagem de commit" --no-verify
    ```

2.  **Desabilitar permanentemente (não recomendado)**:
    Você pode remover os hooks do seu repositório local executando:
    ```bash
    rm -rf .git/hooks
    ```
    Ou, para desinstalar o `pre-commit` do seu ambiente:
    ```bash
    pre-commit uninstall
    ```
    Para reinstalar, execute `pre-commit install`.

## Endpoints da API (Exemplos)

-   **Médicos**:
    -   `POST /medicos`: Cadastrar novo médico.
    -   `GET /medicos`: Listar médicos.
    -   `PUT /medicos`: Atualizar informações de médico.
    -   `DELETE /medicos/{id}`: Excluir médico.

-   **Consultas**:
    -   `POST /consultas`: Agendar nova consulta.
    -   `GET /consultas`: Listar consultas.
    -   `DELETE /consultas/{id}`: Cancelar consulta.
