package com.smarteventai.eventservice.repositories;

import com.smarteventai.eventservice.entities.Evenement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EvenementRepository extends JpaRepository<Evenement, Long> {
    Evenement findByTitleEvenement(String titleEvenement);
}
