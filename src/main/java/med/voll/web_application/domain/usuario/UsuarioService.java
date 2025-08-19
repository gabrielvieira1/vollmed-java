package med.voll.web_application.domain.usuario;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

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

        Usuario novoUsuario = new Usuario(dados.nome(), dados.email(), senhaCriptografada);
        return usuarioRepository.save(novoUsuario);
    }
}
