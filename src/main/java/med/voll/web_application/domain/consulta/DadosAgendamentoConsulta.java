package med.voll.web_application.domain.consulta;

import java.time.LocalDateTime;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import med.voll.web_application.domain.medico.Especialidade;

public record DadosAgendamentoConsulta(

                Long id,
                Long idMedico,

                @NotNull(message = "Paciente é obrigatório") Long pacienteId,

                @NotNull @Future LocalDateTime data,

                Especialidade especialidade) {
}
