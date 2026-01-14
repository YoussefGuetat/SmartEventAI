package com.smarteventai.eventservice.services.impl;

import com.smarteventai.eventservice.dtos.EvenementDto;
import com.smarteventai.eventservice.entities.Evenement;
import com.smarteventai.eventservice.repositories.EvenementRepository;
import com.smarteventai.eventservice.services.EvenementService;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class EvenementServiceImpl implements EvenementService {
    private final EvenementRepository evenementRepository;
    private ModelMapper modelMapper;
    public EvenementServiceImpl(EvenementRepository evenementRepository) {
        this.evenementRepository = evenementRepository;
        this.modelMapper = new ModelMapper();
    }

    @Override
    public EvenementDto createEvenement(EvenementDto evenementDto) {
        Evenement evenement = this.modelMapper.map(evenementDto, Evenement.class);
        evenement.setId(evenementDto.getIdEvenement());
        evenement = this.evenementRepository.save(evenement);
        return this.modelMapper.map(evenement, EvenementDto.class);
    }

    @Override
    public EvenementDto getEvenementById(Long evenementId) throws Exception {
        Evenement evenement = this.evenementRepository.findById(evenementId).orElseThrow(() -> new Exception("Evenement not found"));
        return this.modelMapper.map(evenement, EvenementDto.class);
    }

    @Override
    public List<EvenementDto> getEvenements() {
        List<Evenement> evenements = this.evenementRepository.findAll();
        List<EvenementDto> evenementDtos = new ArrayList<>();
        for (Evenement evenement : evenements) {
            evenementDtos.add(this.modelMapper.map(evenement, EvenementDto.class));
        }
        return evenementDtos;
    }

    @Override
    public void deleteEvenementById(Long evenementId) {
        this.evenementRepository.deleteById(evenementId);
    }

    @Override
    public EvenementDto updateEvenement(EvenementDto evenementDto) throws Exception {
        Evenement evenement = this.evenementRepository.findById(evenementDto.getIdEvenement()).orElseThrow(() -> new Exception("Evenement not found"));
        evenement.setId(evenementDto.getIdEvenement());
        evenement.setOrganizerId(evenementDto.getOrganizerId());
        evenement.setTitleEvenement(evenementDto.getTitleEvenement());
        evenement.setDescriptionEvenement(evenementDto.getDescriptionEvenement());
        evenement.setDateEvenement(evenementDto.getDateEvenement());
        evenement.setStatusEvenement(evenementDto.getStatusEvenement());
        evenement.setAgenda(evenementDto.getAgenda());
        evenement = this.evenementRepository.save(evenement);
        return this.modelMapper.map(evenement, EvenementDto.class);
    }
}
