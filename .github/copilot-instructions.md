# VollMed Java Web Application - AI Coding Guide

## Visão Geral do Projeto

Sistema web para agendamento de consultas médicas desenvolvido em Spring Boot com Thymeleaf. Este é um **projeto didático** com **vulnerabilidades de segurança intencionais** para fins educacionais, utilizando autenticação Spring Security e design responsivo moderno.

## Arquitetura e Tecnologias

- **Backend**: Spring Boot 3.x, Spring Security, Spring Data JPA
- **Frontend**: Thymeleaf, HTML5, CSS3 (modularizado), JavaScript
- **Banco de Dados**: MySQL com Flyway para migrações
- **Segurança**: BCrypt para senhas, Spring Security para autenticação/autorização
- **Build**: Maven

## Estrutura de Pastas

```
src/main/
├── java/med/voll/web_application/
│   ├── controller/          # Controllers MVC (Web + REST)
│   ├── domain/             # Entidades e regras de negócio
│   │   ├── medico/        # Domínio de médicos (Entity, Service, Repository, DTOs)
│   │   ├── consulta/      # Domínio de consultas
│   │   └── usuario/       # Sistema de usuários/autenticação
│   ├── infra/              # Configurações de infraestrutura
│   │   └── security/      # Configurações Spring Security
│   ├── service/           # Serviços de integração externa
│   └── WebApplication.java # Classe principal
├── resources/
│   ├── templates/          # Templates Thymeleaf
│   │   ├── autenticacao/   # Login, logout, registro
│   │   ├── componentes/    # Componentes reutilizáveis
│   │   ├── consulta/       # CRUD de consultas
│   │   ├── medico/         # CRUD de médicos
│   │   ├── relatorio/      # Sistema de relatórios (vulnerável)
│   │   └── erro/           # Páginas de erro
│   ├── static/
│   │   ├── css/            # Estilos modularizados
│   │   ├── js/             # JavaScript
│   │   └── assets/         # Imagens e recursos
│   ├── certificates/       # Certificados .pfx (VULNERÁVEL!)
│   └── db/migration/       # Scripts Flyway
```

## Padrões de Desenvolvimento

### 1. Domain Layer Pattern

Each domain follows consistent structure:

- `Entity.java` - JPA entity with business methods (e.g., `Medico.atualizarDados()`)
- `Service.java` - Business logic with `@Transactional` methods
- `Repository.java` - JpaRepository interface with custom queries
- `DadosCadastro*.java` - Input DTOs with Bean Validation
- `DadosListagem*.java` - Output DTOs with constructor from entity

### 2. Controller Patterns

Controllers use consistent naming and flow:

```java
@Controller
@RequestMapping("domain")
public class DomainController {
    private static final String PAGINA_LISTAGEM = "domain/list-page";
    private static final String PAGINA_CADASTRO = "domain/form-page";
    private static final String REDIRECT_LISTAGEM = "redirect:/domain?sucesso";

    @GetMapping
    public String carregaPagina(@PageableDefault Pageable paginacao, Model model) {
        var dados = service.listar(paginacao);
        model.addAttribute("dados", dados);
        return PAGINA_LISTAGEM;
    }

    @GetMapping("formulario")
    public String carregarPaginaCadastro(Long id, Model model) {
        if (id != null) {
            model.addAttribute("dados", service.carregarPorId(id));
        } else {
            model.addAttribute("dados", new DadosCadastroDto());
        }
        return PAGINA_CADASTRO;
    }

    @PostMapping
    public String processarFormulario(@Valid @ModelAttribute("dados") DadosCadastroDto dados,
                                    BindingResult result,
                                    Model model,
                                    RedirectAttributes redirect) {
        if (result.hasErrors()) {
            model.addAttribute("dados", dados);
            return PAGINA_CADASTRO;
        }

        try {
            service.cadastrar(dados);
            redirect.addFlashAttribute("mensagemSucesso", "Operação realizada!");
            return REDIRECT_LISTAGEM;
        } catch (RegraDeNegocioException e) {
            model.addAttribute("erro", e.getMessage());
            model.addAttribute("dados", dados);
            return PAGINA_CADASTRO;
        }
    }

    @DeleteMapping
    public String excluir(Long id) {
        service.excluir(id);
        return REDIRECT_LISTAGEM;
    }
}
```

