package com.smarteventai.authservice.controllers;

import com.smarteventai.authservice.dtos.AuthentificationDto;
import com.smarteventai.authservice.services.impl.AuthentificationServiceImpl;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/authentification")
public class AuthentificationController {

    private final AuthentificationServiceImpl authService;

    public AuthentificationController(AuthentificationServiceImpl authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public AuthentificationDto register(@RequestBody AuthentificationDto authentificationDto) {
        return this.authService.registerUser(authentificationDto);
    }

    @PostMapping("/login")
    public AuthentificationDto login(@RequestBody AuthentificationDto authentificationDto) {
        return this.authService.authenticate(authentificationDto);
    }

    @PostMapping("/generateToken")
    public String generateToken() {
        return this.authService.generateToken();
    }
}
