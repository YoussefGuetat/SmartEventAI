package com.smarteventai.authservice.services;

import com.smarteventai.authservice.dtos.AuthentificationDto;

public interface AuthentificationService {
    AuthentificationDto registerUser(AuthentificationDto  authentificationDto);
    AuthentificationDto authenticate(AuthentificationDto  authentificationDto);
    String generateToken();
}