### 3. Error Handling Pattern

- Use `RegraDeNegocioException` for business rule violations
- Controllers catch exceptions and add to model: `model.addAttribute("erro", e.getMessage())`
- Templates display errors using Thymeleaf: `th:if="${erro}"`
- Use `RedirectAttributes` for flash messages: `redirect.addFlashAttribute("mensagemSucesso", "...")`

### 4. Security Patterns

- Use `SecurityContextLogoutHandler` for logout
- Authentication based on email (use `getEmail()` instead of `getUsername()`)
- Use `getNome()` method for user display name
- Session-based authentication
- BCrypt password encoding

## Database & Migrations

### Flyway Migrations

- Located in `src/main/resources/db/migration/`
- Naming: `V{version}__{description}.sql`
- Current schema: `medicos`, `consultas`, `usuarios` tables

### Repository Queries

- Use custom `@Query` with JPQL for complex queries
- Example: `MedicoRepository.isJaCadastrado()` prevents duplicates
- **WARNING**: `MedicoService.buscarPorNomeVulneravel()` contains intentional SQL injection

## Security Implementation

### Spring Security Configuration

- `ConfiguracoesSeguranca.java` - Main security config
- BCrypt password encoding
- Form-based authentication with custom login page
- CSRF protection enabled
- **CONTAINS HARDCODED CREDENTIALS** for educational purposes

### Authentication Flow

- `Usuario` entity implements `UserDetails`
- `UsuarioService` implements `UserDetailsService`
- Email-based login (not username)

## Frontend Architecture

### Thymeleaf Templates

- Base template: `templates/template.html`
- Page structure: `templates/{domain}/{action}.html`
- Namespace security: `xmlns:sec="http://www.thymeleaf.org/extras/spring-security"`
- Authentication conditionals: `sec:authorize="isAuthenticated()"`
- Exemplo de estrutura:

```html
<html
  xmlns:th="http://thymeleaf.org"
  xmlns:sec="http://www.thymeleaf.org/extras/spring-security"
  layout:decorate="~{template.html}"
>
  <div layout:fragment="conteudo">
    <!-- Conteúdo da página -->
  </div>
</html>
```

### CSS Organization (Modularizado)

Estilos organizados em módulos específicos:

- `base.css` - Estilos globais, reset, layout, footer
- `header.css` - Menu de navegação e área do usuário
- `hero.css` - Seção hero da página inicial
- `auth.css` - Páginas de autenticação (login, logout, registro)
- `pages.css` - Páginas internas (listagens e formulários)
- `components.css` - Componentes reutilizáveis
- `responsive.css` - Design responsivo

## Padrões de UI/UX

### 1. Paleta de Cores

- Azul principal: #007bff (gradientes permitidos)
- Azul escuro: #0056b3
- Branco: #ffffff
- Cinza claro: #f8f9fa
- Texto escuro: #333333
- Verde sucesso: #28a745
- Vermelho erro: #dc3545

### 2. Componentes de Interface

- **Botões**: Bordas arredondadas (8px), gradientes sutis, hover effects
- **Cards**: Sombras suaves, bordas arredondadas
- **Formulários**: Labels claros, validação visual, mensagens de erro/sucesso
- **Menu**: Horizontal superior, sem dropdowns, botões distribuídos
- **Hero**: Altura 100vh, background azul, conteúdo centralizado

### 3. Responsividade

- Mobile-first approach
- Breakpoints: 768px (tablet), 1024px (desktop)
- Imagens responsivas
- Menu colapsável em mobile

### 4. Navegação

- Menu superior sem dropdowns complexos
- Botões de ação destacados
- Links de navegação intuitivos
- Área do usuário visível quando logado

## Intentional Vulnerabilities (Educational)

This project contains **deliberate security flaws** for learning:

### 1. Hardcoded Credentials

- Files: `ConfiguracoesSeguranca.java`, `IntegracaoExternaService.java`
- Contains API keys, certificates, database credentials in code

### 2. Weak Cryptography

