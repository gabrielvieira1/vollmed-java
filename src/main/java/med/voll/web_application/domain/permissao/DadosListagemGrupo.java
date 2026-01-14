package med.voll.web_application.domain.permissao;

public class DadosListagemGrupo {

 private Long id;
 private String nome;
 private String descricao;
 private Boolean padrao;
 private Boolean ativo;
 private Integer quantidadePermissoes;
 private Integer quantidadeUsuarios;

 public DadosListagemGrupo(Grupo grupo, Integer quantidadeUsuarios) {
  this.id = grupo.getId();
  this.nome = grupo.getNome();
  this.descricao = grupo.getDescricao();
  this.padrao = grupo.getPadrao();
  this.ativo = grupo.getAtivo();
  this.quantidadePermissoes = grupo.getPermissoes().size();
  this.quantidadeUsuarios = quantidadeUsuarios;
 }

 // Getters
 public Long getId() {
  return id;
 }

 public String getNome() {
  return nome;
 }

 public String getDescricao() {
  return descricao;
 }

 public Boolean getPadrao() {
  return padrao;
 }

 public Boolean getAtivo() {
  return ativo;
 }

 public Integer getQuantidadePermissoes() {
  return quantidadePermissoes;
 }

 public Integer getQuantidadeUsuarios() {
  return quantidadeUsuarios;
 }
}
