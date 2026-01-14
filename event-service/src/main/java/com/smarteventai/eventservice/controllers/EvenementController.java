package com.smarteventai.eventservice.controllers;

import com.smarteventai.eventservice.dtos.EvenementDto;
import com.smarteventai.eventservice.services.impl.EvenementServiceImpl;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/evenement")
public class EvenementController {
    private final EvenementServiceImpl evenementService;

    public EvenementController(EvenementServiceImpl evenementService) {
        this.evenementService = evenementService;
    }

    @PostMapping("/saveEvenement")
    public EvenementDto saveEvenement(@RequestBody EvenementDto evenementDto){
        return this.evenementService.createEvenement(evenementDto);
    }

    @GetMapping("/getEvenementById/{id}")
    public EvenementDto getEvenementById(@PathVariable Long id) throws Exception {
        return this.evenementService.getEvenementById(id);
    }

    @GetMapping("/getAllEvents")
    public List<EvenementDto> getAllEvenements(){
        return this.evenementService.getEvenements();
    }

    @DeleteMapping("/deleteEvenementByID/{id}")
    public void deleteEvenementByID(@PathVariable Long id)  {
        this.evenementService.deleteEvenementById(id);
    }

    @PutMapping("/updateEvenement")
    public EvenementDto updateEvenement(@RequestBody EvenementDto evenementDto) throws Exception {
        return this.evenementService.updateEvenement(evenementDto);
    }
}
