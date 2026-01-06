package med.voll.web_application.controller;

import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.validation.Valid;
import med.voll.web_application.domain.exception.RegraDeNegocioException;
import med.voll.web_application.domain.usuario.DadosCadastroUsuario;
import med.voll.web_application.domain.usuario.Perfil;
import med.voll.web_application.domain.usuario.UsuarioService;

@Controller
@RequestMapping("usuarios")
@PreAuthorize("hasRole('ADMIN')") // Apenas ADMIN pode acessar
public class UsuarioController {

 private static final String PAGINA_LISTAGEM = "usuario/listagem-usuarios";
 private static final String PAGINA_CADASTRO = "usuario/formulario-usuario";
 private static final String REDIRECT_LISTAGEM = "redirect:/usuarios?sucesso";

 private final UsuarioService service;

 public UsuarioController(UsuarioService service) {
  this.service = service;
 }

 @ModelAttribute("perfis")
 public Perfil[] perfis() {
  return Perfil.values();
 }

 @GetMapping
 public String carregarPaginaListagem(@PageableDefault Pageable paginacao, Model model) {
  var usuariosCadastrados = service.listar(paginacao);
  model.addAttribute("usuarios", usuariosCadastrados);
  return PAGINA_LISTAGEM;
 }

 @GetMapping("formulario")
 public String carregarPaginaCadastro(Long id, Model model) {
  if (id != null) {
   model.addAttribute("dados", service.carregarPorId(id));
  } else {
   model.addAttribute("dados", new DadosCadastroUsuario());
  }
  return PAGINA_CADASTRO;
 }

 @PostMapping
 public String processarFormulario(@Valid DadosCadastroUsuario dados,
   BindingResult result,
   Model model,
   RedirectAttributes redirect) {
  System.out.println("\n=== CONTROLLER: Requisição POST recebida ===");
  System.out.println("Dados: " + dados);
  System.out.println("Tem erros? " + result.hasErrors());

  if (result.hasErrors()) {
   System.out.println("❌ CONTROLLER: Erros de validação:");
   result.getAllErrors().forEach(error -> System.out.println("  - " + error));
   model.addAttribute("dados", dados);
   return PAGINA_CADASTRO;
  }

  try {
   System.out.println("✅ CONTROLLER: Chamando service.cadastrar()");
   service.cadastrar(dados);
   if (dados.getId() != null) {
    redirect.addFlashAttribute("mensagemSucesso", "Usuário atualizado com sucesso!");
   } else {
    redirect.addFlashAttribute("mensagemSucesso", "Usuário cadastrado com sucesso!");
   }
   System.out.println("✅ CONTROLLER: Redirecionando para listagem");
   return REDIRECT_LISTAGEM;
  } catch (RegraDeNegocioException e) {
   System.out.println("❌ CONTROLLER: Erro de negócio: " + e.getMessage());
   model.addAttribute("erro", e.getMessage());
   model.addAttribute("dados", dados);
   return PAGINA_CADASTRO;
  }
 }

 @DeleteMapping
 public String excluir(Long id, RedirectAttributes redirect) {
  try {
   service.excluir(id);
   redirect.addFlashAttribute("mensagemSucesso", "Usuário excluído com sucesso!");
  } catch (RegraDeNegocioException e) {
   redirect.addFlashAttribute("mensagemErro", e.getMessage());
  }
  return REDIRECT_LISTAGEM;
 }
}
