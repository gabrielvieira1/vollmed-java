package med.voll.web_application.domain.relatorio;

import jakarta.persistence.*;
import med.voll.web_application.domain.consulta.Consulta;
import med.voll.web_application.domain.medico.Medico;

import java.time.LocalDateTime;

/**
 * ENTIDADE VULNERÁVEL - Para fins educacionais
 * 
 * Esta entidade armazena dados sensíveis de saúde que serão criptografados
 * de forma insegura para demonstração de vulnerabilidades.
 */
@Entity
@Table(name = "relatorios")
public class Relatorio {

 @Id
 @GeneratedValue(strategy = GenerationType.IDENTITY)
 private Long id;

 @ManyToOne(fetch = FetchType.LAZY)
 @JoinColumn(name = "consulta_id")
 private Consulta consulta;

 @ManyToOne(fetch = FetchType.LAZY)
 @JoinColumn(name = "medico_id")
 private Medico medico;

 @Column(columnDefinition = "TEXT")
 private String diagnostico;

 @Column(columnDefinition = "TEXT")
 private String procedimento;

 @Column(name = "historico_familiar", columnDefinition = "TEXT")
 private String historicoFamiliar;

 @Column(columnDefinition = "TEXT")
 private String medicacao;

 @Column(name = "observacoes_medicas", columnDefinition = "TEXT")
 private String observacoesMedicas;

 @Column(name = "dados_criptografados", columnDefinition = "LONGTEXT")
 private String dadosCriptografados;

 @Column(name = "data_geracao")
 private LocalDateTime dataGeracao;

 @Column(name = "numero_sus")
 private String numeroSUS;

 @Column(name = "cpf_paciente")
 private String cpfPaciente;

 // Construtores
 public Relatorio() {
  this.dataGeracao = LocalDateTime.now();
 }

 public Relatorio(Consulta consulta, Medico medico, String diagnostico,
   String procedimento, String historicoFamiliar, String medicacao,
   String observacoesMedicas, String numeroSUS, String cpfPaciente) {
  this();
  this.consulta = consulta;
  this.medico = medico;
  this.diagnostico = diagnostico;
  this.procedimento = procedimento;
  this.historicoFamiliar = historicoFamiliar;
  this.medicacao = medicacao;
  this.observacoesMedicas = observacoesMedicas;
  this.numeroSUS = numeroSUS;
  this.cpfPaciente = cpfPaciente;
 }

 // Getters e Setters
 public Long getId() {
  return id;
 }

 public void setId(Long id) {
  this.id = id;
 }

 public Consulta getConsulta() {
  return consulta;
 }

 public void setConsulta(Consulta consulta) {
  this.consulta = consulta;
 }

 public Medico getMedico() {
  return medico;
 }

 public void setMedico(Medico medico) {
  this.medico = medico;
 }

 public String getDiagnostico() {
  return diagnostico;
 }

 public void setDiagnostico(String diagnostico) {
  this.diagnostico = diagnostico;
 }

 public String getProcedimento() {
  return procedimento;
 }

 public void setProcedimento(String procedimento) {
  this.procedimento = procedimento;
 }

 public String getHistoricoFamiliar() {
  return historicoFamiliar;
 }

 public void setHistoricoFamiliar(String historicoFamiliar) {
  this.historicoFamiliar = historicoFamiliar;
 }

 public String getMedicacao() {
  return medicacao;
 }

 public void setMedicacao(String medicacao) {
  this.medicacao = medicacao;
 }

 public String getObservacoesMedicas() {
  return observacoesMedicas;
 }

 public void setObservacoesMedicas(String observacoesMedicas) {
  this.observacoesMedicas = observacoesMedicas;
 }

 public String getDadosCriptografados() {
  return dadosCriptografados;
 }

 public void setDadosCriptografados(String dadosCriptografados) {
  this.dadosCriptografados = dadosCriptografados;
 }

 public LocalDateTime getDataGeracao() {
  return dataGeracao;
 }

 public void setDataGeracao(LocalDateTime dataGeracao) {
  this.dataGeracao = dataGeracao;
 }

 public String getNumeroSUS() {
  return numeroSUS;
 }

 public void setNumeroSUS(String numeroSUS) {
  this.numeroSUS = numeroSUS;
 }

 public String getCpfPaciente() {
  return cpfPaciente;
 }

 public void setCpfPaciente(String cpfPaciente) {
  this.cpfPaciente = cpfPaciente;
 }
}
