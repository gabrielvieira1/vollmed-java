package med.voll.web_application.domain.permissao;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "grupos")
public class Grupo {

 @Id
 @GeneratedValue(strategy = GenerationType.IDENTITY)
 private Long id;

 @Column(nullable = false, unique = true, length = 100)
 private String nome;

 @Column(columnDefinition = "TEXT")
 private String descricao;

 @Column(nullable = false)
 private Boolean padrao = false;

 @Column(nullable = false)
 private Boolean ativo = true;

 @Column(name = "data_criacao")
 private LocalDateTime dataCriacao = LocalDateTime.now();

 @ManyToMany(fetch = FetchType.EAGER)
 @JoinTable(name = "grupo_permissoes", joinColumns = @JoinColumn(name = "grupo_id"), inverseJoinColumns = @JoinColumn(name = "permissao_id"))
 private Set<Permissao> permissoes = new HashSet<>();

 // Construtores
 public Grupo() {
 }

 public Grupo(String nome, String descricao, Boolean padrao) {
  this.nome = nome;
  this.descricao = descricao;
  this.padrao = padrao;
 }

 // Métodos de negócio
 public void adicionarPermissao(Permissao permissao) {
  this.permissoes.add(permissao);
 }

 public void removerPermissao(Permissao permissao) {
  this.permissoes.remove(permissao);
 }

 public boolean temPermissao(String recurso, String acao) {
  return permissoes.stream()
    .anyMatch(p -> p.permite(recurso, acao));
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

 public Boolean getPadrao() {
  return padrao;
 }

 public void setPadrao(Boolean padrao) {
  this.padrao = padrao;
 }

 public Boolean getAtivo() {
  return ativo;
 }

 public void setAtivo(Boolean ativo) {
  this.ativo = ativo;
 }

 public LocalDateTime getDataCriacao() {
  return dataCriacao;
 }

 public void setDataCriacao(LocalDateTime dataCriacao) {
  this.dataCriacao = dataCriacao;
 }

 public Set<Permissao> getPermissoes() {
  return permissoes;
 }

 public void setPermissoes(Set<Permissao> permissoes) {
  this.permissoes = permissoes;
 }
}
