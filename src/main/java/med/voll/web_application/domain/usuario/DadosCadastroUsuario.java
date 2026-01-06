package med.voll.web_application.domain.usuario;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class DadosCadastroUsuario {
 private Long id;

 @NotBlank(message = "Nome é obrigatório")
 private String nome;

 @NotBlank(message = "Email é obrigatório")
 @Email(message = "Email inválido")
 private String email;

 private String senha;

 @NotNull(message = "Perfil é obrigatório")
 private Perfil perfil;

 public DadosCadastroUsuario() {
  this.perfil = Perfil.PACIENTE;
 }

 public DadosCadastroUsuario(Long id, String nome, String email, String senha, Perfil perfil) {
  this.id = id;
  this.nome = nome;
  this.email = email;
  this.senha = senha;
  this.perfil = perfil;
 }

 public DadosCadastroUsuario(Usuario usuario) {
  this.id = usuario.getId();
  this.nome = usuario.getNome();
  this.email = usuario.getEmail();
  this.senha = "";
  this.perfil = usuario.getPerfil();
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

 public String getEmail() {
  return email;
 }

 public void setEmail(String email) {
  this.email = email;
 }

 public String getSenha() {
  return senha;
 }

 public void setSenha(String senha) {
  this.senha = senha;
 }

 public Perfil getPerfil() {
  return perfil;
 }

 public void setPerfil(Perfil perfil) {
  this.perfil = perfil;
 }
}
