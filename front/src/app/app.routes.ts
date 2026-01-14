import { Routes } from '@angular/router';
import { AuthComponent } from './components/auth/auth.component';
import { EvenementsComponent } from './components/evenements/evenements.component';

export const routes: Routes = [
    { path : '', component: EvenementsComponent},
    { path: 'auth', component: AuthComponent},
    { path: '**', redirectTo: '' }
    
];
