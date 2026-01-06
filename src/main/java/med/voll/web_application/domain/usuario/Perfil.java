package med.voll.web_application.domain.usuario;

public enum Perfil {
 ADMIN("Administrador"),
 MEDICO("Médico"),
 PACIENTE("Paciente"),
 RECEPCIONISTA("Recepcionista");

 private String descricao;

 Perfil(String descricao) {
  this.descricao = descricao;
 }

 public String getDescricao() {
  return descricao;
 }
}
