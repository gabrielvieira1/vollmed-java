package med.voll.web_application.controller;

import jakarta.validation.Valid;
import med.voll.web_application.domain.usuario.DadosRegistroUsuario;
import med.voll.web_application.domain.usuario.UsuarioService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/registro")
public class RegistroController {

    private final UsuarioService usuarioService;

    public RegistroController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @GetMapping
    public String carregaPaginaRegistro(Model model) {
        model.addAttribute("dados", new DadosRegistroUsuario("", "", "", ""));
        return "autenticacao/registro";
    }

    @PostMapping
    public String registrarUsuario(@Valid DadosRegistroUsuario dados,
                                 BindingResult result,
                                 Model model,
                                 RedirectAttributes redirectAttributes) {

        if (result.hasErrors()) {
            model.addAttribute("dados", dados);
            return "autenticacao/registro";
        }

        try {
            usuarioService.registrarUsuario(dados);
            redirectAttributes.addFlashAttribute("mensagemSucesso",
                "Conta criada com sucesso! Faça login para acessar o sistema.");
            return "redirect:/login";

        } catch (IllegalArgumentException e) {
            model.addAttribute("dados", dados);
            model.addAttribute("erro", e.getMessage());
            return "autenticacao/registro";
        }
    }
}
