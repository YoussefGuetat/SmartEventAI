package com.smarteventai.eventservice.dtos;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class EvenementDto {
    private Long idEvenement;
    private Long organizerId;
    private String titleEvenement;
    private String descriptionEvenement;
    private LocalDateTime dateEvenement;
    private String location;
    private String statusEvenement;
    private String agenda;
}
