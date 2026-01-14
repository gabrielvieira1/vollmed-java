package med.voll.web_application.controller;

import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.validation.Valid;
import med.voll.web_application.domain.exception.RegraDeNegocioException;
import med.voll.web_application.domain.permissao.DadosCadastroGrupo;
import med.voll.web_application.domain.permissao.GrupoService;

@Controller
@RequestMapping("grupos")
@PreAuthorize("hasRole('ADMIN')") // Apenas ADMIN pode gerenciar grupos
public class GrupoController {

 private static final String PAGINA_LISTAGEM = "grupo/listagem-grupos";
 private static final String PAGINA_CADASTRO = "grupo/formulario-grupo";
 private static final String REDIRECT_LISTAGEM = "redirect:/grupos?sucesso";

 private final GrupoService service;

 public GrupoController(GrupoService service) {
  this.service = service;
 }

 @GetMapping
 public String carregarPaginaListagem(@PageableDefault Pageable paginacao, Model model) {
  var grupos = service.listar(paginacao);
  model.addAttribute("grupos", grupos);
  return PAGINA_LISTAGEM;
 }

 @GetMapping("formulario")
 public String carregarPaginaCadastro(Long id, Model model) {
  if (id != null) {
   model.addAttribute("dados", service.carregarPorId(id));
  } else {
   model.addAttribute("dados", new DadosCadastroGrupo());
  }

  // Carregar todas as permissões para checkboxes
  model.addAttribute("permissoes", service.listarTodasPermissoes());
  // Carregar recursos ordenados para agrupamento
  model.addAttribute("recursos", service.listarRecursosOrdenados());

  return PAGINA_CADASTRO;
 }

 @PostMapping
 public String processarFormulario(@Valid DadosCadastroGrupo dados,
   BindingResult result,
   Model model,
   RedirectAttributes redirect) {
  if (result.hasErrors()) {
   model.addAttribute("dados", dados);
   model.addAttribute("permissoes", service.listarTodasPermissoes());
   model.addAttribute("recursos", service.listarRecursosOrdenados());
   return PAGINA_CADASTRO;
  }

  try {
   service.cadastrar(dados);
   if (dados.getId() != null) {
    redirect.addFlashAttribute("mensagemSucesso", "Grupo atualizado com sucesso!");
   } else {
    redirect.addFlashAttribute("mensagemSucesso", "Grupo cadastrado com sucesso!");
   }
   return REDIRECT_LISTAGEM;
  } catch (RegraDeNegocioException e) {
   model.addAttribute("erro", e.getMessage());
   model.addAttribute("dados", dados);
   model.addAttribute("permissoes", service.listarTodasPermissoes());
   model.addAttribute("recursos", service.listarRecursosOrdenados());
   return PAGINA_CADASTRO;
  }
 }

 @DeleteMapping
 public String excluir(Long id, RedirectAttributes redirect) {
  try {
   service.excluir(id);
   redirect.addFlashAttribute("mensagemSucesso", "Grupo excluído com sucesso!");
  } catch (RegraDeNegocioException e) {
   redirect.addFlashAttribute("mensagemErro", e.getMessage());
  }
  return REDIRECT_LISTAGEM;
 }
}
