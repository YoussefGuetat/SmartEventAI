import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Evenement } from '../models/evenement.model';

@Injectable({
  providedIn: 'root'
})
export class EvenementService {
    private apiGetAllEvents = 'http://localhost:8083/events/getAllEvents';

    constructor(private http: HttpClient) { }

    getAllEvents(): Observable<Evenement[]> {
        return this.http.get<Evenement[]>(this.apiGetAllEvents);
    }

}
