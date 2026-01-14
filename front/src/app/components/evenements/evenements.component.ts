import { Component, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Evenement } from '../../models/evenement.model';
import { EventCard } from '../event-card/event-card.component';
import { EvenementService } from '../../services/evenement.service';

@Component({
  selector: 'app-evenements',
  standalone: true,
  imports: [CommonModule, EventCard],
  templateUrl: './evenements.component.html',
  styleUrl: './evenements.component.css',
})
export class EvenementsComponent implements OnInit {
  evenements= signal<Evenement[]>([]);

  loading= signal<boolean>(false);

  error= signal<string>('');

  selectedEvent = signal<Evenement | null>(null);

  constructor(private evenementService: EvenementService) {}

  ngOnInit() {
    this.loadEvents();
  }

  loadEvents(){
    this.loading.set(true);
    this.error.set('');
    this.evenementService.getAllEvents().subscribe({
        next: (events) => {
            console.log('Événements chargés :', events);
            this.evenements.set(events);
            this.loading.set(false);
        },
        error: (err) => {
            console.error('Erreur lors du chargement des événements :', err);
            this.error.set('Impossible de charger les événements');
            this.loading.set(false);
        }
    });
  }

  selectEvent(event: Evenement) {
    this.selectedEvent.set(event);
  }

  closeEvent() {
    this.selectedEvent.set(null);
  }

  formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    return date.toLocaleDateString(undefined, {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }
}
