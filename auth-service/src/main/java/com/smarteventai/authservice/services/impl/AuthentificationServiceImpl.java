package com.smarteventai.authservice.services.impl;

import com.smarteventai.authservice.dtos.AuthentificationDto;
import com.smarteventai.authservice.entities.Authentification;
import com.smarteventai.authservice.repositories.AuthentificationRepository;
import com.smarteventai.authservice.services.AuthentificationService;
import com.smarteventai.authservice.utils.Mapper;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.Base64;

@Service
public class AuthentificationServiceImpl implements AuthentificationService {
    private final AuthentificationRepository authentificationRepository;
    private Mapper converter;
    private PasswordEncoder passwordEncoder;

    public AuthentificationServiceImpl(AuthentificationRepository authentificationRepository, PasswordEncoder passwordEncoder) {
        this.authentificationRepository = authentificationRepository;
        converter = new Mapper();
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public AuthentificationDto registerUser(AuthentificationDto authentificationDto) {
        Authentification authentification = this.converter.map(authentificationDto);
        authentification.setPassword(this.passwordEncoder.encode(authentificationDto.getMotDePasse()));
        authentification.setRole("user");
        authentification.setEnabled(true);

        authentificationRepository.save(authentification);
        AuthentificationDto reponse = this.converter.map(authentification);
        reponse.setMotDePasse(null);
        return reponse;
    }

    @Override
    public AuthentificationDto authenticate(AuthentificationDto authentificationDto) {
        Authentification authentification = authentificationRepository
                .findByEmail(authentificationDto.getEmail())
                .orElseThrow(()-> new RuntimeException("Email ou mot de passe invalide"));

        //String passwordHashed = this.passwordEncoder.encode(authentificationDto.getMotDePasse());
        if(!passwordEncoder.matches(authentificationDto.getMotDePasse(), authentification.getPassword())) {
            throw new RuntimeException("Email ou mot de passe invalide");
        }

        AuthentificationDto response = this.converter.map(authentification);
        response.setMotDePasse(null);
        return response;
    }

    @Override
    public String generateToken() {
       byte[] randomBytes = new byte[32]; // 256 bits
        SecureRandom secureRandom = new SecureRandom();
        secureRandom.nextBytes(randomBytes);

        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }
}
