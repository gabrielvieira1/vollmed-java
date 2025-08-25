package med.voll.web_application.domain.paciente;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface PacienteRepository extends JpaRepository<Paciente, Long> {

 // Busca paginada de pacientes ativos
 Page<Paciente> findByAtivoTrue(Pageable pageable);

 // Busca paciente por CPF
 Optional<Paciente> findByCpfAndAtivoTrue(String cpf);

 // Verifica se já existe paciente cadastrado com CPF
 @Query("SELECT COUNT(p) > 0 FROM Paciente p WHERE p.cpf = :cpf AND (:id IS NULL OR p.id != :id)")
 boolean existePacienteComCpf(@Param("cpf") String cpf, @Param("id") Long id);

 // Verifica se já existe paciente cadastrado com email
 @Query("SELECT COUNT(p) > 0 FROM Paciente p WHERE p.email = :email AND (:id IS NULL OR p.id != :id)")
 boolean existePacienteComEmail(@Param("email") String email, @Param("id") Long id);

 // Busca pacientes por plano de saúde
 @Query("SELECT p FROM Paciente p WHERE p.planoSaude = :planoSaude AND p.ativo = true ORDER BY p.nome")
 List<Paciente> findByPlanoSaudeAndAtivoTrue(@Param("planoSaude") String planoSaude);

 // ⚠️ MÉTODO VULNERÁVEL - NÃO USE EM PRODUÇÃO
 // Este método será usado para demonstrar SQL Injection via procedure
 // A procedure search_patient_vulnerable contém vulnerabilidade intencional
 @Query(value = "CALL search_patient_vulnerable(:nome)", nativeQuery = true)
 List<Object[]> buscarPacientePorNomeVulneravel(@Param("nome") String nome);

 // ✅ MÉTODO SEGURO (para comparação)
 @Query(value = "CALL search_patient_secure(:nome)", nativeQuery = true)
 List<Object[]> buscarPacientePorNomeSeguro(@Param("nome") String nome);

 // Busca segura usando JPQL
 @Query("SELECT p FROM Paciente p WHERE LOWER(p.nome) LIKE LOWER(CONCAT('%', :nome, '%')) AND p.ativo = true ORDER BY p.nome")
 List<Paciente> findByNomeContainingIgnoreCaseAndAtivoTrue(@Param("nome") String nome);
}
