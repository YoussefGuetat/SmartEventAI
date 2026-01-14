import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { Router } from '@angular/router';
import { EventService } from '../../services/event.service';
import { AuthService } from '../../services/auth.service';
import { Event } from '../../models/event.model';

@Component({
    selector: 'app-dashboard',
    templateUrl: './dashboard.component.html',
    styleUrls: ['./dashboard.component.scss'],
    standalone: false
})
export class DashboardComponent implements OnInit {
  showCreateEventModal = false;
  showEventDetailsModal = false;
  showEditEventModal = false;
  showAiGenerateModal = false;
  showAiMarketingModal = false;
  showMarketingResultModal = false;
  selectedEvent: Event | null = null;
  aiGeneratedData: any = null;
  marketingContent: string = '';
  events: Event[] = [];
  isLoading = false;
  currentUserId: number | null = null;

  constructor(
    private eventService: EventService,
    private authService: AuthService,
    private router: Router,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    console.log('ngOnInit appelé');
    this.currentUserId = this.authService.getUserId();
    console.log('Current User ID dans ngOnInit:', this.currentUserId);
    this.loadEvents();
  }

  loadEvents(): void {
    this.isLoading = true;
    console.log('Chargement des événements pour userId:', this.currentUserId);
    console.log('isLoading:', this.isLoading);
    
    this.eventService.getAllEvents().subscribe({
      next: (events) => {
        console.log('Événements reçus:', events);
        
        // Filtrer les événements de l'utilisateur connecté (tous les statuts)
        this.events = events.filter(event => {
          console.log(`Event ${event.idEvenement}: organizerId=${event.organizerId}, currentUserId=${this.currentUserId}`);
          return event.organizerId === this.currentUserId;
        });
        
        console.log('Événements filtrés:', this.events);
        this.isLoading = false;
        console.log('isLoading après chargement:', this.isLoading);
        this.cdr.detectChanges();
        console.log('Detection de changement forcée');
      },
      error: (error) => {
        console.error('Erreur lors du chargement des événements:', error);
        this.isLoading = false;
        console.log('isLoading après erreur:', this.isLoading);
        this.cdr.detectChanges();
      }
    });
  }

  openCreateEventModal(): void {
    this.aiGeneratedData = null; // Reset AI data
    this.showCreateEventModal = true;
  }

  closeCreateEventModal(): void {
    this.showCreateEventModal = false;
    this.aiGeneratedData = null;
  }

  openAiGenerateModal(): void {
    this.showAiGenerateModal = true;
  }

  closeAiGenerateModal(): void {
    this.showAiGenerateModal = false;
  }

  openAiMarketingModal(): void {
    this.showAiMarketingModal = true;
  }

  closeAiMarketingModal(): void {
    this.showAiMarketingModal = false;
  }

  onMarketingGenerated(content: string): void {
    console.log('Contenu marketing reçu:', content);
    this.marketingContent = content;
    this.showAiMarketingModal = false;
    this.showMarketingResultModal = true;
  }

  closeMarketingResultModal(): void {
    this.showMarketingResultModal = false;
    this.marketingContent = '';
  }

  onAiContentGenerated(data: any): void {
    console.log('Contenu IA reçu dans dashboard:', data);
    this.aiGeneratedData = data;
    this.showAiGenerateModal = false;
    this.showCreateEventModal = true;
  }

  onEventCreated(): void {
    this.loadEvents(); // Recharger la liste
  }

  viewEventDetails(event: Event): void {
    this.selectedEvent = event;
    this.showEventDetailsModal = true;
  }

  closeEventDetailsModal(): void {
    this.showEventDetailsModal = false;
    this.selectedEvent = null;
  }

  openEditEventModal(event: Event, $event: MouseEvent): void {
    $event.stopPropagation();
    this.selectedEvent = event;
    this.showEditEventModal = true;
  }

  closeEditEventModal(): void {
    this.showEditEventModal = false;
    this.selectedEvent = null;
  }

  onEventUpdated(): void {
    this.loadEvents();
  }

  deleteEvent(event: Event, $event: MouseEvent): void {
    $event.stopPropagation(); // Empêcher l'ouverture des détails
    
    if (confirm(`Êtes-vous sûr de vouloir supprimer l'événement "${event.titleEvenement}" ?`)) {
      this.eventService.deleteEvent(event.idEvenement!).subscribe({
        next: () => {
          console.log('Événement supprimé avec succès');
          this.loadEvents(); // Recharger la liste
        },
        error: (error) => {
          console.error('Erreur lors de la suppression:', error);
          alert('Une erreur est survenue lors de la suppression de l\'événement.');
        }
      });
    }
  }

  startWorkflow(event: Event, $event: MouseEvent): void {
    $event.stopPropagation(); // Empêcher l'ouverture des détails
    
    if (confirm(`Voulez-vous démarrer le workflow d'automatisation pour "${event.titleEvenement}" ?`)) {
      this.eventService.startWorkflow(event.idEvenement!).subscribe({
        next: (response) => {
          console.log('Workflow démarré avec succès:', response);
          alert('Workflow d\'automatisation démarré avec succès !');
          this.loadEvents(); // Recharger la liste pour voir les changements
        },
        error: (error) => {
          console.error('Erreur lors du démarrage du workflow:', error);
          alert('Une erreur est survenue lors du démarrage du workflow.');
        }
      });
    }
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  getStatusBadgeClass(status: string): string {
    switch (status) {
      case 'VALIDATED':
        return 'success';
      case 'GENERATED':
        return 'info';
      case 'DRAFT':
        return 'warning';
      default:
        return 'secondary';
    }
  }

  getStatusLabel(status: string): string {
    switch (status) {
      case 'VALIDATED':
        return 'Validé';
      case 'GENERATED':
        return 'Généré par IA';
      case 'DRAFT':
        return 'Brouillon';
      default:
        return status;
    }
  }
}
