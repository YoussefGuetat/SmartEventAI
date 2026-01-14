import { Component, EventEmitter, Output, Input, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { EventService } from '../../services/event.service';
import { AuthService } from '../../services/auth.service';
import { EventStatus, CreateEventRequest, Event } from '../../models/event.model';

@Component({
    selector: 'app-create-event-modal',
    templateUrl: './create-event-modal.component.html',
    styleUrls: ['./create-event-modal.component.scss'],
    standalone: false
})
export class CreateEventModalComponent implements OnInit {
  @Input() event?: Event; // Si fourni, on est en mode édition
  @Input() aiGeneratedData?: any; // Données générées par l'IA
  @Output() closeModal = new EventEmitter<void>();
  @Output() eventCreated = new EventEmitter<void>();

  eventForm: FormGroup;
  isSubmitting = false;
  errorMessage = '';
  isEditMode = false;
  eventStatusOptions = [
    { value: EventStatus.DRAFT, label: 'Brouillon' },
    { value: EventStatus.VALIDATED, label: 'Validé' },
    { value: EventStatus.GENERATED, label: 'Généré par IA' }
  ];

  constructor(
    private fb: FormBuilder,
    private eventService: EventService,
    private authService: AuthService
  ) {
    this.eventForm = this.fb.group({
      titleEvenement: ['', [Validators.required, Validators.minLength(3)]],
      descriptionEvenement: ['', [Validators.required, Validators.minLength(10)]],
      dateEvenement: ['', Validators.required],
      location: ['', Validators.required],
      statusEvenement: [EventStatus.DRAFT, Validators.required],
      agenda: ['', Validators.required]
    });
  }

  ngOnInit(): void {
    this.isEditMode = !!this.event;
    
    if (this.isEditMode && this.event) {
      // Pré-remplir le formulaire avec les données de l'événement
      const eventDate = new Date(this.event.dateEvenement);
      const formattedDate = eventDate.toISOString().slice(0, 16);
      
      this.eventForm.patchValue({
        titleEvenement: this.event.titleEvenement,
        descriptionEvenement: this.event.descriptionEvenement,
        dateEvenement: formattedDate,
        location: this.event.location,
        statusEvenement: this.event.statusEvenement,
        agenda: this.event.agenda
      });
    } else if (this.aiGeneratedData) {
      // Pré-remplir avec les données générées par l'IA
      console.log('Pré-remplissage avec données IA:', this.aiGeneratedData);
      
      // Convertir la date YYYY-MM-DD en datetime-local format
      const eventDate = new Date(this.aiGeneratedData.eventDate);
      eventDate.setHours(20, 0, 0, 0); // Par défaut 20h00
      const formattedDate = eventDate.toISOString().slice(0, 16);
      
      this.eventForm.patchValue({
        titleEvenement: this.aiGeneratedData.title,
        descriptionEvenement: this.aiGeneratedData.description,
        dateEvenement: formattedDate,
        location: this.aiGeneratedData.location,
        statusEvenement: EventStatus.GENERATED,
        agenda: this.aiGeneratedData.agenda
      });
    }
  }

  onSubmit(): void {
    if (this.eventForm.invalid) {
      this.eventForm.markAllAsTouched();
      return;
    }

    this.isSubmitting = true;
    this.errorMessage = '';

    const formValue = this.eventForm.value;
    const userId = this.authService.getUserId();
    
    if (!userId) {
      this.errorMessage = 'Utilisateur non connecté';
      this.isSubmitting = false;
      return;
    }

    if (this.isEditMode && this.event) {
      // Mode édition
      const updatedEvent: Event = {
        ...this.event,
        titleEvenement: formValue.titleEvenement,
        descriptionEvenement: formValue.descriptionEvenement,
        dateEvenement: new Date(formValue.dateEvenement).toISOString(),
        location: formValue.location,
        statusEvenement: formValue.statusEvenement,
        agenda: formValue.agenda,
        organizerId: userId
      };

      console.log('Mise à jour événement:', updatedEvent);

      this.eventService.updateEvent(updatedEvent).subscribe({
        next: (response) => {
          console.log('Événement mis à jour avec succès:', response);
          this.eventCreated.emit();
          this.close();
        },
        error: (error) => {
          console.error('Erreur lors de la mise à jour de l\'événement:', error);
          this.errorMessage = 'Une erreur est survenue lors de la mise à jour de l\'événement.';
          this.isSubmitting = false;
        },
        complete: () => {
          this.isSubmitting = false;
        }
      });
    } else {
      // Mode création
      const eventData: CreateEventRequest = {
        titleEvenement: formValue.titleEvenement,
        descriptionEvenement: formValue.descriptionEvenement,
        dateEvenement: new Date(formValue.dateEvenement).toISOString(),
        location: formValue.location,
        statusEvenement: formValue.statusEvenement,
        agenda: formValue.agenda,
        organizerId: userId
      };

      console.log('Création événement avec organizerId:', userId, eventData);

      this.eventService.createEvent(eventData).subscribe({
        next: (response) => {
          console.log('Événement créé avec succès:', response);
          this.eventCreated.emit();
          this.close();
        },
        error: (error) => {
          console.error('Erreur lors de la création de l\'événement:', error);
          this.errorMessage = 'Une erreur est survenue lors de la création de l\'événement.';
          this.isSubmitting = false;
        },
        complete: () => {
          this.isSubmitting = false;
        }
      });
    }
  }

  close(): void {
    this.closeModal.emit();
  }

  getErrorMessage(fieldName: string): string {
    const control = this.eventForm.get(fieldName);
    if (control?.hasError('required')) {
      return 'Ce champ est requis';
    }
    if (control?.hasError('minlength')) {
      const minLength = control.errors?.['minlength'].requiredLength;
      return `Minimum ${minLength} caractères requis`;
    }
    return '';
  }
}
