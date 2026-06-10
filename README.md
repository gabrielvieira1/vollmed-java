# Vollmed Java Web Application - Sistema Completo com Shift-Left Security

Este projeto é uma aplicação web completa desenvolvida em Java com Spring Boot, que simula um sistema de gerenciamento médico com agendamento de consultas. O sistema oferece uma **interface moderna e responsiva** para gerenciar médicos, consultas e usuários, implementando uma **arquitetura de segurança robusta** com **vulnerabilidades educacionais intencionais** para demonstrar práticas de **Shift-Left Security**.

## ✨ Funcionalidades Principais

### 🔐 **Sistema de Autenticação Completo**
- **Login seguro** com validação de credenciais
- **Registro de novos usuários** com criptografia BCrypt
- **Logout com confirmação** para maior segurança
- **Autenticação baseada em banco de dados** com Spring Security

### 👨‍⚕️ **Gerenciamento de Médicos**
- Cadastro completo de médicos com validações
- Listagem paginada com busca e filtros
- Edição e exclusão de registros
- Gerenciamento de especialidades médicas

### 📅 **Sistema de Consultas**
- Agendamento de consultas por especialidade
- Seleção automática de médicos disponíveis
- Controle de data/hora com validações
- Gestão completa do histórico de consultas

### 🎨 **Interface Moderna e Responsiva**
- **Design glassmorphism** com gradientes azuis
- **Efeitos visuais modernos** (hover effects, sombras, transições)
- **Totalmente responsivo** (mobile-first design)
- **Experiência de usuário otimizada** com validações em tempo real

## 🛡️ **Arquitetura de Segurança e DevSecOps**

### 🚀 **Shift-Left Security Strategy**

Este projeto implementa uma **estratégia completa de Shift-Left Security**, movendo a segurança para o início do ciclo de desenvolvimento:

#### **Pipeline de Segurança Automatizado**
```mermaid
graph LR
    A[Desenvolvedor] --> B[Git Commit]
    B --> C[Pre-commit Hooks]
    C --> D[Análise de Vulnerabilidades]
    D --> E{Vulnerabilidades?}
    E -->|Sim| F[❌ Commit Rejeitado]
    E -->|Não| G[✅ Commit Aprovado]
    F --> H[Correção Obrigatória]
    H --> B
```

#### **Ferramentas de Segurança Integradas**
- 🔍 **OWASP Dependency-Check** - Análise de dependências com vulnerabilidades conhecidas
- 🔐 **GitLeaks** - Detecção de credenciais expostas e secrets hardcoded
- 📊 **Snyk** - Análise de vulnerabilidades em dependências JavaScript/Java
- 🛡️ **Semgrep** - Análise estática de código para padrões inseguros
- 🤖 **IA Gemini** - Análise inteligente e relatórios automatizados

### **Pipeline de Segurança Pre-Commit Detalhado**

#### **Configuração do Pre-Commit (.pre-commit-config.yaml)**

O sistema utiliza **pre-commit hooks** para executar análises de segurança automaticamente antes de cada commit:

```yaml
repos:
  # Hooks básicos de qualidade de código
  - repo: https://github.com/pre-commit/pre-commit-hooks
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  # Análise de dependências OWASP (instalação local)
  - repo: local
    hooks:
      - id: owasp-dependency-check
        name: OWASP Dependency-Check (Local)
        entry: ~/dependency-check/bin/dependency-check.sh
```

### **Como Funciona o Pipeline de Segurança**

#### **1. Execução Automática**
- ✅ **Trigger**: A cada `git commit`
- ⏱️ **Tempo médio**: ~10 segundos
- 🔍 **Escopo**: Análise completa do projeto

#### **2. Critérios de Aprovação/Rejeição**
```bash
✅ COMMIT APROVADO quando:
   - Nenhuma vulnerabilidade CRITICAL detectada
   - Nenhuma vulnerabilidade HIGH detectada
   - Nenhum secret/credencial exposto
   - Código passa em validações básicas

❌ COMMIT REJEITADO quando:
   - Vulnerabilidades CRITICAL ou HIGH encontradas
   - Secrets/API keys detectados
   - Arquivos grandes (>500KB) adicionados
   - Sintaxe YAML inválida
```

## 🛠 Tecnologias Utilizadas

### Backend
- **Java 17**
- **Spring Boot 3.x** - Framework principal
- **Spring Security** - Autenticação e autorização
- **Spring Data JPA** - Persistência de dados
- **BCrypt** - Criptografia de senhas
- **Bean Validation** - Validações de formulários
- **MySQL** - Banco de dados relacional
- **Flyway** - Controle de versão do banco
- **Maven** - Gerenciamento de dependências

### Frontend
- **Thymeleaf** - Motor de templates
- **HTML5 Semântico**
- **CSS3 Moderno** (Flexbox, Grid, Gradientes, Animações)
- **JavaScript** - Interações dinâmicas
- **Design Responsivo** - Mobile + Desktop

