package med.voll.web_application.domain.paciente;

import java.math.BigInteger;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import med.voll.web_application.domain.exception.RegraDeNegocioException;

@Service
public class PacienteService {

  private final PacienteRepository repository;

  public PacienteService(PacienteRepository repository) {
    this.repository = repository;
  }

  // Listar pacientes com paginação
  public Page<DadosListagemPaciente> listar(Pageable paginacao) {
    return repository.findByAtivoTrue(paginacao)
        .map(DadosListagemPaciente::new);
  }

  // Cadastrar novo paciente
  @Transactional
  public void cadastrar(DadosCadastroPaciente dados) {
    validarDadosPaciente(dados);

    var paciente = new Paciente(dados);
    repository.save(paciente);
  }

  // Carregar paciente por ID (para edição)
  public DadosCadastroPaciente carregarPorId(Long id) {
    var paciente = repository.findById(id)
        .orElseThrow(() -> new RegraDeNegocioException("Paciente não encontrado"));

    return new DadosCadastroPaciente(paciente);
  }

  // Atualizar paciente existente
  @Transactional
  public void atualizar(DadosCadastroPaciente dados) {
    if (dados.id() == null) {
      throw new RegraDeNegocioException("ID do paciente é obrigatório para atualização");
    }

    var paciente = repository.findById(dados.id())
        .orElseThrow(() -> new RegraDeNegocioException("Paciente não encontrado"));

    validarDadosPaciente(dados);
    paciente.atualizarDados(dados);

    repository.save(paciente);
  }

  // Excluir (inativar) paciente
  @Transactional
  public void excluir(Long id) {
    var paciente = repository.findById(id)
        .orElseThrow(() -> new RegraDeNegocioException("Paciente não encontrado"));

    paciente.inativar();
    repository.save(paciente);
  }

  // ⚠️ MÉTODO VULNERÁVEL - PARA DEMONSTRAÇÃO EDUCACIONAL
  // Este método chama uma procedure com vulnerabilidade SQL Injection
  // NÃO USE EM PRODUÇÃO!
  public List<DadosListagemPaciente> buscarPorNome(String nome) {
    System.out.println("🚨 ATENÇÃO: Executando busca vulnerável para: " + nome);
    System.out.println("⚠️  Esta funcionalidade contém vulnerabilidade intencional para fins educacionais!");

    try {
      List<Object[]> resultados = repository.buscarPacientePorNome(nome);

      return resultados.stream().map(result -> {
        // Mapeamento dos resultados da procedure - ajustado para tipos corretos
        Long id = result[0] instanceof BigInteger ? ((BigInteger) result[0]).longValue() : (Long) result[0];
        String nomeResult = (String) result[1];
        String email = (String) result[2];
        String telefone = (String) result[3];
        String cpf = (String) result[4];
        LocalDate dataNascimento = result[5] != null ? ((java.sql.Date) result[5]).toLocalDate() : null;
        String planoSaude = (String) result[6];

        return new DadosListagemPaciente(id, nomeResult, email, telefone, cpf, dataNascimento, planoSaude, true);
      }).collect(Collectors.toList());

    } catch (Exception e) {
      System.err.println("❌ ERRO na busca vulnerável: " + e.getMessage());
      throw new RegraDeNegocioException("Erro na busca de pacientes: " + e.getMessage());
    }
  }

  // Buscar por plano de saúde
  public List<DadosListagemPaciente> buscarPorPlanoSaude(String planoSaude) {
    List<Paciente> pacientes = repository.findByPlanoSaudeAndAtivoTrue(planoSaude);
    return pacientes.stream()
        .map(DadosListagemPaciente::new)
        .collect(Collectors.toList());
  }

  // Validações de negócio
  private void validarDadosPaciente(DadosCadastroPaciente dados) {
    // Validar CPF único
    if (repository.existePacienteComCpf(dados.cpf(), dados.id())) {
      throw new RegraDeNegocioException("Já existe um paciente cadastrado com este CPF");
    }

    // Validar email único
    if (repository.existePacienteComEmail(dados.email(), dados.id())) {
      throw new RegraDeNegocioException("Já existe um paciente cadastrado com este email");
    }

    // Validar idade mínima
    if (dados.dataNascimento() != null && dados.dataNascimento().isAfter(LocalDate.now().minusYears(1))) {
      throw new RegraDeNegocioException("Paciente deve ter pelo menos 1 ano de idade");
    }
  }
}
