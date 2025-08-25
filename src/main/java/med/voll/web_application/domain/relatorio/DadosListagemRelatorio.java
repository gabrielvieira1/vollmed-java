package med.voll.web_application.domain.relatorio;

import java.time.format.DateTimeFormatter;

/**
 * DTO para listagem de relatórios - VULNERÁVEL para fins educacionais
 *
 * Este DTO expõe dados sensíveis que não deveriam ser transmitidos
 */
public record DadosListagemRelatorio(
  Long id,
  String nomeMedico,
  String paciente,
  String diagnostico,
  String numeroSUS,
  String cpfPaciente,
  String dataGeracao) {

 public DadosListagemRelatorio(Relatorio relatorio) {
  this(
    relatorio.getId(),
    relatorio.getMedico() != null ? relatorio.getMedico().getNome() : "N/A",
    relatorio.getConsulta() != null ? relatorio.getConsulta().getPaciente() : "N/A",
    relatorio.getDiagnostico(),
    relatorio.getNumeroSUS(),
    relatorio.getCpfPaciente(), // VULNERABILIDADE: Expondo CPF completo
    relatorio.getDataGeracao().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));
 }

 /**
  * MÉTODO VULNERÁVEL - Para fins educacionais
  *
  * Método que retorna dados sensíveis sem mascaramento
  */
 public String getCpfCompleto() {
  return this.cpfPaciente;
 }

 /**
  * MÉTODO VULNERÁVEL - Para fins educacionais
  *
  * Retorna número SUS completo sem proteção
  */
 public String getSUSCompleto() {
  return this.numeroSUS;
 }
}
