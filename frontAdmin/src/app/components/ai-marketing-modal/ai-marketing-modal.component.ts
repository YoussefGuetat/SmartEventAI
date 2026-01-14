import { Component, EventEmitter, Output } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';

export interface MarketingGenerateRequest {
  title: string;
  location: string;
  eventDate: string;
}

export interface MarketingGenerateResponse {
  marketing: string;
}

@Component({
  selector: 'app-ai-marketing-modal',
  templateUrl: './ai-marketing-modal.component.html',
  styleUrls: ['./ai-marketing-modal.component.scss'],
  standalone: false
})
export class AiMarketingModalComponent {
  @Output() closeModal = new EventEmitter<void>();
  @Output() marketingGenerated = new EventEmitter<string>();

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

    const request: MarketingGenerateRequest = this.generateForm.value;
    console.log('Génération marketing avec:', request);

    this.http.post<MarketingGenerateResponse>('http://localhost:8080/ai/generate-marketing', request)
      .subscribe({
        next: (response) => {
          console.log('Contenu marketing généré:', response);
          this.marketingGenerated.emit(response.marketing);
          this.close();
        },
        error: (error) => {
          console.error('Erreur lors de la génération marketing:', error);
          this.errorMessage = 'Une erreur est survenue lors de la génération du contenu marketing.';
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
