package med.voll.web_application.domain.usuario;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import med.voll.web_application.domain.exception.RegraDeNegocioException;

@Service
public class UsuarioService implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        return usuarioRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado com o email: " + email));
    }

    public Usuario registrarUsuario(DadosRegistroUsuario dados) {
        if (usuarioRepository.existsByEmailIgnoreCase(dados.email())) {
            throw new IllegalArgumentException("Email já cadastrado no sistema");
        }

        if (!dados.senhasConferem()) {
            throw new IllegalArgumentException("Senhas não conferem");
        }

        String senhaCriptografada = passwordEncoder.encode(dados.senha());

        Usuario novoUsuario = new Usuario(dados.nome(), dados.email(), senhaCriptografada, Perfil.PACIENTE);
        return usuarioRepository.save(novoUsuario);
    }

    // Métodos para gestão de usuários (apenas ADMIN)

    public Page<DadosListagemUsuario> listar(Pageable paginacao) {
        return usuarioRepository.findAll(paginacao).map(DadosListagemUsuario::new);
    }

    @Transactional
    public void cadastrar(DadosCadastroUsuario dados) {

        // Validar email único
        if (usuarioRepository.existeUsuarioComEmail(dados.getEmail(), dados.getId())) {
            throw new RegraDeNegocioException("Já existe um usuário cadastrado com este email");
        }

        if (dados.getId() == null) {

            if (dados.getSenha() == null || dados.getSenha().isBlank()) {
                throw new RegraDeNegocioException("Senha é obrigatória para novo usuário");
            }

            var senhaEncriptada = passwordEncoder.encode(dados.getSenha());
            var usuario = new Usuario(dados.getNome(), dados.getEmail(), senhaEncriptada, dados.getPerfil());
            usuarioRepository.save(usuario);
        } else {
            // Atualizar usuário existente
            var usuario = usuarioRepository.findById(dados.getId())
                    .orElseThrow(() -> new RegraDeNegocioException("Usuário não encontrado"));

            usuario.atualizarDados(dados.getNome(), dados.getEmail(), dados.getPerfil());

            // Só atualiza senha se for fornecida
            if (dados.getSenha() != null && !dados.getSenha().isBlank()) {
                usuario.setSenha(passwordEncoder.encode(dados.getSenha()));
            }

            usuarioRepository.save(usuario);
        }
    }

    public DadosCadastroUsuario carregarPorId(Long id) {
        var usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RegraDeNegocioException("Usuário não encontrado"));
        return new DadosCadastroUsuario(usuario);
    }

    @Transactional
    public void excluir(Long id) {
        var usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RegraDeNegocioException("Usuário não encontrado"));

        // ⚠️ VULNERABILIDADE EDUCACIONAL: Não verifica se é o último admin
        // Em produção, deveria impedir exclusão do último administrador
        usuarioRepository.deleteById(id);
    }

    public List<DadosListagemUsuario> listarPorPerfil(Perfil perfil) {
        return usuarioRepository.findByPerfil(perfil).stream()
                .map(DadosListagemUsuario::new)
                .toList();
    }
}
