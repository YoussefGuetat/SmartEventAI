package com.smarteventai.authservice.utils;

import com.smarteventai.authservice.dtos.AuthentificationDto;
import com.smarteventai.authservice.entities.Authentification;

public class Mapper {
    Authentification authentification;
    AuthentificationDto authentificationDto;

    public Mapper(){
        authentification = new Authentification();
        authentificationDto = new AuthentificationDto();
    }

    public AuthentificationDto map(Authentification authentification){
        authentificationDto.setIdAuthentification(authentification.getId());
        authentificationDto.setNomUtilisateur(authentification.getUsername());
        authentificationDto.setEmail(authentification.getEmail());
        authentificationDto.setMotDePasse(authentification.getPassword());
        authentificationDto.setRole(authentification.getRole());
        authentificationDto.setActive(authentification.isEnabled());
        return authentificationDto;
    }

    public Authentification map(AuthentificationDto authentificationDto){
        authentification.setId(authentificationDto.getIdAuthentification());
        authentification.setUsername(authentificationDto.getNomUtilisateur());
        authentification.setEmail(authentificationDto.getEmail());
        authentification.setPassword(authentificationDto.getMotDePasse());
        authentification.setRole(authentificationDto.getRole());
        authentification.setEnabled(authentificationDto.isActive());
        return authentification;
    }
}
