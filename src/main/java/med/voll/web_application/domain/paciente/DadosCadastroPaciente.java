package med.voll.web_application.domain.paciente;

import java.time.LocalDate;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record DadosCadastroPaciente(
  Long id,

  @NotBlank(message = "Nome é obrigatório") @Size(min = 2, max = 255, message = "Nome deve ter entre 2 e 255 caracteres") String nome,

  @NotBlank(message = "Email é obrigatório") @Email(message = "Email deve ser válido") @Size(max = 255, message = "Email deve ter no máximo 255 caracteres") String email,

  @NotBlank(message = "Telefone é obrigatório") @Pattern(regexp = "\\d{10,11}", message = "Telefone deve conter 10 ou 11 dígitos") String telefone,

  @NotBlank(message = "CPF é obrigatório") @Pattern(regexp = "\\d{11}", message = "CPF deve conter 11 dígitos") String cpf,

  @NotNull(message = "Data de nascimento é obrigatória") @Past(message = "Data de nascimento deve ser no passado") LocalDate dataNascimento,

  @Size(max = 500, message = "Endereço deve ter no máximo 500 caracteres") String endereco,

  @Size(max = 100, message = "Plano de saúde deve ter no máximo 100 caracteres") String planoSaude,

  @Size(max = 50, message = "Número da carteirinha deve ter no máximo 50 caracteres") String numeroCarteirinha) {
 // Construtor para criar DTO vazio (formulário novo)
 public DadosCadastroPaciente() {
  this(null, "", "", "", "", null, "", "", "");
 }

 // Construtor a partir da entidade (para edição)
 public DadosCadastroPaciente(Paciente paciente) {
  this(
    paciente.getId(),
    paciente.getNome(),
    paciente.getEmail(),
    paciente.getTelefone(),
    paciente.getCpf(),
    paciente.getDataNascimento(),
    paciente.getEndereco(),
    paciente.getPlanoSaude(),
    paciente.getNumeroCarteirinha());
 }
}
