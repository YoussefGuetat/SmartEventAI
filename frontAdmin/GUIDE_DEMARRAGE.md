# SmartEvent AI - Dashboard Template - Guide de démarrage

## ✅ Problème résolu !

L'application est maintenant **opérationnelle** et fonctionne sur `http://localhost:4200/`

## 📦 Ce qui a été fait

### 1. **Projet Angular initialisé**
- Angular 17.3.12 installé
- Structure de projet créée avec routing et SCSS

### 2. **Remplacement de CoreUI par Bootstrap**
**Pourquoi ?** CoreUI 5.x nécessite Angular 20+ (incompatible avec Angular 17)

**Solution :** Utilisation de **Bootstrap 5 + Font Awesome** pour un design moderne similaire

**Packages installés :**
```json
{
  "bootstrap": "^5.x.x",
  "@fortawesome/fontawesome-free": "^6.x.x"
}
```

### 3. **Composants créés**

#### Dashboard Component (`src/app/views/dashboard/`)
- ✅ `dashboard.component.ts` - Logique TypeScript avec données mockées
- ✅ `dashboard.component.html` - Template Bootstrap avec Font Awesome icons
- ✅ `dashboard.component.scss` - Styles personnalisés
- ✅ `dashboard.module.ts` - Module Angular
- ✅ `routes.ts` - Configuration du routing

#### Structure du Dashboard
1. **Header** - Titre "SmartEvent AI" + sous-titre
2. **Section Résumé** - 3 cartes statistiques :
   - Événements au total (12)
   - Événements générés par l'IA (5)
   - Événements validés (3)
3. **Actions rapides** - 4 boutons de navigation :
   - Créer un événement → `/events/new`
   - Liste des événements → `/events/list`
   - Assistant IA → `/ai`
   - Lancer workflow → `/workflow`
4. **Derniers événements** - Table responsive avec 5 événements mockés

### 4. **Configuration du routing**
```typescript
// app-routing.module.ts
{
  path: '',
  redirectTo: '/dashboard',
  pathMatch: 'full'
},
{
  path: 'dashboard',
  loadChildren: () => import('./views/dashboard/dashboard.module')
    .then(m => m.DashboardModule)
}
```

### 5. **Styles globaux configurés**
- Bootstrap 5 importé
- Font Awesome importé (Solid, Regular, Brands)
- Couleur primaire personnalisée (#321fdb)

## 🚀 Commandes disponibles

### Démarrer le serveur de développement
```powershell
cd templateFront
ng serve
```
L'app sera accessible sur `http://localhost:4200/`

### Compiler le projet
```powershell
ng build
```
Les fichiers compilés seront dans `dist/`

### Compiler en mode production
```powershell
ng build --configuration production
```

## 📁 Structure du projet

```
templateFront/
├── src/
│   ├── app/
│   │   ├── views/
│   │   │   └── dashboard/
│   │   │       ├── dashboard.component.ts
│   │   │       ├── dashboard.component.html
│   │   │       ├── dashboard.component.scss
│   │   │       ├── dashboard.module.ts
│   │   │       └── routes.ts
│   │   ├── app-routing.module.ts
│   │   ├── app.component.ts
│   │   ├── app.component.html
│   │   ├── app.component.scss
│   │   └── app.module.ts
│   ├── assets/
│   ├── styles.scss (Bootstrap + Font Awesome)
│   └── index.html
├── angular.json
├── package.json
└── tsconfig.json
```

## 🎨 Technologies utilisées

| Technologie | Version | Usage |
|------------|---------|-------|
| Angular | 17.3.12 | Framework frontend |
| TypeScript | 5.4.5 | Langage de programmation |
| Bootstrap | 5.3.x | Framework CSS |
| Font Awesome | 6.x.x | Icônes |
| RxJS | 7.8.x | Programmation réactive |

## 🔗 Prochaines étapes

### 1. Créer les services Angular
```typescript
// src/app/services/event.service.ts
@Injectable({ providedIn: 'root' })
export class EventService {
  private apiUrl = 'http://localhost:8080/events';
  
  constructor(private http: HttpClient) {}
  
  getStats(): Observable<EventStats> {
    return this.http.get<EventStats>(`${this.apiUrl}/stats`);
  }
  
  getRecentEvents(): Observable<Event[]> {
    return this.http.get<Event[]>(`${this.apiUrl}/recent`);
  }
}
```

### 2. Intégrer les services dans le Dashboard
```typescript
// dashboard.component.ts
export class DashboardComponent implements OnInit {
  constructor(private eventService: EventService) {}
  
  ngOnInit(): void {
    this.loadStats();
    this.loadRecentEvents();
  }
  
  loadStats(): void {
    this.eventService.getStats().subscribe(
      stats => this.stats = stats,
      error => console.error('Erreur chargement stats:', error)
    );
  }
}
```

### 3. Créer les pages manquantes
- `/events/new` - Création d'événement
- `/events/list` - Liste des événements
- `/ai` - Assistant IA
- `/workflow` - Gestion des workflows

### 4. Ajouter l'authentification
Connecter au service `auth-service` via l'API Gateway

### 5. Implémenter la gestion d'état
Utiliser NgRx ou Angular Signals pour gérer l'état global

## 🐛 Résolution des problèmes courants

### Le serveur ne démarre pas
```powershell
# Supprimer node_modules et réinstaller
Remove-Item -Path node_modules -Recurse -Force
npm install
ng serve
```

### Erreurs de compilation
```powershell
# Nettoyer le cache Angular
ng cache clean
ng serve
```

### Port 4200 déjà utilisé
```powershell
# Utiliser un autre port
ng serve --port 4300
```

## 📝 Notes importantes

- ✅ **Données mockées** : Toutes les données sont en dur pour l'instant
- ✅ **Pas d'appels HTTP** : Prêt pour l'intégration des services
- ✅ **Responsive** : S'adapte aux mobiles, tablettes et desktop
- ✅ **Icons Font Awesome** : Remplacent les icônes CoreUI
- ⚠️ **Warning budget** : Le bundle dépasse 500KB (normal avec Bootstrap)

## 🔧 Configuration des endpoints API

```typescript
// environments/environment.ts
export const environment = {
  production: false,
  apiGateway: 'http://localhost:8080',
  endpoints: {
    events: '/events',
    auth: '/auth',
    ai: '/ai',
    workflow: '/workflow'
  }
};
```

## 📚 Ressources

- [Angular Documentation](https://angular.io/docs)
- [Bootstrap Documentation](https://getbootstrap.com/docs/5.3/)
- [Font Awesome Icons](https://fontawesome.com/icons)
- [RxJS Documentation](https://rxjs.dev/)

---

**Status:** ✅ Application fonctionnelle  
**URL:** http://localhost:4200/  
**Dernière mise à jour:** 20 novembre 2025
