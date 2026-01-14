import { Component, EventEmitter, Input, Output } from '@angular/core';
import { Event } from '../../models/event.model';

@Component({
  selector: 'app-event-details-modal',
  templateUrl: './event-details-modal.component.html',
  styleUrls: ['./event-details-modal.component.scss'],
  standalone: false
})
export class EventDetailsModalComponent {
  @Input() event: Event | null = null;
  @Output() closeModal = new EventEmitter<void>();

  close(): void {
    this.closeModal.emit();
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
