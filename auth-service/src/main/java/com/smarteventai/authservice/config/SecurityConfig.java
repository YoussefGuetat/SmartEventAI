package com.smarteventai.authservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                // Pour une API REST, on désactive CSRF
                .csrf(csrf -> csrf.disable())
                // On ne veut pas de session côté serveur
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // 👉 ces endpoints sont accessibles sans être connecté
                        .requestMatchers(
                                "/authentification/register",
                                "/authentification/authenticate"
                        ).permitAll()
                        // 👉 pour l’instant, tout le reste est aussi libre
                        .anyRequest().permitAll()
                );

        return http.build();
    }
}
