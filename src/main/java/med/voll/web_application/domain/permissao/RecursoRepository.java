package med.voll.web_application.domain.permissao;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface RecursoRepository extends JpaRepository<Recurso, Long> {

 Optional<Recurso> findByNome(String nome);

 List<Recurso> findByAtivoTrueOrderByOrdem();

 @Query("SELECT r FROM Recurso r WHERE r.ativo = true ORDER BY r.ordem")
 List<Recurso> findAllAtivos();
}
