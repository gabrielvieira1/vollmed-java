package med.voll.web_application.domain.paciente;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public record DadosListagemPaciente(
  Long id,
  String nome,
  String email,
  String telefone,
  String cpf,
  LocalDate dataNascimento,
  String planoSaude,
  Boolean ativo) {
 public DadosListagemPaciente(Paciente paciente) {
  this(
    paciente.getId(),
    paciente.getNome(),
    paciente.getEmail(),
    paciente.getTelefone(),
    paciente.getCpf(),
    paciente.getDataNascimento(),
    paciente.getPlanoSaude(),
    paciente.getAtivo());
 }

 // Método auxiliar para formatação de data na view
 public String getDataNascimentoFormatada() {
  if (dataNascimento != null) {
   return dataNascimento.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
  }
  return "";
 }

 // Método auxiliar para formatação de CPF na view
 public String getCpfFormatado() {
  if (cpf != null && cpf.length() == 11) {
   return cpf.replaceAll("(\\d{3})(\\d{3})(\\d{3})(\\d{2})", "$1.$2.$3-$4");
  }
  return cpf;
 }

 // Método auxiliar para formatação de telefone na view
 public String getTelefoneFormatado() {
  if (telefone != null) {
   if (telefone.length() == 11) {
    return telefone.replaceAll("(\\d{2})(\\d{5})(\\d{4})", "($1) $2-$3");
   } else if (telefone.length() == 10) {
    return telefone.replaceAll("(\\d{2})(\\d{4})(\\d{4})", "($1) $2-$3");
   }
  }
  return telefone;
 }
}