### Segurança
- **Senhas criptografadas** com BCrypt
- **Proteção CSRF** habilitada
- **Validações server-side** completas
- **Controle de acesso** por rotas

## 🚀 Como Rodar o Projeto

### 1. Pré-requisitos
- Java 17 ou superior
- Maven 3.6+
- MySQL 8.0+ ou MariaDB
- IDE de sua preferência (IntelliJ IDEA recomendado)

### 2. Configuração do Banco de Dados
Crie um banco MySQL. A configuração principal fica em
`src/main/resources/application.properties` e utiliza variáveis de ambiente
com valores padrão para execução local:

```properties
spring.application.name=web-application

server.port=${SERVER_PORT:8080}

spring.datasource.url=${DB_URL:jdbc:mysql://localhost/vollmed_web?createDatabaseIfNotExist=true}
spring.datasource.username=${DB_USERNAME:root}
spring.datasource.password=${DB_PASSWORD:root}

spring.mvc.hiddenmethod.filter.enabled=true

spring.flyway.validate-on-migrate=true

management.endpoints.web.exposure.include=health
management.endpoint.health.show-details=never
```

O arquivo `src/main/resources/application-dev.properties` concentra apenas as
configurações específicas de desenvolvimento:

```properties
app.dev.seed-users=${TEST_USERS_ENABLED:true}
app.dev.test-user-password=${TEST_USER_PASSWORD:Vollmed@2026}
```

Crie esse arquivo quando quiser habilitar o inicializador de usuários de teste.
Ele só é carregado quando o perfil Spring `dev` está ativo. No Docker Compose,
isso é configurado por `SPRING_PROFILES_ACTIVE=dev`. Fora do Docker, execute:

```bash
SPRING_PROFILES_ACTIVE=dev ./mvnw spring-boot:run
```

As variáveis `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `SERVER_PORT`,
`TEST_USERS_ENABLED` e `TEST_USER_PASSWORD` podem sobrescrever os valores
padrão sem alterar os arquivos versionados.

### 3. Executando a Aplicação

```bash
# Clone o repositório
git clone <seu-repositorio>
cd vollmed-java

# Execute a aplicação
./mvnw spring-boot:run

# Ou no Windows
mvnw.cmd spring-boot:run
```

### 4. Acesso ao Sistema
- **URL**: http://localhost:8080
- **Página inicial**: Interface moderna com botões de Login/Registro
- **Primeiro acesso**: Crie uma conta através do botão "Criar Conta"

## 🐳 Executando com Docker

O Docker Compose inicia a aplicação e um MySQL 8 isolado do banco instalado no
computador. Os dados do banco ficam armazenados em um volume Docker persistente.

### Pré-requisitos

- Docker
- Docker Compose

### Iniciar o ambiente

```bash
docker compose up --build
```

Se o Docker estiver instalado sem o plugin `buildx`, use o builder legado:

```bash
COMPOSE_BAKE=false DOCKER_BUILDKIT=0 docker compose up --build
```

Depois que os health checks estiverem concluídos:

- **Aplicação**: http://localhost:8080
- **Health check**: http://localhost:8080/actuator/health
- **MySQL no host**: `localhost:3307`
- **Banco**: `vollmed_web`
- **Usuário padrão**: `vollmed`
- **Senha padrão**: `vollmed_local`

As credenciais locais podem ser alteradas no `.env` usando as variáveis
`DB_USERNAME`, `DB_PASSWORD` e `MYSQL_ROOT_PASSWORD`. Somente as variáveis
declaradas no `compose.yaml` são enviadas para os containers; tokens de
ferramentas de segurança não são repassados para a aplicação.

### Usuários de desenvolvimento

O perfil Spring `dev` cria as contas abaixo na primeira inicialização. A criação
é idempotente: se o e-mail já existir, o usuário não será alterado.

| Perfil | E-mail | Senha padrão |
| --- | --- | --- |
| Administrador | `admin@vollmed.local` | `Vollmed@2026` |
| Médico | `medico@vollmed.local` | `Vollmed@2026` |
| Paciente | `ana.silva@email.com` | `Vollmed@2026` |

A conta da Ana é vinculada à paciente de teste criada pelas migrations. Os
demais médicos continuam sendo massa de dados para CRUD, buscas e consultas,
sem receber uma conta de acesso individual.

A senha pode ser alterada com `TEST_USER_PASSWORD`. Para não criar essas contas,
defina `TEST_USERS_ENABLED=false`. O inicializador não é executado fora do
perfil `dev`.

### Operação do ambiente

```bash
# Acompanhar os logs
docker compose logs -f app

# Parar e remover os containers, preservando o banco
docker compose down

# Recriar os containers usando os dados persistidos
docker compose up -d

