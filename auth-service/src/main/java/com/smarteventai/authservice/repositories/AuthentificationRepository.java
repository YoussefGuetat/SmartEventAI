package com.smarteventai.authservice.repositories;

import com.smarteventai.authservice.entities.Authentification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AuthentificationRepository extends JpaRepository<Authentification, Long> {
    Optional<Authentification> findByEmail(String email);
}
