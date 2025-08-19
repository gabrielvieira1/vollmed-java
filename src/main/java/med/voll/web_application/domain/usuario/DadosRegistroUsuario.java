package med.voll.web_application.domain.usuario;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record DadosRegistroUsuario(
        @NotBlank(message = "Nome é obrigatório")
        @Size(min = 2, max = 100, message = "Nome deve ter entre 2 e 100 caracteres")
        String nome,

        @NotBlank(message = "Email é obrigatório")
        @Email(message = "Email deve ter formato válido")
        String email,

        @NotBlank(message = "Senha é obrigatória")
        @Size(min = 6, max = 20, message = "Senha deve ter entre 6 e 20 caracteres")
        String senha,

        @NotBlank(message = "Confirmação de senha é obrigatória")
        String confirmarSenha
) {
    public boolean senhasConferem() {
        return senha != null && senha.equals(confirmarSenha);
    }
}
