export interface Event {
  idEvenement?: number;
  organizerId?: number;
  titleEvenement: string;
  descriptionEvenement: string;
  dateEvenement: string;
  location: string;
  statusEvenement: EventStatus;
  agenda: string;
}

export enum EventStatus {
  DRAFT = 'DRAFT',
  VALIDATED = 'VALIDATED',
  GENERATED = 'GENERATED'
}

export interface CreateEventRequest {
  organizerId: number;
  titleEvenement: string;
  descriptionEvenement: string;
  dateEvenement: string;
  location: string;
  statusEvenement: EventStatus;
  agenda: string;
}
