package med.voll.web_application.domain.consulta;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import med.voll.web_application.domain.exception.RegraDeNegocioException;
import med.voll.web_application.domain.medico.MedicoRepository;
import med.voll.web_application.domain.paciente.PacienteRepository;

@Service
public class ConsultaService {

    private final ConsultaRepository repository;
    private final MedicoRepository medicoRepository;
    private final PacienteRepository pacienteRepository;

    public ConsultaService(ConsultaRepository repository, MedicoRepository medicoRepository,
            PacienteRepository pacienteRepository) {
        this.repository = repository;
        this.medicoRepository = medicoRepository;
        this.pacienteRepository = pacienteRepository;
    }

    public Page<DadosListagemConsulta> listar(Pageable paginacao) {
        return repository.findAllByAtivoTrueOrderByData(paginacao).map(DadosListagemConsulta::new);
    }

    public Page<DadosListagemConsulta> listarPorPaciente(Long pacienteId, Pageable paginacao) {
        return repository.findByPacienteRefIdAndAtivoTrueOrderByData(pacienteId, paginacao)
                .map(DadosListagemConsulta::new);
    }

    @Transactional
    public void cadastrar(DadosAgendamentoConsulta dados) {
        var medicoConsulta = medicoRepository.findById(dados.idMedico()).orElseThrow();

        // Buscar paciente pelo ID informado
        var pacienteEncontrado = pacienteRepository.findById(dados.pacienteId())
                .orElseThrow(() -> new RegraDeNegocioException("Paciente não encontrado"));

        if (dados.id() == null) {
            repository.save(new Consulta(medicoConsulta, pacienteEncontrado, dados));
        } else {
            var consulta = buscarConsultaAtivaPorId(dados.id());
            consulta.modificarDados(medicoConsulta, pacienteEncontrado, dados);
        }
    }

    public DadosAgendamentoConsulta carregarPorId(Long id) {
        var consulta = buscarConsultaAtivaPorId(id);
        var medicoConsulta = medicoRepository.getReferenceById(consulta.getMedico().getId());
        return new DadosAgendamentoConsulta(
                consulta.getId(),
                consulta.getMedico().getId(),
                consulta.getPacienteRef() != null ? consulta.getPacienteRef().getId() : null,
                consulta.getData(),
                medicoConsulta.getEspecialidade());
    }

    @Transactional
    public void excluir(Long id) {
        var consulta = buscarConsultaAtivaPorId(id);
        consulta.inativar();
    }

    private Consulta buscarConsultaAtivaPorId(Long id) {
        var consulta = repository.findById(id)
                .orElseThrow(() -> new RegraDeNegocioException("Consulta não encontrada"));

        if (Boolean.FALSE.equals(consulta.getAtivo())) {
            throw new ConsultaInativaException("Esta consulta foi inativada e não pode mais ser acessada");
        }

        return consulta;
    }

}
