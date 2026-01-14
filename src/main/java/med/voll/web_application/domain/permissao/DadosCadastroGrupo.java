package med.voll.web_application.domain.permissao;

import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

public class DadosCadastroGrupo {

 private Long id;

 @NotBlank(message = "Nome do grupo é obrigatório")
 private String nome;

 private String descricao;

 @NotEmpty(message = "Selecione pelo menos uma permissão")
 private List<Long> permissoesIds;

 private Boolean ativo = true;

 public DadosCadastroGrupo() {
 }

 public DadosCadastroGrupo(Long id, String nome, String descricao, List<Long> permissoesIds, Boolean ativo) {
  this.id = id;
  this.nome = nome;
  this.descricao = descricao;
  this.permissoesIds = permissoesIds;
  this.ativo = ativo;
 }

 public DadosCadastroGrupo(Grupo grupo) {
  this.id = grupo.getId();
  this.nome = grupo.getNome();
  this.descricao = grupo.getDescricao();
  this.permissoesIds = grupo.getPermissoes().stream()
    .map(Permissao::getId)
    .toList();
  this.ativo = grupo.getAtivo();
 }

 // Getters e Setters
 public Long getId() {
  return id;
 }

 public void setId(Long id) {
  this.id = id;
 }

 public String getNome() {
  return nome;
 }

 public void setNome(String nome) {
  this.nome = nome;
 }

 public String getDescricao() {
  return descricao;
 }

 public void setDescricao(String descricao) {
  this.descricao = descricao;
 }

 public List<Long> getPermissoesIds() {
  return permissoesIds;
 }

 public void setPermissoesIds(List<Long> permissoesIds) {
  this.permissoesIds = permissoesIds;
 }

 public Boolean getAtivo() {
  return ativo;
 }

 public void setAtivo(Boolean ativo) {
  this.ativo = ativo;
 }
}
