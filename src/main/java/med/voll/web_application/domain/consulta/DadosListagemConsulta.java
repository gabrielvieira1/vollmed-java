package med.voll.web_application.domain.consulta;

import java.time.LocalDateTime;

import med.voll.web_application.domain.medico.Especialidade;

public record DadosListagemConsulta(Long id, String medico, String paciente, LocalDateTime data,
        Especialidade especialidade) {

    public DadosListagemConsulta(Consulta consulta) {
        this(
                consulta.getId(),
                consulta.getMedico().getNome(),
                consulta.getPacienteRef() != null ? consulta.getPacienteRef().getNome() : "Paciente não vinculado",
                consulta.getData(),
                consulta.getMedico().getEspecialidade());
    }

}
