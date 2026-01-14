import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Event, CreateEventRequest } from '../models/event.model';

@Injectable({
  providedIn: 'root'
})
export class EventService {
  private apiUrl = 'http://localhost:8080/events';

  constructor(private http: HttpClient) { }

  createEvent(event: CreateEventRequest): Observable<Event> {
    return this.http.post<Event>(`${this.apiUrl}/saveEvenement`, event);
  }

  updateEvent(event: Event): Observable<Event> {
    console.log('EventService.updateEvent - Envoi de:', event);
    console.log('EventService.updateEvent - URL:', `${this.apiUrl}/updateEvenement`);
    return this.http.put<Event>(`${this.apiUrl}/updateEvenement`, event);
  }

  getAllEvents(): Observable<Event[]> {
    return this.http.get<Event[]>(`${this.apiUrl}/getAllEvents`);
  }

  deleteEvent(eventId: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/deleteEvenementByID/${eventId}`);
  }

  startWorkflow(eventId: number): Observable<any> {
    return this.http.post<any>(`http://localhost:8080/workflow/start/${eventId}`, {});
  }
}
