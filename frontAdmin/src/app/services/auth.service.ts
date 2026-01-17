import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, tap } from 'rxjs';
import { LoginRequest, LoginResponse, User } from '../models/auth.model';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = 'https://gateway-service-production-b40f.up.railway.app/auth';
  private currentUserSubject = new BehaviorSubject<User | null>(null);
  public currentUser$ = this.currentUserSubject.asObservable();

  constructor(private http: HttpClient) {
    // Charger l'utilisateur depuis le localStorage au démarrage
    try {
      const storedUser = localStorage.getItem('currentUser');
      if (storedUser) {
        this.currentUserSubject.next(JSON.parse(storedUser));
      }
    } catch (error) {
      console.error('Erreur lors du chargement de l\'utilisateur:', error);
      // Nettoyer le localStorage si les données sont corrompues
      localStorage.removeItem('currentUser');
      localStorage.removeItem('token');
    }
  }

  login(credentials: LoginRequest): Observable<any> {
    // Adapter le format pour le backend (qui attend peut-être motDePasse au lieu de password)
    const payload = {
      email: credentials.email,
      motDePasse: credentials.password
    };
    console.log('Payload envoyé:', payload);
    
    return this.http.post<any>(`${this.apiUrl}/login`, payload).pipe(
      tap(response => {
        console.log('Réponse complète de login:', response);
        
        // Le backend retourne: { idAuthentification, nomUtilisateur, email, motDePasse, role, active }
        // On va créer un token simple et mapper les données
        
        const user: User = {
          id: response.idAuthentification,
          email: response.email,
          name: response.nomUtilisateur,
          role: response.role
        };
        
        // Générer un token simple (en attendant que le backend en fournisse un)
        const token = btoa(JSON.stringify({ userId: user.id, timestamp: Date.now() }));
        
        console.log('Token généré:', token);
        console.log('User extrait:', user);
        
        // Stocker le token et l'utilisateur
        localStorage.setItem('token', token);
        localStorage.setItem('currentUser', JSON.stringify(user));
        this.currentUserSubject.next(user);
        
        console.log('Utilisateur stocké:', user);
        console.log('User ID:', user.id);
      })
    );
  }

  logout(): void {
    localStorage.removeItem('token');
    localStorage.removeItem('currentUser');
    this.currentUserSubject.next(null);
  }

  getToken(): string | null {
    return localStorage.getItem('token');
  }

  getCurrentUser(): User | null {
    return this.currentUserSubject.value;
  }

  isAuthenticated(): boolean {
    return !!this.getToken();
  }

  getUserId(): number | null {
    const user = this.getCurrentUser();
    console.log('getUserId() - Current user:', user);
    console.log('getUserId() - User ID:', user?.id);
    return user ? user.id : null;
  }
}
