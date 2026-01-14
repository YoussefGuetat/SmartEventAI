package com.smarteventai.authservice.dtos;

import lombok.Data;

@Data
public class AuthentificationDto {
    private Long idAuthentification;
    private String nomUtilisateur;
    private String email;
    private String motDePasse;
    private String role;
    private boolean active;
}
