package med.voll.web_application.domain.medico;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import jakarta.transaction.Transactional;
import med.voll.web_application.domain.exception.RegraDeNegocioException;

@Service
public class MedicoService {

    private final MedicoRepository repository;
    private final EntityManager entityManager;

    public MedicoService(MedicoRepository repository, EntityManager entityManager) {
        this.repository = repository;
        this.entityManager = entityManager;
    }

    public Page<DadosListagemMedico> listar(Pageable paginacao) {
        return repository.findAll(paginacao).map(DadosListagemMedico::new);
    }

    @Transactional
    public void cadastrar(DadosCadastroMedico dados) {
        if (repository.isJaCadastrado(dados.email(), dados.crm(), dados.id())) {
            throw new RegraDeNegocioException("E-mail ou CRM já cadastrado para outro médico!");
        }

        if (dados.id() == null) {
            repository.save(new Medico(dados));
        } else {
            var medico = repository.findById(dados.id()).orElseThrow();
            medico.atualizarDados(dados);
        }
    }

    public DadosCadastroMedico carregarPorId(Long id) {
        var medico = repository.findById(id).orElseThrow();
        return new DadosCadastroMedico(medico.getId(), medico.getNome(), medico.getEmail(), medico.getTelefone(),
                medico.getCrm(), medico.getEspecialidade());
    }

    @Transactional
    public void excluir(Long id) {
        repository.deleteById(id);
    }

    public List<DadosListagemMedico> listarPorEspecialidade(Especialidade especialidade) {
        return repository.findByEspecialidade(especialidade).stream().map(DadosListagemMedico::new).toList();
    }

    @SuppressWarnings("unchecked")
    public List<DadosListagemMedico> buscarPorNomeVulneravel(String nome) {
        String sql = "SELECT * FROM medicos WHERE nome LIKE '%" + nome + "%'";

        Query query = entityManager.createNativeQuery(sql, Medico.class);
        List<Medico> medicos = query.getResultList();

        return medicos.stream().map(DadosListagemMedico::new).toList();
    }

}
