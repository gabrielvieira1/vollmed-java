package med.voll.web_application.controller;

import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.validation.Valid;
import med.voll.web_application.domain.RegraDeNegocioException;
import med.voll.web_application.domain.relatorio.DadosCadastroRelatorio;
import med.voll.web_application.domain.relatorio.RelatorioService;

@Controller
@RequestMapping("relatorios")
public class RelatorioController {

  private static final String PAGINA_LISTAGEM = "relatorio/listagem-relatorios";
  private static final String PAGINA_CADASTRO = "relatorio/formulario-relatorio";
  private static final String REDIRECT_LISTAGEM = "redirect:/relatorios?sucesso";

  private final RelatorioService service;

  public RelatorioController(RelatorioService service) {
    this.service = service;
  }

  @GetMapping
  public String carregarPaginaListagem(@PageableDefault Pageable paginacao, Model model) {
    var relatorios = service.listar(paginacao);
    model.addAttribute("relatorios", relatorios);
    return PAGINA_LISTAGEM;
  }

  @GetMapping("formulario")
  public String carregarPaginaCadastro(Long id, Model model) {
    if (id != null) {
      model.addAttribute("dados", service.carregarPorId(id));
    } else {
      model.addAttribute("dados", new DadosCadastroRelatorio(
          null, null, null, "", "", "", "", "", "", ""));
    }

    // Carregar consultas e médicos para os dropdowns
    model.addAttribute("consultas", service.listarConsultasDisponiveis());
    model.addAttribute("medicos", service.listarMedicosAtivos());

    return PAGINA_CADASTRO;
  }

  @PostMapping
  public String cadastrar(@Valid @ModelAttribute("dados") DadosCadastroRelatorio dados,
      BindingResult result,
      Model model,
      RedirectAttributes redirect) {
    if (result.hasErrors()) {
      model.addAttribute("dados", dados);
      return PAGINA_CADASTRO;
    }

    try {
      service.cadastrar(dados);
      redirect.addFlashAttribute("mensagemSucesso", "Relatório criado com sucesso!");
      return REDIRECT_LISTAGEM;

    } catch (RegraDeNegocioException e) {
      model.addAttribute("erro", e.getMessage());
      model.addAttribute("dados", dados);
      return PAGINA_CADASTRO;
    }
  }

  @PostMapping("atualizar/{id}")
  public String atualizar(@PathVariable Long id,
      @Valid @ModelAttribute("dados") DadosCadastroRelatorio dados,
      BindingResult result,
      Model model,
      RedirectAttributes redirect) {
    if (result.hasErrors()) {
      model.addAttribute("dados", dados);
      return PAGINA_CADASTRO;
    }

    try {
      service.atualizar(id, dados);
      redirect.addFlashAttribute("mensagemSucesso", "Relatório atualizado com sucesso!");
      return REDIRECT_LISTAGEM;

    } catch (RegraDeNegocioException e) {
      model.addAttribute("erro", e.getMessage());
      model.addAttribute("dados", dados);
      return PAGINA_CADASTRO;
    }
  }

  @DeleteMapping
  public String excluir(Long id) {
    service.excluir(id);
    return REDIRECT_LISTAGEM;
  }

  /**
   * ENDPOINT PARA EXPORTAR RELATÓRIO EM PDF
   */
  @GetMapping("/{id}/exportar-pdf")
  public ResponseEntity<byte[]> exportarPDF(@PathVariable Long id,
      @RequestParam(defaultValue = "false") boolean criptografado) {

    try {
      byte[] pdfBytes = service.exportarRelatorioPDF(id, criptografado);

      String filename = "relatorio_" + id + (criptografado ? "_criptografado" : "") + ".pdf";

      return ResponseEntity.ok()
          .header("Content-Disposition", "attachment; filename=\"" + filename + "\"")
          .header("Content-Type", "application/pdf")
          .header("Cache-Control", "no-cache, no-store, must-revalidate")
          .header("Pragma", "no-cache")
          .header("Expires", "0")
          .body(pdfBytes);

    } catch (Exception e) {
      return ResponseEntity.internalServerError().build();
    }
  }
}
