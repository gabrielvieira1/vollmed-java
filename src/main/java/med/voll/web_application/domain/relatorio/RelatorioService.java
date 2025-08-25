package med.voll.web_application.domain.relatorio;

import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

// Imports para PDF (iText 5)
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfWriter;

import med.voll.web_application.domain.consulta.ConsultaRepository;
import med.voll.web_application.domain.exception.RegraDeNegocioException;
import med.voll.web_application.domain.medico.MedicoRepository;

@Service
public class RelatorioService {

  private static final String CHAVE_AES_DEMO = "VollMed2024SecretKey1234567890AB"; // 32 bytes para AES-256

  private static final String ALGORITMO_SEGURO = "AES";

  private static final String TRANSFORMACAO_SEGURA = "AES/CBC/PKCS5Padding";

  private final RelatorioRepository repository;
  private final ConsultaRepository consultaRepository;
  private final MedicoRepository medicoRepository;

  public RelatorioService(RelatorioRepository repository,
      ConsultaRepository consultaRepository,
      MedicoRepository medicoRepository) {
    this.repository = repository;
    this.consultaRepository = consultaRepository;
    this.medicoRepository = medicoRepository;
  }

  @Transactional
  public void cadastrar(DadosCadastroRelatorio dados) {
    var consulta = consultaRepository.findById(dados.consultaId())
        .orElseThrow(() -> new RegraDeNegocioException("Consulta não encontrada"));

    var medico = medicoRepository.findById(dados.medicoId())
        .orElseThrow(() -> new RegraDeNegocioException("Médico não encontrado"));

    var relatorio = new Relatorio(
        consulta, medico, dados.diagnostico(), dados.procedimento(),
        dados.historicoFamiliar(), dados.medicacao(), dados.observacoesMedicas(),
        dados.numeroSUS(), dados.cpfPaciente());

    // Criptografar dados sensíveis com AES
    String dadosSensiveis = criarStringDadosSensiveis(relatorio);
    String dadosCriptografados = criptografarDadosSeguro(dadosSensiveis);
    relatorio.setDadosCriptografados(dadosCriptografados);

    repository.save(relatorio);
  }

  private String criptografarDadosSeguro(String dados) {
    try {
      // Criar chave AES-256
      SecretKeySpec chave = new SecretKeySpec(
          CHAVE_AES_DEMO.getBytes(StandardCharsets.UTF_8),
          ALGORITMO_SEGURO);

      // Gerar IV aleatório para CBC
      byte[] iv = new byte[16]; // AES usa blocos de 16 bytes
      new SecureRandom().nextBytes(iv);
      IvParameterSpec ivSpec = new IvParameterSpec(iv);

      // Configurar cipher com AES/CBC
      Cipher cipher = Cipher.getInstance(TRANSFORMACAO_SEGURA);
      cipher.init(Cipher.ENCRYPT_MODE, chave, ivSpec);

      byte[] dadosBytes = dados.getBytes(StandardCharsets.UTF_8);
      byte[] dadosCriptografados = cipher.doFinal(dadosBytes);

      // Combinar IV + dados criptografados
      byte[] resultado = new byte[iv.length + dadosCriptografados.length];
      System.arraycopy(iv, 0, resultado, 0, iv.length);
      System.arraycopy(dadosCriptografados, 0, resultado, iv.length, dadosCriptografados.length);

      return Base64.getEncoder().encodeToString(resultado);

    } catch (Exception e) {
      System.err.println("ERRO na criptografia AES: " + e.getMessage());
      return "ERRO_CRIPTOGRAFIA:" + dados;
    }
  }

  private String criarStringDadosSensiveis(Relatorio relatorio) {
    StringBuilder sb = new StringBuilder();
    sb.append("DIAGNOSTICO:").append(relatorio.getDiagnostico()).append("|");
    sb.append("PROCEDIMENTO:").append(relatorio.getProcedimento()).append("|");
    sb.append("HISTORICO:").append(relatorio.getHistoricoFamiliar()).append("|");
    sb.append("MEDICACAO:").append(relatorio.getMedicacao()).append("|");
    sb.append("SUS:").append(relatorio.getNumeroSUS()).append("|");
    sb.append("CPF:").append(relatorio.getCpfPaciente()).append("|");

    return sb.toString();
  }

  public Page<DadosListagemRelatorio> listar(Pageable paginacao) {
    return repository.findAll(paginacao)
        .map(DadosListagemRelatorio::new);
  }

  public java.util.List<med.voll.web_application.domain.consulta.Consulta> listarConsultasDisponiveis() {
    return consultaRepository.findAll();
  }

  public java.util.List<med.voll.web_application.domain.medico.Medico> listarMedicosAtivos() {
    return medicoRepository.findAll();
  }

  public DadosCadastroRelatorio carregarPorId(Long id) {
    var relatorio = repository.findById(id)
        .orElseThrow(() -> new RegraDeNegocioException("Relatório não encontrado"));

    return new DadosCadastroRelatorio(
        relatorio.getId(),
        relatorio.getConsulta().getId(),
        relatorio.getMedico().getId(),
        relatorio.getDiagnostico(),
        relatorio.getProcedimento(),
        relatorio.getHistoricoFamiliar(),
        relatorio.getMedicacao(),
        relatorio.getObservacoesMedicas(),
        relatorio.getNumeroSUS(),
        relatorio.getCpfPaciente());
  }

