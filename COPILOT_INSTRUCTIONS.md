# Instruções do Projeto Vollmed para GitHub Copilot

## Visão Geral do Projeto
Sistema web para agendamento de consultas médicas desenvolvido em Spring Boot com Thymeleaf, utilizando autenticação Spring Security e design responsivo moderno.

## Arquitetura e Tecnologias
- **Backend**: Spring Boot 3.x, Spring Security, Spring Data JPA
- **Frontend**: Thymeleaf, HTML5, CSS3 (modularizado), JavaScript
- **Banco de Dados**: Flyway para migrações
- **Segurança**: BCrypt para senhas, Spring Security para autenticação/autorização
- **Build**: Maven

## Estrutura de Pastas
```
src/main/
├── java/med/voll/web_application/
│   ├── controller/          # Controllers MVC
│   ├── domain/             # Entidades e regras de negócio
│   ├── infra/              # Configurações de infraestrutura
│   └── WebApplication.java # Classe principal
├── resources/
│   ├── templates/          # Templates Thymeleaf
│   │   ├── autenticacao/   # Login, logout, registro
│   │   ├── componentes/    # Componentes reutilizáveis
│   │   ├── consulta/       # CRUD de consultas
│   │   ├── medico/         # CRUD de médicos
│   │   └── erro/           # Páginas de erro
│   └── static/
│       ├── css/            # Estilos modularizados
│       ├── js/             # JavaScript
│       └── assets/         # Imagens e recursos
```

## Padrões de Desenvolvimento

### 1. Controllers
- Usar `@Controller` para páginas web
- Métodos GET para exibir páginas, POST para processar formulários
- Validação com `@Valid` e `BindingResult`
- Redirecionamento com `RedirectAttributes` para mensagens flash
- Exemplo padrão:
```java
@GetMapping
public String carregaPagina(Model model) {
    model.addAttribute("dados", new DadosDto());
    return "template/pagina";
}

@PostMapping
public String processarFormulario(@Valid DadosDto dados,
                                BindingResult result,
                                RedirectAttributes redirect) {
    if (result.hasErrors()) {
        return "template/pagina";
    }
    // Processar dados
    redirect.addFlashAttribute("mensagemSucesso", "Operação realizada!");
    return "redirect:/listagem";
}
```

### 2. Segurança
- Usar `SecurityContextLogoutHandler` para logout
- Método `getEmail()` ao invés de `getUsername()`
- Método `getNome()` para exibição do nome do usuário
- Autenticação baseada em sessão
- Senhas com BCrypt

### 3. Templates Thymeleaf
- Layout base em `template.html`
- Fragmentos reutilizáveis em `componentes/`
- Namespace security: `xmlns:sec="http://www.thymeleaf.org/extras/spring-security"`
- Condicionais de autenticação: `sec:authorize="isAuthenticated()"`
- Exemplo de estrutura:
```html
<html xmlns:th="http://thymeleaf.org"
      xmlns:sec="http://www.thymeleaf.org/extras/spring-security"
      layout:decorate="~{template.html}">
<div layout:fragment="conteudo">
    <!-- Conteúdo da página -->
</div>
```

### 4. CSS Modularizado
Estilos organizados em módulos específicos:
- `base.css`: Estilos globais, reset, layout, footer
- `header.css`: Menu de navegação e área do usuário
- `hero.css`: Seção hero da página inicial
- `auth.css`: Páginas de autenticação (login, logout, registro)
- `pages.css`: Páginas internas (listagens e formulários)
- `components.css`: Componentes reutilizáveis
- `responsive.css`: Design responsivo

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

## Funcionalidades Implementadas

### 1. Autenticação
- Login com email e senha
- Logout com SecurityContextLogoutHandler
- Registro de novos usuários
- Páginas estilizadas harmoniosamente

### 2. CRUD Médicos
- Listagem com paginação
- Cadastro com validação
- Edição e exclusão
- Design responsivo

### 3. CRUD Consultas
- Agendamento de consultas
- Listagem com filtros
- Gerenciamento completo
- Interface moderna

### 4. Página Inicial
- Hero section responsiva
- Botões de login/registro para não autenticados
- Menu superior para usuários logados
- Layout sem scroll desnecessário

## Diretrizes de Estilo

### 1. Código Java
- Nomenclatura clara e descritiva
- Métodos pequenos e focados
- Validação adequada
- Tratamento de exceções

### 2. Templates
- HTML semântico
- Atributos Thymeleaf consistentes
- Fragmentos para reutilização
- Acessibilidade básica

### 3. CSS
- Evitar estilos inline
- Usar classes semânticas
- Manter consistência visual
- Otimizar para performance

## Regras de Desenvolvimento

### 1. Novas Features
- Seguir padrão MVC estabelecido
- Criar DTOs para transfer de dados
- Implementar validação adequada
- Manter consistência visual

### 2. Modificações
- Não quebrar funcionalidades existentes
- Manter padrões de nomenclatura
- Testar responsividade
- Validar acessibilidade

### 3. Estilização
- Usar módulos CSS apropriados
- Manter paleta de cores
- Implementar hover effects
- Garantir responsividade

### 4. Segurança
- Validar dados de entrada
- Usar anotações de segurança
- Proteger rotas adequadamente
- Criptografar senhas com BCrypt

## Padrões de Commit
- Usar mensagens descritivas
- Agrupar alterações relacionadas
- Mencionar arquivos modificados importantes
- Seguir padrão: "feat:", "fix:", "style:", "refactor:"

## Testes e Validação
- Testar em diferentes resoluções
- Validar formulários
- Verificar autenticação/autorização
- Confirmar responsividade

## Observações Importantes
- Priorizar UX intuitiva
- Manter design limpo e profissional
- Evitar scroll desnecessário nas páginas
- Garantir harmonia visual em todas as telas
- Usar SecurityContextLogoutHandler para logout
- Preferir getNome() para exibição de usuário
- Manter CSS modularizado por área funcional
