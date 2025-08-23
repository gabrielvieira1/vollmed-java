package med.voll.web_application.domain.relatorio;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * DTO para cadastro de relatórios - VULNERÁVEL para fins educacionais
 * 
 * Este DTO não possui validações adequadas para dados sensíveis de saúde
 */
public record DadosCadastroRelatorio(
    Long id,

    @NotNull Long consultaId,

    @NotNull Long medicoId,

    @NotBlank String diagnostico,

    String procedimento,

    String historicoFamiliar,

    String medicacao,

    String observacoesMedicas,

    @NotBlank String numeroSUS,

    @NotBlank String cpfPaciente) {

  /**
   * MÉTODO VULNERÁVEL - Para fins educacionais
   * 
   * Este método expõe dados sensíveis em logs através do toString()
   */
  @Override
  public String toString() {
    return "DadosCadastroRelatorio{" +
        "id=" + id +
        ", consultaId=" + consultaId +
        ", medicoId=" + medicoId +
        ", diagnostico='" + diagnostico + '\'' +
        ", procedimento='" + procedimento + '\'' +
        ", historicoFamiliar='" + historicoFamiliar + '\'' +
        ", medicacao='" + medicacao + '\'' +
        ", observacoesMedicas='" + observacoesMedicas + '\'' +
        ", numeroSUS='" + numeroSUS + '\'' +
        ", cpfPaciente='" + cpfPaciente + '\'' +
        '}';
  }
}
