package med.voll.web_application.controller;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.validation.Valid;
import med.voll.web_application.domain.exception.RegraDeNegocioException;
import med.voll.web_application.domain.paciente.DadosCadastroPaciente;
import med.voll.web_application.domain.paciente.DadosListagemPaciente;
import med.voll.web_application.domain.paciente.PacienteService;

@Controller
@RequestMapping("pacientes")
public class PacienteController {

  private static final String PAGINA_LISTAGEM = "paciente/listagem-pacientes";
  private static final String PAGINA_CADASTRO = "paciente/formulario-paciente";
  private static final String REDIRECT_LISTAGEM = "redirect:/pacientes?sucesso";

  private final PacienteService service;

  public PacienteController(PacienteService service) {
    this.service = service;
  }

  @GetMapping
  public String carregarPaginaListagem(@PageableDefault Pageable paginacao, Model model) {
    var pacientesCadastrados = service.listar(paginacao);
    model.addAttribute("pacientes", pacientesCadastrados);
    return PAGINA_LISTAGEM;
  }

  @GetMapping("formulario")
  public String carregarPaginaCadastro(Long id, Model model) {
    if (id != null) {
      model.addAttribute("dados", service.carregarPorId(id));
    } else {
      model.addAttribute("dados", new DadosCadastroPaciente());
    }
    return PAGINA_CADASTRO;
  }

  @PostMapping
  public String processarFormulario(@Valid @ModelAttribute("dados") DadosCadastroPaciente dados,
      BindingResult result,
      Model model,
      RedirectAttributes redirect) {
    if (result.hasErrors()) {
      model.addAttribute("dados", dados);
      return PAGINA_CADASTRO;
    }

    try {
      if (dados.id() != null) {
        service.atualizar(dados);
        redirect.addFlashAttribute("mensagemSucesso", "Paciente atualizado com sucesso!");
      } else {
        service.cadastrar(dados);
        redirect.addFlashAttribute("mensagemSucesso", "Paciente cadastrado com sucesso!");
      }
      return REDIRECT_LISTAGEM;
    } catch (RegraDeNegocioException e) {
      model.addAttribute("erro", e.getMessage());
      model.addAttribute("dados", dados);
      return PAGINA_CADASTRO;
    }
  }

  @DeleteMapping
  public String excluir(Long id, RedirectAttributes redirect) {
    try {
      service.excluir(id);
      redirect.addFlashAttribute("mensagemSucesso", "Paciente excluído com sucesso!");
    } catch (RegraDeNegocioException e) {
      redirect.addFlashAttribute("mensagemErro", e.getMessage());
    }
    return REDIRECT_LISTAGEM;
  }

  @GetMapping("buscar")
  @ResponseBody
  public List<DadosListagemPaciente> buscarPacientesVulneravel(@RequestParam String nome) {
    return service.buscarPorNome(nome);
  }

  // Endpoint para buscar por plano de saúde
  @GetMapping("plano/{planoSaude}")
  @ResponseBody
  public List<DadosListagemPaciente> listarPacientesPorPlano(@PathVariable String planoSaude) {
    return service.buscarPorPlanoSaude(planoSaude);
  }
}
