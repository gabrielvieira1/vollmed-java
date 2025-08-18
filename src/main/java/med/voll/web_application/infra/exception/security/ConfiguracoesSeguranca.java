package med.voll.web_application.infra.exception.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;

@Configuration
@EnableWebSecurity
public class ConfiguracoesSeguranca {
//    @Bean
//    public UserDetailsService dadosUsuariosCadastrados(){
//        UserDetails usuario1 = User.builder()
//                .username("joao@email.com")
//                .password("{noop}joao123")
//                .build();
//        UserDetails usuario2 = User.builder()
//                .username("maria@email.com")
//                .password("{noop}maria123")
//                .build();
//        UserDetails usuario3 = User.builder()
//                .username("iasmin@email.com")
//                .password("{noop}iasmin123")
//                .build();
//        return new InMemoryUserDetailsManager(usuario1, usuario2, usuario3);
//    }

    @Bean
    public SecurityFilterChain filtrosSeguranca(HttpSecurity http) throws Exception {
        return http
            .authorizeHttpRequests(req -> {
                        req.requestMatchers("/css/**", "/js/**", "/assets/**", "/", "/index", "/home").permitAll();
                        req.anyRequest().authenticated();
                    })
            .formLogin(form -> form.loginPage("/login")
                    .defaultSuccessUrl("/")
                    .permitAll())
            .logout(logout -> logout
                    .logoutSuccessUrl("/login?logout")
                    .addLogoutHandler(new SecurityContextLogoutHandler())
                    .permitAll())
                .rememberMe(remember -> remember.key("vollmed")
                        .alwaysRemember(true))
                        //.tokenValiditySeconds(60 * 60 * 24 * 30)) // 30 dias
                .csrf(Customizer.withDefaults())
            .build();
    }

    @Bean
    public PasswordEncoder codificadorSenha(){
        return new BCryptPasswordEncoder();
    }
}