# Remover também o volume e recriar o banco do zero
docker compose down -v
```

Para conectar ao MySQL por uma IDE ou cliente externo, use
`jdbc:mysql://localhost:3307/vollmed_web`. Dentro da rede Docker, a aplicação
usa `jdbc:mysql://mysql:3306/vollmed_web`.

## 📱 Estrutura da Aplicação

### Páginas Principais
- **/** - Página inicial com hero section moderna
- **/login** - Tela de login com design glassmorphism
- **/registro** - Formulário de criação de conta
- **/logout** - Confirmação de logout
- **/medicos** - Listagem e gestão de médicos
- **/consultas** - Sistema de agendamento

### Arquitetura do Código
```
src/main/java/med/voll/web_application/
├── controller/          # Controllers REST e Web
├── domain/             # Entidades e regras de negócio
│   ├── medico/        # Domínio de médicos
│   ├── consulta/      # Domínio de consultas
│   └── usuario/       # Sistema de usuários
└── infra/             # Configurações e infraestrutura
    └── security/      # Configurações Spring Security
```

```
src/main/resources/
├── templates/         # Templates Thymeleaf
│   ├── autenticacao/ # Páginas de login/registro
│   ├── medico/       # CRUD de médicos
│   └── consulta/     # Sistema de consultas
├── static/           # Arquivos estáticos (CSS/JS/Images)
└── db/migration/     # Scripts Flyway
```

## 🎨 Design System

### Paleta de Cores
- **Azul Primário**: #339CFF (botões e links principais)
- **Azul Escuro**: #0B3B60 (headers e elementos importantes)
- **Azul Claro**: #64B4FF (backgrounds e gradientes)
- **Verde**: #28a745 (ações de sucesso)
- **Vermelho**: #ff4757 (ações de exclusão/erro)

### Componentes Modernos
- **Cards glassmorphism** com blur effects
- **Botões com gradientes** e hover animations
- **Formulários com focus effects**
- **Tabelas estilizadas** com hover states
- **Estados vazios** com emojis e call-to-actions

## 🔒 Segurança Implementada

- **Autenticação obrigatória** para áreas protegidas
- **Criptografia BCrypt** para todas as senhas
- **Validação de entrada** em todos os formulários
- **Proteção contra CSRF**
- **Logout seguro** com limpeza de sessão
- **Verificação de emails únicos** no registro

## 📊 Funcionalidades Avançadas

### Sistema de Usuários
- Registro com validação de senhas
- Login seguro com remember-me
- Exibição do nome do usuário logado
- Logout com página de confirmação

### Interface Responsiva
- **Mobile-first design**
- **Breakpoints otimizados** para todos os dispositivos
- **Menu adaptável** com hamburger em mobile
- **Formulários responsivos** com campos adaptativos

### Validações Inteligentes
- **Validação em tempo real** nos formulários
- **Mensagens de erro personalizadas**
- **Feedback visual** para ações do usuário
- **Estados de loading** e confirmação

## 🛡 Próximas Melhorias

- [ ] Sistema de perfis de usuário (Admin/Médico/Recepcionista)
- [ ] Dashboard com estatísticas de segurança
- [ ] Sistema de notificações de vulnerabilidades
- [ ] API REST para integração mobile
- [ ] Relatórios em PDF automáticos
- [ ] Sistema de backup automático
- [ ] **Integração com GitHub Actions** para CI/CD
- [ ] **Alertas Slack/Teams** para vulnerabilidades críticas
- [ ] **Dashboard Grafana** para métricas de segurança

## 📝 Changelog Recente

### v3.0.0 - DevSecOps e Shift-Left Security (Atual)
- ✅ **Pipeline completo de segurança** com pre-commit hooks
- ✅ **OWASP Dependency-Check** integrado localmente (12.1.0)
- ✅ **GitLeaks** para detecção de secrets
- ✅ **Base NVD offline** (307.439 vulnerabilidades)
- ✅ **Análise automatizada com IA** (Google Gemini)
- ✅ **Scripts de relatório** executivos e técnicos
- ✅ **Cache inteligente** para performance otimizada
- ✅ **Rejeição automática** de commits inseguros

### v2.0.0 - Sistema de Autenticação e Design Moderno
- ✅ Implementado sistema completo de registro de usuários
- ✅ Redesenhadas todas as páginas com design glassmorphism
- ✅ Criado menu superior responsivo com gradientes
- ✅ Modernizadas listagens e formulários
- ✅ Implementada autenticação baseada em banco de dados
- ✅ Adicionados efeitos visuais e animações CSS3
- ✅ Tornada aplicação completamente responsiva

## 👨‍💻 Contribuição

Este é um projeto de estudo focado em demonstrar:
- **Desenvolvimento Full-Stack** com Spring Boot
- **Autenticação moderna** com Spring Security
- **Design responsivo** com CSS3 avançado
- **Boas práticas** de desenvolvimento web

---

**Projeto desenvolvido para fins educacionais** 📚

*Demonstrando integração completa entre backend robusto e frontend moderno*
