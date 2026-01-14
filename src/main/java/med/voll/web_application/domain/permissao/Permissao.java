package med.voll.web_application.domain.permissao;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "permissoes")
public class Permissao {

 @Id
 @GeneratedValue(strategy = GenerationType.IDENTITY)
 private Long id;

 @ManyToOne(fetch = FetchType.EAGER)
 @JoinColumn(name = "recurso_id", nullable = false)
 private Recurso recurso;

 @Column(nullable = false, length = 50)
 private String acao;

 @Column(nullable = false)
 private String descricao;

 // Construtores
 public Permissao() {
 }

 public Permissao(Recurso recurso, String acao, String descricao) {
  this.recurso = recurso;
  this.acao = acao;
  this.descricao = descricao;
 }

 // Método auxiliar para verificar permissão
 public boolean permite(String nomeRecurso, String acaoSolicitada) {
  return this.recurso.getNome().equalsIgnoreCase(nomeRecurso)
    && this.acao.equalsIgnoreCase(acaoSolicitada);
 }

 // Getters e Setters
 public Long getId() {
  return id;
 }

 public void setId(Long id) {
  this.id = id;
 }

 public Recurso getRecurso() {
  return recurso;
 }

 public void setRecurso(Recurso recurso) {
  this.recurso = recurso;
 }

 public String getAcao() {
  return acao;
 }

 public void setAcao(String acao) {
  this.acao = acao;
 }

 public String getDescricao() {
  return descricao;
 }

 public void setDescricao(String descricao) {
  this.descricao = descricao;
 }
}
