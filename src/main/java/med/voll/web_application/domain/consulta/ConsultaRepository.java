package med.voll.web_application.domain.consulta;

import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ConsultaRepository extends JpaRepository<Consulta, Long> {

    Page<Consulta> findAllByAtivoTrueOrderByData(Pageable paginacao);

    Page<Consulta> findByPacienteRefIdAndAtivoTrueOrderByData(Long pacienteId, Pageable paginacao);

    Optional<Consulta> findByIdAndAtivoTrue(Long id);

}
