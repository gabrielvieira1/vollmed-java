package med.voll.web_application.domain.usuario;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    @Query("SELECT u FROM Usuario u LEFT JOIN FETCH u.grupos WHERE LOWER(u.email) = LOWER(:email)")
    Optional<Usuario> findByEmailIgnoreCase(@Param("email") String email);

    boolean existsByEmailIgnoreCase(String email);

    Page<Usuario> findAll(Pageable pageable);

    List<Usuario> findByPerfil(Perfil perfil);

    @Query("SELECT COUNT(u) > 0 FROM Usuario u WHERE LOWER(u.email) = LOWER(:email) AND (:id IS NULL OR u.id != :id)")
    boolean existeUsuarioComEmail(@Param("email") String email, @Param("id") Long id);

    @Query("SELECT COUNT(u) FROM Usuario u JOIN u.grupos g WHERE g.id = :grupoId")
    int countByGruposId(@Param("grupoId") Long grupoId);

    @Query("SELECT u FROM Usuario u LEFT JOIN FETCH u.grupos WHERE u.id = :id")
    Optional<Usuario> findByIdWithGrupos(@Param("id") Long id);
}
