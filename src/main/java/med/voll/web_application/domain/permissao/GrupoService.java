package med.voll.web_application.domain.permissao;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import med.voll.web_application.domain.exception.RegraDeNegocioException;
import med.voll.web_application.domain.usuario.UsuarioRepository;

@Service
public class GrupoService {

 private final GrupoRepository grupoRepository;
 private final PermissaoRepository permissaoRepository;
 private final UsuarioRepository usuarioRepository;

 public GrupoService(GrupoRepository grupoRepository,
   PermissaoRepository permissaoRepository,
   UsuarioRepository usuarioRepository) {
  this.grupoRepository = grupoRepository;
  this.permissaoRepository = permissaoRepository;
  this.usuarioRepository = usuarioRepository;
 }

 public Page<DadosListagemGrupo> listar(Pageable paginacao) {
  Page<Grupo> grupos = grupoRepository.findAll(paginacao);

  List<DadosListagemGrupo> dadosListagem = grupos.getContent().stream()
    .map(grupo -> {
     int qtdUsuarios = usuarioRepository.countByGruposId(grupo.getId());
     return new DadosListagemGrupo(grupo, qtdUsuarios);
    })
    .toList();

  return new PageImpl<>(dadosListagem, paginacao, grupos.getTotalElements());
 }

 public List<Grupo> listarAtivos() {
  return grupoRepository.findByAtivoTrueOrderByNome();
 }

 public DadosCadastroGrupo carregarPorId(Long id) {
  Grupo grupo = grupoRepository.findByIdWithPermissoes(id)
    .orElseThrow(() -> new RegraDeNegocioException("Grupo não encontrado"));
  return new DadosCadastroGrupo(grupo);
 }

 @Transactional
 public void cadastrar(DadosCadastroGrupo dados) {
  if (dados.getId() == null) {
   // Validar nome único apenas para novo grupo
   if (grupoRepository.existsByNome(dados.getNome())) {
    throw new RegraDeNegocioException("Já existe um grupo com este nome");
   }

   // Criar novo grupo
   Grupo grupo = new Grupo(dados.getNome(), dados.getDescricao(), false);
   grupo.setAtivo(dados.getAtivo());

   // Adicionar permissões
   Set<Permissao> permissoes = dados.getPermissoesIds().stream()
     .map(id -> permissaoRepository.findById(id)
       .orElseThrow(() -> new RegraDeNegocioException("Permissão não encontrada")))
     .collect(Collectors.toSet());

   grupo.setPermissoes(permissoes);
   grupoRepository.save(grupo);

  } else {
   // Atualizar grupo existente
   Grupo grupo = grupoRepository.findByIdWithPermissoes(dados.getId())
     .orElseThrow(() -> new RegraDeNegocioException("Grupo não encontrado"));

   // Não permite editar grupos padrão do sistema
   if (grupo.getPadrao()) {
    throw new RegraDeNegocioException("Grupos padrão do sistema não podem ser editados");
   }

   // Validar nome único apenas se foi alterado
   if (!grupo.getNome().equals(dados.getNome()) && grupoRepository.existsByNome(dados.getNome())) {
    throw new RegraDeNegocioException("Já existe um grupo com este nome");
   }

   grupo.setNome(dados.getNome());
   grupo.setDescricao(dados.getDescricao());
   grupo.setAtivo(dados.getAtivo());

   // Atualizar permissões
   grupo.getPermissoes().clear();
   Set<Permissao> permissoes = dados.getPermissoesIds().stream()
     .map(id -> permissaoRepository.findById(id)
       .orElseThrow(() -> new RegraDeNegocioException("Permissão não encontrada")))
     .collect(Collectors.toSet());

   grupo.setPermissoes(permissoes);
   grupoRepository.save(grupo);
  }
 }

 @Transactional
 public void excluir(Long id) {
  Grupo grupo = grupoRepository.findById(id)
    .orElseThrow(() -> new RegraDeNegocioException("Grupo não encontrado"));

  if (grupo.getPadrao()) {
   throw new RegraDeNegocioException("Grupos padrão do sistema não podem ser excluídos");
  }

  int qtdUsuarios = usuarioRepository.countByGruposId(id);
  if (qtdUsuarios > 0) {
   throw new RegraDeNegocioException(
     "Não é possível excluir este grupo pois existem " + qtdUsuarios + " usuário(s) associado(s)");
  }

  grupoRepository.deleteById(id);
 }

 public List<Permissao> listarTodasPermissoes() {
  return permissaoRepository.findAllWithRecurso();
 }

 public List<Recurso> listarRecursosOrdenados() {
  return permissaoRepository.findAllWithRecurso()
    .stream()
    .map(Permissao::getRecurso)
    .distinct()
    .sorted((r1, r2) -> r1.getOrdem().compareTo(r2.getOrdem()))
    .toList();
 }
}
