package med.voll.web_application.infra.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true) // Habilita @PreAuthorize
public class ConfiguracoesSeguranca {
  // @Bean
  // public UserDetailsService dadosUsuariosCadastrados(){
  // UserDetails usuario1 = User.builder()
  // .username("joao@email.com")
  // .password("{noop}joao123")
  // .build();
  // UserDetails usuario2 = User.builder()
  // .username("maria@email.com")
  // .password("{noop}maria123")
  // .build();
  // UserDetails usuario3 = User.builder()
  // .username("iasmin@email.com")
  // .password("{noop}iasmin123")
  // .build();
  // return new InMemoryUserDetailsManager(usuario1, usuario2, usuario3);
  // }

  @Bean
  public SecurityFilterChain filtrosSeguranca(HttpSecurity http) throws Exception {
    return http
        .authorizeHttpRequests(req -> {
          req.requestMatchers("/css/**", "/js/**", "/assets/**", "/", "/index", "/home",
              "/registro", "/logout")
              .permitAll();
          req.requestMatchers("/relatorios/*/exportar-pdf").authenticated();
          req.anyRequest().authenticated();
        })
        .formLogin(form -> form
            .loginPage("/login")
            .defaultSuccessUrl("/")
            .permitAll())
        .logout(logout -> logout
            .logoutUrl("/perform-logout")
            .logoutSuccessUrl("/login?logout")
            .addLogoutHandler(new SecurityContextLogoutHandler())
            .permitAll())
        .rememberMe(remember -> remember
            .key("vollmed")
            .alwaysRemember(true))
        .csrf(csrf -> csrf.disable())
        .build();
  }

  @Bean
  public PasswordEncoder codificadorSenha() {
    return new BCryptPasswordEncoder();
  }
}
