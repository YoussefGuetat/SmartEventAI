import { Component, EventEmitter, Output } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';

export interface AIGenerateRequest {
  title: string;
  location: string;
  eventDate: string;
}

export interface AIGenerateResponse {
  title: string;
  description: string;
  agenda: string;
}

@Component({
  selector: 'app-ai-generate-modal',
  templateUrl: './ai-generate-modal.component.html',
  styleUrls: ['./ai-generate-modal.component.scss'],
  standalone: false
})
export class AiGenerateModalComponent {
  @Output() closeModal = new EventEmitter<void>();
  @Output() contentGenerated = new EventEmitter<AIGenerateResponse & { location: string; eventDate: string }>();

  generateForm: FormGroup;
  isGenerating = false;
  errorMessage = '';

  constructor(
    private fb: FormBuilder,
    private http: HttpClient
  ) {
    this.generateForm = this.fb.group({
      title: ['', [Validators.required, Validators.minLength(3)]],
      location: ['', Validators.required],
      eventDate: ['', Validators.required]
    });
  }

  onSubmit(): void {
    if (this.generateForm.invalid) {
      this.generateForm.markAllAsTouched();
      return;
    }

    this.isGenerating = true;
    this.errorMessage = '';

    const request: AIGenerateRequest = this.generateForm.value;
    console.log('Génération IA avec:', request);

    this.http.post<AIGenerateResponse>('http://localhost:8080/ai/generate-event-content', request)
      .subscribe({
        next: (response) => {
          console.log('Contenu généré par IA:', response);
          
          // Émettre les données générées avec la date et location d'origine
          this.contentGenerated.emit({
            ...response,
            location: request.location,
            eventDate: request.eventDate
          });
          
          this.close();
        },
        error: (error) => {
          console.error('Erreur lors de la génération:', error);
          this.errorMessage = 'Une erreur est survenue lors de la génération du contenu.';
          this.isGenerating = false;
        },
        complete: () => {
          this.isGenerating = false;
        }
      });
  }

  close(): void {
    this.closeModal.emit();
  }

  getErrorMessage(fieldName: string): string {
    const control = this.generateForm.get(fieldName);
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
