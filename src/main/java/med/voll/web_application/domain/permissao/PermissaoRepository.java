package med.voll.web_application.domain.permissao;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface PermissaoRepository extends JpaRepository<Permissao, Long> {

 List<Permissao> findByRecursoId(Long recursoId);

 @Query("SELECT p FROM Permissao p JOIN FETCH p.recurso ORDER BY p.recurso.ordem, p.acao")
 List<Permissao> findAllWithRecurso();

 @Query("SELECT p FROM Permissao p WHERE p.recurso.nome = :recursoNome AND p.acao = :acao")
 Permissao findByRecursoNomeAndAcao(String recursoNome, String acao);
}
