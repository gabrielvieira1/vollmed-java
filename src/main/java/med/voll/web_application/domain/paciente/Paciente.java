package med.voll.web_application.domain.paciente;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "pacientes")
public class Paciente {

 @Id
 @GeneratedValue(strategy = GenerationType.IDENTITY)
 private Long id;

 @Column(nullable = false)
 private String nome;

 @Column(nullable = false, unique = true)
 private String email;

 @Column(nullable = false)
 private String telefone;

 @Column(nullable = false, unique = true)
 private String cpf;

 @Column(name = "data_nascimento", nullable = false)
 private LocalDate dataNascimento;

 private String endereco;

 @Column(name = "plano_saude")
 private String planoSaude;

 @Column(name = "numero_carteirinha")
 private String numeroCarteirinha;

 @Column(nullable = false)
 private Boolean ativo = true;

 @Column(name = "data_cadastro", nullable = false)
 private LocalDateTime dataCadastro = LocalDateTime.now();

 // Construtor padrão
 public Paciente() {
 }

 // Construtor para cadastro
 public Paciente(DadosCadastroPaciente dados) {
  this.nome = dados.nome();
  this.email = dados.email();
  this.telefone = dados.telefone();
  this.cpf = dados.cpf();
  this.dataNascimento = dados.dataNascimento();
  this.endereco = dados.endereco();
  this.planoSaude = dados.planoSaude();
  this.numeroCarteirinha = dados.numeroCarteirinha();
  this.ativo = true;
  this.dataCadastro = LocalDateTime.now();
 }

 // Método de negócio para atualizar dados
 public void atualizarDados(DadosCadastroPaciente dados) {
  if (dados.nome() != null && !dados.nome().trim().isEmpty()) {
   this.nome = dados.nome();
  }
  if (dados.email() != null && !dados.email().trim().isEmpty()) {
   this.email = dados.email();
  }
  if (dados.telefone() != null && !dados.telefone().trim().isEmpty()) {
   this.telefone = dados.telefone();
  }
  if (dados.endereco() != null && !dados.endereco().trim().isEmpty()) {
   this.endereco = dados.endereco();
  }
  if (dados.planoSaude() != null && !dados.planoSaude().trim().isEmpty()) {
   this.planoSaude = dados.planoSaude();
  }
  if (dados.numeroCarteirinha() != null && !dados.numeroCarteirinha().trim().isEmpty()) {
   this.numeroCarteirinha = dados.numeroCarteirinha();
  }
  if (dados.dataNascimento() != null) {
   this.dataNascimento = dados.dataNascimento();
  }
 }

 // Método de negócio para inativar
 public void inativar() {
  this.ativo = false;
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

 public String getTelefone() {
  return telefone;
 }

 public void setTelefone(String telefone) {
  this.telefone = telefone;
 }

 public String getCpf() {
  return cpf;
 }

 public void setCpf(String cpf) {
  this.cpf = cpf;
 }

 public LocalDate getDataNascimento() {
  return dataNascimento;
 }

 public void setDataNascimento(LocalDate dataNascimento) {
  this.dataNascimento = dataNascimento;
 }

 public String getEndereco() {
  return endereco;
 }

 public void setEndereco(String endereco) {
  this.endereco = endereco;
 }

 public String getPlanoSaude() {
  return planoSaude;
 }

 public void setPlanoSaude(String planoSaude) {
  this.planoSaude = planoSaude;
 }

 public String getNumeroCarteirinha() {
  return numeroCarteirinha;
 }

 public void setNumeroCarteirinha(String numeroCarteirinha) {
  this.numeroCarteirinha = numeroCarteirinha;
 }

 public Boolean getAtivo() {
  return ativo;
 }

 public void setAtivo(Boolean ativo) {
  this.ativo = ativo;
 }

 public LocalDateTime getDataCadastro() {
  return dataCadastro;
 }

 public void setDataCadastro(LocalDateTime dataCadastro) {
  this.dataCadastro = dataCadastro;
 }
}
