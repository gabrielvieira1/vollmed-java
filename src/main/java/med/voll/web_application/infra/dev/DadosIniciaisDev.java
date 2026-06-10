package med.voll.web_application.infra.dev;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import med.voll.web_application.domain.paciente.Paciente;
import med.voll.web_application.domain.paciente.PacienteRepository;
import med.voll.web_application.domain.permissao.Grupo;
import med.voll.web_application.domain.permissao.GrupoRepository;
import med.voll.web_application.domain.usuario.Perfil;
import med.voll.web_application.domain.usuario.Usuario;
import med.voll.web_application.domain.usuario.UsuarioRepository;

@Component
@Profile("dev")
@ConditionalOnProperty(name = "app.dev.seed-users", havingValue = "true", matchIfMissing = true)
public class DadosIniciaisDev implements ApplicationRunner {

    private final UsuarioRepository usuarioRepository;
    private final GrupoRepository grupoRepository;
    private final PacienteRepository pacienteRepository;
    private final PasswordEncoder passwordEncoder;
    private final String senha;

    public DadosIniciaisDev(
            UsuarioRepository usuarioRepository,
            GrupoRepository grupoRepository,
            PacienteRepository pacienteRepository,
            PasswordEncoder passwordEncoder,
            @Value("${app.dev.test-user-password}") String senha) {
        this.usuarioRepository = usuarioRepository;
        this.grupoRepository = grupoRepository;
        this.pacienteRepository = pacienteRepository;
        this.passwordEncoder = passwordEncoder;
        this.senha = senha;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        criarUsuario("Administrador de Teste", "admin@vollmed.local", Perfil.ADMIN, "Administradores", null);
        criarUsuario("Medico de Teste", "medico@vollmed.local", Perfil.MEDICO, "Médicos", null);

        Paciente ana = pacienteRepository.findByEmailIgnoreCaseAndAtivoTrue("ana.silva@email.com")
                .orElseThrow(() -> new IllegalStateException("Paciente de teste Ana Silva não encontrada"));
        criarUsuario("Ana Silva Santos", ana.getEmail(), Perfil.PACIENTE, "Pacientes", ana);
    }

    private void criarUsuario(String nome, String email, Perfil perfil, String nomeGrupo, Paciente paciente) {
        if (usuarioRepository.existsByEmailIgnoreCase(email)) {
            return;
        }

        Grupo grupo = grupoRepository.findByNome(nomeGrupo)
                .orElseThrow(() -> new IllegalStateException("Grupo de teste não encontrado: " + nomeGrupo));

        Usuario usuario = new Usuario(nome, email, passwordEncoder.encode(senha), perfil);
        usuario.setPaciente(paciente);
        usuario.adicionarGrupo(grupo);
        usuarioRepository.save(usuario);
    }
}
