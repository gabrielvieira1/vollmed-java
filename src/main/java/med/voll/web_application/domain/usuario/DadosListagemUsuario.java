package med.voll.web_application.domain.usuario;

public record DadosListagemUsuario(
  Long id,
  String nome,
  String email,
  String perfil,
  String perfilDescricao) {
 public DadosListagemUsuario(Usuario usuario) {
  this(
    usuario.getId(),
    usuario.getNome(),
    usuario.getEmail(),
    usuario.getPerfil().name(),
    usuario.getPerfil().getDescricao());
 }
}