  @Transactional
  public void excluir(Long id) {
    var relatorio = repository.findById(id)
        .orElseThrow(() -> new RegraDeNegocioException("Relatório não encontrado"));

    repository.delete(relatorio);
  }

  @Transactional
  public void atualizar(Long id, DadosCadastroRelatorio dados) {
    var relatorio = repository.findById(id)
        .orElseThrow(() -> new RegraDeNegocioException("Relatório não encontrado"));

    var consulta = consultaRepository.findById(dados.consultaId())
        .orElseThrow(() -> new RegraDeNegocioException("Consulta não encontrada"));

    var medico = medicoRepository.findById(dados.medicoId())
        .orElseThrow(() -> new RegraDeNegocioException("Médico não encontrado"));

    // Atualizar dados do relatório
    relatorio.setConsulta(consulta);
    relatorio.setMedico(medico);
    relatorio.setDiagnostico(dados.diagnostico());
    relatorio.setProcedimento(dados.procedimento());
    relatorio.setHistoricoFamiliar(dados.historicoFamiliar());
    relatorio.setMedicacao(dados.medicacao());
    relatorio.setObservacoesMedicas(dados.observacoesMedicas());
    relatorio.setNumeroSUS(dados.numeroSUS());
    relatorio.setCpfPaciente(dados.cpfPaciente());

    // Recriptografar dados sensíveis com os novos dados
    String dadosSensiveis = criarStringDadosSensiveis(relatorio);
    String dadosCriptografados = criptografarDadosSeguro(dadosSensiveis);
    relatorio.setDadosCriptografados(dadosCriptografados);

    repository.save(relatorio);
  }

  public byte[] exportarRelatorioPDF(Long relatorioId, boolean criptografado) {
    var relatorio = repository.findById(relatorioId)
        .orElseThrow(() -> new RegraDeNegocioException("Relatório não encontrado"));

    try {
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      Document document = new Document();
      PdfWriter.getInstance(document, baos);

      document.open();

      // Título do documento
      Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
      Paragraph title = new Paragraph("RELATÓRIO MÉDICO - VOLLMED", titleFont);
      title.setAlignment(Element.ALIGN_CENTER);
      document.add(title);

      document.add(new Paragraph(" ")); // Espaço

      // Data de geração
      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
      document.add(new Paragraph("Gerado em: " + LocalDateTime.now().format(formatter)));
      document.add(new Paragraph(" "));

      // Informações do médico
      Font sectionFont = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD);
      document.add(new Paragraph("INFORMAÇÕES DO MÉDICO:", sectionFont));
      document.add(new Paragraph("Nome: " + relatorio.getMedico().getNome()));
      document.add(new Paragraph("Especialidade: " + relatorio.getMedico().getEspecialidade()));
      document.add(new Paragraph("CRM: " + relatorio.getMedico().getCrm()));
      document.add(new Paragraph(" "));

      // Informações da consulta
      document.add(new Paragraph("INFORMAÇÕES DA CONSULTA:", sectionFont));
      document.add(new Paragraph("Data: " + relatorio.getConsulta().getData()));
      document.add(new Paragraph(" "));

      // Dados do relatório
      document.add(new Paragraph("DADOS DO RELATÓRIO:", sectionFont));

      if (criptografado) {
        // Exportar dados criptografados
        document.add(new Paragraph("⚠️ DADOS CRIPTOGRAFADOS COM AES-256/CBC"));
        document.add(new Paragraph(" "));

        String dadosSensiveis = criarStringDadosSensiveis(relatorio);
        String dadosCriptografados = criptografarDadosSeguro(dadosSensiveis);

        Font cryptoFont = new Font(Font.FontFamily.COURIER, 10);
        Paragraph cryptoPara = new Paragraph("Dados Criptografados (Base64):", cryptoFont);
        document.add(cryptoPara);
        document.add(new Paragraph(dadosCriptografados, cryptoFont));

      } else {
        // Exportar dados em texto claro
        document.add(new Paragraph("Diagnóstico: " + relatorio.getDiagnostico()));
        document.add(new Paragraph("Procedimento: " + relatorio.getProcedimento()));
        document.add(new Paragraph("Histórico Familiar: " + relatorio.getHistoricoFamiliar()));
        document.add(new Paragraph("Medicação: " + relatorio.getMedicacao()));
        document.add(new Paragraph("Observações Médicas: " + relatorio.getObservacoesMedicas()));
        document.add(new Paragraph(" "));
        document.add(new Paragraph("Número SUS: " + relatorio.getNumeroSUS()));
        document.add(new Paragraph("CPF do Paciente: " + relatorio.getCpfPaciente()));
      }

      document.close();

      return baos.toByteArray();

    } catch (DocumentException e) {
      throw new RegraDeNegocioException("Erro ao gerar PDF: " + e.getMessage());
    }
  }
}
