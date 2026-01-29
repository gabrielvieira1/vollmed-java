package med.voll.web_application.domain.medico;

public record DadosListagemMedico(Long id, String nome, String email, String crm, Especialidade especialidade) {

    public DadosListagemMedico(Medico medico) {
        this(medico.getId(), medico.getNome(), medico.getEmail(), medico.getCrm(), medico.getEspecialidade());
    }

    public DadosListagemMedico(Object[] resultado) {
        this(
                resultado[0] != null ? ((Number) resultado[0]).longValue() : null,
                resultado[1] != null ? resultado[1].toString() : null,
                resultado[2] != null ? resultado[2].toString() : null,
                resultado[3] != null ? resultado[3].toString() : null,
                resultado[4] != null ? parseEspecialidade(resultado[4].toString()) : null);
    }

    private static Especialidade parseEspecialidade(String valor) {
        try {
            return Especialidade.valueOf(valor.toUpperCase());
        } catch (Exception e) {
            return null;
        }
    }

}
