package med.voll.web_application.domain.permissao;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "recursos")
public class Recurso {

 @Id
 @GeneratedValue(strategy = GenerationType.IDENTITY)
 private Long id;

 @Column(nullable = false, unique = true, length = 100)
 private String nome;

 @Column(nullable = false)
 private String descricao;

 @Column(length = 50)
 private String icone;

 @Column(name = "ordem")
 private Integer ordem = 0;

 @Column(nullable = false)
 private Boolean ativo = true;

 // Construtores
 public Recurso() {
 }

 public Recurso(String nome, String descricao, String icone, Integer ordem) {
  this.nome = nome;
  this.descricao = descricao;
  this.icone = icone;
  this.ordem = ordem;
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

 public String getIcone() {
  return icone;
 }

 public void setIcone(String icone) {
  this.icone = icone;
 }

 public Integer getOrdem() {
  return ordem;
 }

 public void setOrdem(Integer ordem) {
  this.ordem = ordem;
 }

 public Boolean getAtivo() {
  return ativo;
 }

 public void setAtivo(Boolean ativo) {
  this.ativo = ativo;
 }
}