- `RelatorioMedicoService.java` - Uses DES encryption with hardcoded keys
- Certificate `.pfx` files stored in project resources

### 3. SQL Injection

- `MedicoService.buscarPorNomeVulneravel()` - Concatenated SQL queries

### 4. Information Disclosure

- Detailed error messages and stack traces
- Credentials logged to console

## Security Testing Setup

### Pre-commit Hooks

- `.pre-commit-config.yaml` - Configured with security scanners
- **Snyk** - Dependency vulnerability scanning
- **GitLeaks** - Hardcoded secrets detection
- **Semgrep** - Static code analysis

### Security Scripts

- `scripts/security-summary.sh` - Executive security summary
- `scripts/show-security-results.sh` - Detailed scan results
- Run: `git commit` triggers automatic security scans

## Development Workflow

### Running the Application

```bash
./mvnw spring-boot:run
# Access: http://localhost:8080
```

### Padrões de Commit

- **feat**: Nova funcionalidade
- **fix**: Correção de bug
- **docs**: Documentação
- **style**: Formatação, estilos CSS
- **refactor**: Refatoração de código
- **test**: Testes
- **sec**: Alterações de segurança (vulnerabilidades educacionais)

### Validação de Código

1. **Bean Validation**: Usar anotações nas DTOs
2. **Service Layer**: Validações de negócio com `@Transactional`
3. **Controller Layer**: Tratamento de erros com `BindingResult`
4. **Templates**: Exibição de mensagens de erro/sucesso

### Testes de Segurança

- Navigate to `/relatorios` for vulnerability demonstrations
- Use pre-commit hooks: `git add . && git commit -m "test"`
- View scan results: `./scripts/security-summary.sh`

### Database Setup

- MySQL required (see `application.properties`)
- Flyway handles schema migrations automatically
- Default admin credentials in security config

### Integração com Dependências Externas

- **Maven**: Gerenciamento de dependências
- **Spring Boot**: Auto-configuração
- **Flyway**: Migrações de banco automáticas
- **Thymeleaf**: Renderização server-side
- **Spring Security**: Autenticação e autorização

## Key Files for AI Agents

### Arquivos Essenciais para Agentes de IA

- `ConfiguracoesSeguranca.java` - Configuração de segurança com vulnerabilidades intencionais
- `*Service.java` - Camada de lógica de negócio com gerenciamento transacional
- `*Controller.java` - Padrão MVC com validação e tratamento de erros
- `RelatorioMedicoService.java` - Demonstra criptografia fraca educacional
- `IntegracaoExternaService.java` - Certificados .pfx e integração externa vulnerável
- `application.properties` - Configuração de banco de dados e segurança
- `.pre-commit-config.yaml` - Configuração de scanners de segurança
- `templates/template.html` - Template base com layout responsivo
- `static/css/` - Estilos modularizados (base, components, pages, auth, responsive)
- `db/migration/` - Scripts Flyway para evolução do schema

### Regras de Desenvolvimento

1. **Sempre** use DTOs para transferência de dados entre camadas
2. **Sempre** aplique `@Transactional` em métodos de serviço que modificam dados
3. **Sempre** trate erros nos controllers com `BindingResult` e `model.addAttribute("erro")`
4. **Sempre** use `RedirectAttributes` para flash messages após operações POST
5. **Sempre** valide entrada com Bean Validation (`@Valid`, `@NotBlank`, etc.)
6. **Sempre** use queries customizadas em repositories quando necessário
7. **Sempre** implemente métodos de negócio nas entidades quando apropriado
8. **Sempre** siga o padrão de nomenclatura de constantes para páginas e redirecionamentos
9. **Sempre** use autenticação baseada em email (não username)
10. **Nunca** corrija as vulnerabilidades intencionais sem solicitação explícita

### Debugging e Logs

- Use `System.out.println()` para logs simples de desenvolvimento
- Vulnerabilidades intencionais podem gerar stack traces detalhados
- Console mostra credenciais hardcoded para fins educacionais
- Logs de segurança salvos em `logs/` pelos scanners pre-commit

When working on this codebase, remember it's designed for **security education** - vulnerabilities are intentional and should not be "fixed" unless specifically requested.
