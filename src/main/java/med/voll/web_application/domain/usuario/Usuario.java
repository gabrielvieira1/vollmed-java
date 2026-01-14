package med.voll.web_application.domain.usuario;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import med.voll.web_application.domain.paciente.Paciente;
import med.voll.web_application.domain.permissao.Grupo;

@Entity
@Table(name = "usuarios")
public class Usuario implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String nome;
    private String email;
    private String senha;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Perfil perfil;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "paciente_id")
    private Paciente paciente;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "usuario_grupos", joinColumns = @JoinColumn(name = "usuario_id"), inverseJoinColumns = @JoinColumn(name = "grupo_id"))
    private Set<Grupo> grupos = new HashSet<>();

    public Usuario() {
    }

    public Usuario(String nome, String email, String senha, Perfil perfil) {
        this.nome = nome;
        this.email = email;
        this.senha = senha;
        this.perfil = perfil;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // Retorna ROLE do perfil + permissões dos grupos
        Set<GrantedAuthority> authorities = new HashSet<>();

        // Adiciona role baseada no perfil (compatibilidade retroativa)
        authorities.add(new SimpleGrantedAuthority("ROLE_" + perfil.name()));

        // Adiciona permissões dos grupos
        for (Grupo grupo : grupos) {
            grupo.getPermissoes().forEach(permissao -> {
                String authority = permissao.getRecurso().getNome().toUpperCase()
                        + "_" + permissao.getAcao().toUpperCase();
                authorities.add(new SimpleGrantedAuthority(authority));
            });
        }

        return authorities;
    }

    @Override
    public String getPassword() {
        return senha;
    }

    @Override
    public String getUsername() {
        return email;
    }

    public String getNome() {
        return nome;
    }

    public String getEmail() {
        return email;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    public Long getId() {
        return id;
    }

    public Perfil getPerfil() {
        return perfil;
    }

    public void setPerfil(Perfil perfil) {
        this.perfil = perfil;
    }

    public Set<Grupo> getGrupos() {
        return grupos;
    }

    public void setGrupos(Set<Grupo> grupos) {
        this.grupos = grupos;
    }

    public void adicionarGrupo(Grupo grupo) {
        this.grupos.add(grupo);
    }

    public void removerGrupo(Grupo grupo) {
        this.grupos.remove(grupo);
    }

    public Paciente getPaciente() {
        return paciente;
    }

    public void setPaciente(Paciente paciente) {
        this.paciente = paciente;
    }

    // Verifica se o usuário tem uma permissão específica
    public boolean temPermissao(String recurso, String acao) {
        return grupos.stream()
                .anyMatch(grupo -> grupo.temPermissao(recurso, acao));
    }

    // Retorna lista de recursos que o usuário tem acesso
    public Set<String> getRecursosDisponiveis() {
        return grupos.stream()
                .flatMap(grupo -> grupo.getPermissoes().stream())
                .map(permissao -> permissao.getRecurso().getNome())
                .collect(Collectors.toSet());
    }

    public void atualizarDados(String nome, String email, Perfil perfil) {
        if (nome != null && !nome.isBlank()) {
            this.nome = nome;
        }
        if (email != null && !email.isBlank()) {
            this.email = email;
        }
        if (perfil != null) {
            this.perfil = perfil;
        }
    }
}
