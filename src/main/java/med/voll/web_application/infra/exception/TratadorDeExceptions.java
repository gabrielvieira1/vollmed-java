package med.voll.web_application.infra.exception;

import java.util.NoSuchElementException;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authorization.AuthorizationDeniedException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import med.voll.web_application.domain.consulta.ConsultaInativaException;
import med.voll.web_application.domain.exception.RegraDeNegocioException;

/**
 * Tratador centralizado de exceções do sistema.
 * Mapeia exceções para páginas de erro apropriadas.
 */
@ControllerAdvice
public class TratadorDeExceptions {

    /**
     * Tratamento para AuthorizationDeniedException (Spring Security 6+)
     * Ocorre quando usuário não tem permissão (@PreAuthorize)
     */
    @ExceptionHandler(AuthorizationDeniedException.class)
    public String tratarErroAutorizacao(AuthorizationDeniedException e, HttpServletRequest request) {
        System.out.println("🚫 Acesso negado: " + e.getMessage());
        System.out.println("📍 Rota acessada: " + request.getRequestURI());
        System.out.println("👤 Usuário: " + request.getRemoteUser());
        return "erro/403";
    }

    /**
     * Tratamento para AccessDeniedException (Spring Security legacy)
     * Ocorre quando usuário não tem permissão de acesso
     */
    @ExceptionHandler(AccessDeniedException.class)
    public String tratarErroAcessoNegado(AccessDeniedException e, HttpServletRequest request) {
        System.out.println("🚫 Acesso negado (legacy): " + e.getMessage());
        System.out.println("📍 Rota acessada: " + request.getRequestURI());
        return "erro/403";
    }

    /**
     * Tratamento para recursos não encontrados
     */
    @ExceptionHandler(NoSuchElementException.class)
    public String tratarErro404(NoSuchElementException e) {
        System.out.println("🔍 Recurso não encontrado: " + e.getMessage());
        return "erro/404";
    }

    /**
     * Tratamento para exceções de regras de negócio
     * Exibe a mensagem de erro ao usuário
     */
    @ExceptionHandler(RegraDeNegocioException.class)
    public ModelAndView tratarErroNegocio(RegraDeNegocioException e, HttpServletRequest request) {
        System.out.println("⚠️ Regra de negócio violada: " + e.getMessage());
        System.out.println("📍 Rota: " + request.getRequestURI());

        ModelAndView modelAndView = new ModelAndView("erro/500");
        modelAndView.addObject("mensagemErro", e.getMessage());
        modelAndView.addObject("tipoErro", "Regra de Negócio");
        return modelAndView;
    }

    /**
     * Tratamento específico para consultas inativas.
     * Redireciona para a listagem com mensagem flash.
     */
    @ExceptionHandler(ConsultaInativaException.class)
    public String tratarErroConsultaInativa(ConsultaInativaException e, HttpServletRequest request,
            RedirectAttributes redirect) {
        System.out.println("⚠️ Consulta inativa acessada: " + e.getMessage());
        System.out.println("📍 Rota: " + request.getRequestURI());

        redirect.addFlashAttribute("erro", e.getMessage());
        return "redirect:/consultas";
    }

    /**
     * Tratamento genérico para erros inesperados
     */
    @ExceptionHandler(Exception.class)
    public ModelAndView tratarErro500(Exception e, HttpServletRequest request) {
        System.err.println("❌ Erro inesperado: " + e.getClass().getName());
        System.err.println("📍 Rota: " + request.getRequestURI());
        System.err.println("💬 Mensagem: " + e.getMessage());
        e.printStackTrace();

        ModelAndView modelAndView = new ModelAndView("erro/500");
        modelAndView.addObject("mensagemErro", "Ocorreu um erro inesperado no sistema");
        modelAndView.addObject("tipoErro", e.getClass().getSimpleName());
        return modelAndView;
    }
}
