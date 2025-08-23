package med.voll.web_application.domain.relatorio;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface RelatorioRepository extends JpaRepository<Relatorio, Long> {

 /**
  * CONSULTA VULNERÁVEL - Para fins educacionais
  * 
  * Esta query permite buscar relatórios por médico ID sem validação adequada
  * de autorização, podendo expor dados de outros médicos.
  */
 @Query("SELECT r FROM Relatorio r WHERE r.medico.id = :medicoId")
 List<Relatorio> findByMedicoId(@Param("medicoId") Long medicoId);

 /**
  * CONSULTA VULNERÁVEL - Para fins educacionais
  * 
  * Busca relatórios por período sem controle de acesso adequado
  */
 @Query("SELECT r FROM Relatorio r WHERE r.dataGeracao BETWEEN :dataInicio AND :dataFim")
 List<Relatorio> findByPeriodo(@Param("dataInicio") LocalDateTime dataInicio,
   @Param("dataFim") LocalDateTime dataFim);

 Page<Relatorio> findByMedicoId(Long medicoId, Pageable pageable);

 /**
  * CONSULTA VULNERÁVEL - Para fins educacionais
  * 
  * Busca por CPF sem validação adequada - pode expor dados sensíveis
  */
 @Query("SELECT r FROM Relatorio r WHERE r.cpfPaciente = :cpf")
 List<Relatorio> findByCpfPaciente(@Param("cpf") String cpf);
}
