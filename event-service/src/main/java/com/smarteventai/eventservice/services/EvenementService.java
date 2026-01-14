package com.smarteventai.eventservice.services;

import com.smarteventai.eventservice.dtos.EvenementDto;

import java.util.List;

public interface EvenementService {
    EvenementDto createEvenement(EvenementDto evenementDto);
    EvenementDto getEvenementById(Long evenementId) throws Exception;
    List<EvenementDto> getEvenements();
    void deleteEvenementById(Long evenementId) throws Exception;
    EvenementDto updateEvenement(EvenementDto evenementDto) throws Exception;
}
