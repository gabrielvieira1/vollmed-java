package med.voll.web_application.domain.consulta;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import med.voll.web_application.domain.medico.Medico;

@Entity
@Table(name = "consultas")
public class Consulta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "paciente_id")
    private med.voll.web_application.domain.paciente.Paciente pacienteRef;

    @ManyToOne(fetch = FetchType.LAZY)
    private Medico medico;

    private LocalDateTime data;

    @Deprecated
    public Consulta() {
    }

    public Consulta(Medico medico, med.voll.web_application.domain.paciente.Paciente paciente,
            DadosAgendamentoConsulta dados) {
        modificarDados(medico, paciente, dados);
    }

    public void modificarDados(Medico medico, med.voll.web_application.domain.paciente.Paciente paciente,
            DadosAgendamentoConsulta dados) {
        this.medico = medico;
        this.pacienteRef = paciente;
        this.data = dados.data();
    }

    public Long getId() {
        return id;
    }

    public Medico getMedico() {
        return medico;
    }

    public LocalDateTime getData() {
        return data;
    }

    public med.voll.web_application.domain.paciente.Paciente getPacienteRef() {
        return pacienteRef;
    }

}
