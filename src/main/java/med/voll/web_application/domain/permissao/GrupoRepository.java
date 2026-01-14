package med.voll.web_application.domain.permissao;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface GrupoRepository extends JpaRepository<Grupo, Long> {

 Optional<Grupo> findByNome(String nome);

 List<Grupo> findByAtivoTrueOrderByNome();

 @Query("SELECT g FROM Grupo g LEFT JOIN FETCH g.permissoes WHERE g.id = :id")
 Optional<Grupo> findByIdWithPermissoes(Long id);

 @Query("SELECT g FROM Grupo g LEFT JOIN FETCH g.permissoes WHERE g.ativo = true ORDER BY g.nome")
 List<Grupo> findAllActivosWithPermissoes();

 boolean existsByNome(String nome);
}
