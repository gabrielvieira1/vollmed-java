# Sistema de Perfis e Gestão de Usuários

## 📋 Visão Geral

Sistema completo de controle de acesso baseado em perfis (RBAC - Role-Based Access Control) para o VollMed.

## 🎭 Perfis Disponíveis

### 1. **ADMIN** (Administrador)
- ✅ Acesso total ao sistema
- ✅ Gerenciar usuários (criar, editar, excluir)
- ✅ Gerenciar médicos, pacientes e consultas
- ✅ Acessar relatórios e configurações
- 🔴 **Menu exclusivo:** Usuários

### 2. **MEDICO** (Médico)
- ✅ Gerenciar suas consultas
- ✅ Visualizar pacientes
- ✅ Gerar relatórios médicos
- ❌ Não pode gerenciar usuários

### 3. **RECEPCIONISTA** (Recepcionista)
- ✅ Agendar consultas
- ✅ Cadastrar e editar pacientes
- ✅ Visualizar médicos
- ❌ Não pode gerenciar usuários
- ❌ Acesso limitado a relatórios

### 4. **PACIENTE** (Paciente)
- ✅ Visualizar suas próprias consultas
- ✅ Atualizar seus dados pessoais
- ❌ Sem acesso administrativo

## 🗄️ Estrutura do Banco de Dados

### Tabela `usuarios`
```sql
- id (BIGINT, PK)
- nome (VARCHAR)
- email (VARCHAR, UNIQUE)
- senha (VARCHAR) -- BCrypt hashed
- perfil (VARCHAR) -- ENUM: ADMIN, MEDICO, PACIENTE, RECEPCIONISTA
```

## 🔐 Implementação de Segurança

### Spring Security Configuration
```java
@EnableMethodSecurity(prePostEnabled = true)
```

### Anotações de Controle de Acesso
```java
@PreAuthorize("hasRole('ADMIN')")  // Apenas ADMIN
@PreAuthorize("hasAnyRole('ADMIN', 'MEDICO')")  // ADMIN ou MEDICO
```

### Thymeleaf Security
```html
<li sec:authorize="hasRole('ADMIN')">
    <a th:href="@{/usuarios}">Usuários</a>
</li>
```

## 📁 Arquivos Criados/Modificados

### Domain Layer
- ✅ `Perfil.java` - Enum com os perfis do sistema
- ✅ `DadosCadastroUsuario.java` - DTO para cadastro
- ✅ `DadosListagemUsuario.java` - DTO para listagem
- ✅ `Usuario.java` - Entidade com perfil e authorities
- ✅ `UsuarioRepository.java` - Queries customizadas
- ✅ `UsuarioService.java` - Lógica de negócio

### Controller Layer
- ✅ `UsuarioController.java` - CRUD de usuários (apenas ADMIN)

### View Layer
- ✅ `listagem-usuarios.html` - Listagem com badges de perfil
- ✅ `formulario-usuario.html` - Formulário de cadastro/edição
- ✅ `_menu.html` - Menu atualizado com link para usuários

### Database
- ✅ `V10__adicionar-perfil-usuario.sql` - Migração Flyway

## 🚀 Como Usar

### 1. Acessar Gestão de Usuários
- Login como **ADMIN**
- Menu: **🔐 Usuários**

### 2. Criar Novo Usuário
1. Clicar em "Novo Usuário"
2. Preencher:
   - Nome completo
   - Email
   - Senha (mínimo 6 caracteres)
   - Perfil de acesso
3. Salvar

### 3. Editar Usuário
- Clicar no ícone de editar
- Modificar dados necessários
- **Senha:** Deixar em branco para não alterar
- Salvar alterações

### 4. Excluir Usuário
- Clicar no ícone de excluir
- Confirmar exclusão no modal

## ⚠️ Vulnerabilidades Educacionais

### 1. **Exclusão do Último Admin**
```java
// ⚠️ VULNERABILIDADE: Não verifica se é o último admin
// Em produção, deveria impedir exclusão do último administrador
usuarioRepository.deleteById(id);
```

**Problema:** Sistema pode ficar sem administrador

**Correção (não implementada):**
```java
if (usuario.getPerfil() == Perfil.ADMIN) {
    long countAdmins = repository.countByPerfil(Perfil.ADMIN);
    if (countAdmins <= 1) {
        throw new RegraDeNegocioException("Não é possível excluir o último administrador");
    }
}
```

### 2. **Escalação de Privilégios**
Um usuário comum poderia tentar modificar seu próprio perfil enviando requisições diretas.

**Mitigação implementada:** 
- `@PreAuthorize("hasRole('ADMIN')")` no controller
- Validação no service layer

## 🧪 Testes Sugeridos

### 1. Testar Controle de Acesso
```
✅ Login como ADMIN → Ver menu "Usuários"
✅ Login como MEDICO → Menu "Usuários" não aparece
✅ Acessar /usuarios como MEDICO → 403 Forbidden
```

### 2. Testar CRUD
```
✅ Criar usuário com cada perfil
✅ Editar usuário mantendo senha
✅ Editar usuário alterando senha
✅ Excluir usuário
```

### 3. Testar Validações
```
✅ Email duplicado
✅ Senha em branco (novo usuário)
✅ Perfil não selecionado
```

## 📊 Dados de Teste

A migração `V10` cria usuários exemplo:

| Nome | Email | Senha | Perfil |
|------|-------|-------|--------|
| Dr. Carlos Médico | medico@vollmed.com | (gerar hash) | MEDICO |
| Ana Recepcionista | recepcao@vollmed.com | (gerar hash) | RECEPCIONISTA |
| João Paciente | paciente@vollmed.com | (gerar hash) | PACIENTE |

**⚠️ Lembre-se:** Gere senhas com BCrypt antes de inserir!

```java
BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
String hash = encoder.encode("senha123");
```

## 🎯 Próximos Passos (Melhorias)

1. **Auditoria de Ações**
   - Registrar quem criou/editou/excluiu usuários
   - Tabela de logs de auditoria

2. **Recuperação de Senha**
   - Fluxo de "esqueci minha senha"
   - Envio de email com token

3. **Perfis Customizáveis**
   - Criar perfis personalizados
   - Permissões granulares por funcionalidade

4. **Sessões Simultâneas**
   - Controlar número de sessões ativas por usuário

5. **Histórico de Senhas**
   - Impedir reuso de senhas antigas

## 📚 Referências

- [Spring Security Method Security](https://docs.spring.io/spring-security/reference/servlet/authorization/method-security.html)
- [OWASP - Broken Access Control](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [BCrypt Password Encoder](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/crypto/bcrypt/BCryptPasswordEncoder.html)
