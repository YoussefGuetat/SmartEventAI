
import { Component, signal } from '@angular/core';
import { FormGroup, FormBuilder, Validators, ReactiveFormsModule } from '@angular/forms'; 
import { HttpClient, HttpClientModule } from '@angular/common/http';

@Component({
  selector: 'app-auth',
  standalone: true,
  imports: [ReactiveFormsModule, HttpClientModule],
  templateUrl: './auth.component.html',
  styleUrl: './auth.component.css',
})
export class AuthComponent {
    isLoginMode = signal(true);
    registerForm: FormGroup;
    loginForm: FormGroup;
    
    loginErrors = signal<string>('');
    registerErrors = signal<string>('');
    loginSuccess = signal<string>('');
    registerSuccess = signal<string>('');

    private readonly apiBase = 'http://localhost:8083/auth';

    private apiRegister = `${this.apiBase}/register`
    private apiLogin = `${this.apiBase}/login`

  constructor(private fb: FormBuilder, private http: HttpClient) {
    this.registerForm = this.fb.group({
      nomUtilisateur: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      motDePasse: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', Validators.required]
    });

    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      motDePasse: ['', Validators.required]
    });
  }

  switchToLogin() {
    this.isLoginMode.set(true);
    this.loginErrors.set('');
    this.loginSuccess.set('');
  }

  switchToRegister() {
    this.isLoginMode.set(false);
    this.registerErrors.set('');
    this.registerSuccess.set('');
  }

  onLogin() {
    this.loginErrors.set('');
    this.loginSuccess.set('');

    if (this.loginForm.valid) {
       this.http.post(this.apiLogin, this.loginForm.value).subscribe({
        next: (response) => {
          this.loginSuccess.set('Connexion réussie !');
        },
        error: (error) => {
          if(error.status === 401) {
            this.loginErrors.set('Email ou mot de passe incorrect.');
            return;
          }else if (error.status === 0) {
            this.loginErrors.set('Impossible de joindre le serveur. Veuillez réessayer plus tard.');
            return;
          }
          else{
            this.loginErrors.set('Une erreur est survenue lors de la connexion. Veuillez réessayer.');
          }
         
        }
      });
    } else {
      this.loginErrors.set('Formulaire invalide. Veuillez vérifier vos informations de connexion.');
    }
  }

  onRegister() {
    this.registerErrors.set('');
    this.registerSuccess.set('');

    if (this.registerForm.valid) {
      if (this.registerForm.get('motDePasse')?.value !== this.registerForm.get('confirmPassword')?.value) {
        this.registerErrors.set('Les mots de passe ne correspondent pas.');
        return;
      }

      // Préparer les données à envoyer (sans confirmPassword)
      const userData = {
        nomUtilisateur: this.registerForm.get('nomUtilisateur')?.value,
        email: this.registerForm.get('email')?.value,
        motDePasse: this.registerForm.get('motDePasse')?.value
      };
      
      this.http.post(this.apiRegister, userData).subscribe({
        next: (response) => {
          this.registerSuccess.set('Inscription réussie !');
        },
        error: (error) => {
          if(error.status === 409) {
            this.registerErrors.set('Cet email est déjà utilisé.');
            return;
          }else if (error.status === 0) {
            this.registerErrors.set('Impossible de joindre le serveur. Veuillez réessayer plus tard.');
            return;
          }else{
            this.registerErrors.set('Une erreur est survenue lors de l\'inscription. Veuillez réessayer.');
          }
        }
      });
    } else {
      this.registerErrors.set('Formulaire invalide. Veuillez vérifier vos informations d\'inscription.');
    }
  }
}
