# Dashboard SmartEvent AI - Documentation

## 📋 Vue d'ensemble

Ce composant Dashboard est le template principal de l'application **SmartEvent AI**, construit avec **Angular 17+** et **CoreUI Free Angular Admin Template**.

## 🎯 Fonctionnalités

### 1. **Section Résumé (Statistiques)**
Affiche 3 cartes avec des métriques clés :
- **Événements au total** : 12
- **Événements générés par l'IA** : 5
- **Événements validés** : 3

> 💡 Ces valeurs sont actuellement **fictives** (définies dans `stats`). Plus tard, elles seront alimentées par les services.

### 2. **Section Actions rapides**
4 boutons d'action principaux :
- **Créer un événement** → `/events/new`
- **Voir la liste des événements** → `/events/list`
- **Ouvrir l'assistant IA** → `/ai`
- **Lancer un workflow** → `/workflow`

### 3. **Section Derniers événements**
Table affichant les événements récents avec :
- ID
- Titre
- Date
- Lieu
- Statut (avec badge coloré)

Les statuts disponibles :
- `VALIDATED` → Badge vert
- `GENERATED` → Badge bleu
- `DRAFT` → Badge jaune

> 💡 Les données sont actuellement **mockées** dans `recentEvents[]`. Prêt pour l'intégration avec un service.

## 🏗️ Architecture

```
dashboard/
├── dashboard.component.ts      # Logique TypeScript + imports CoreUI
├── dashboard.component.html    # Template HTML avec composants CoreUI
├── dashboard.component.scss    # Styles personnalisés
└── routes.ts                   # Configuration de routing
```

### Interfaces TypeScript

```typescript
interface EventStats {
  totalEvents: number;
  aiGeneratedEvents: number;
  validatedEvents: number;
}

interface Event {
  id: number;
  title: string;
  date: string;
  location: string;
  status: 'DRAFT' | 'GENERATED' | 'VALIDATED';
}
```

## 🔌 Intégration future avec les services

Le composant est conçu pour faciliter l'intégration avec vos microservices via l'API Gateway (`http://localhost:8080`).

### Services à créer plus tard :

```typescript
// app/services/event.service.ts
export class EventService {
  getStats(): Observable<EventStats> { /* ... */ }
  getRecentEvents(): Observable<Event[]> { /* ... */ }
}

// app/services/ai.service.ts
export class AiService { /* ... */ }

// app/services/workflow.service.ts
export class WorkflowService { /* ... */ }
```

### Intégration dans le composant :

```typescript
// Dans dashboard.component.ts
constructor(
  private eventService: EventService,
  private aiService: AiService,
  private workflowService: WorkflowService
) {}

ngOnInit(): void {
  this.loadStats();
  this.loadRecentEvents();
}

loadStats(): void {
  this.eventService.getStats().subscribe(stats => {
    this.stats = stats;
  });
}

loadRecentEvents(): void {
  this.eventService.getRecentEvents().subscribe(events => {
    this.recentEvents = events;
  });
}
```

## 🎨 Composants CoreUI utilisés

- `ContainerComponent`, `RowComponent`, `ColComponent` → Layout Grid
- `CardComponent`, `CardHeaderComponent`, `CardBodyComponent` → Cartes
- `ButtonDirective` → Boutons stylisés
- `TableDirective` → Tables responsives
- `BadgeComponent` → Badges de statut
- `IconDirective` → Icônes CoreUI

## 🚀 Utilisation

### 1. Intégrer dans le routing principal

```typescript
// app/app.routes.ts
export const routes: Routes = [
  {
    path: '',
    redirectTo: 'dashboard',
    pathMatch: 'full'
  },
  {
    path: 'dashboard',
    loadChildren: () => import('./views/dashboard/routes').then(m => m.routes)
  },
  // ... autres routes
];
```

### 2. Ajouter au menu de navigation (si applicable)

```typescript
// Exemple dans un fichier de navigation
{
  name: 'Dashboard',
  url: '/dashboard',
  icon: 'cilSpeedometer'
}
```

## 📦 Dépendances requises

Assurez-vous que votre `package.json` inclut :

```json
{
  "dependencies": {
    "@angular/common": "^17.x.x",
    "@angular/core": "^17.x.x",
    "@angular/router": "^17.x.x",
    "@coreui/angular": "^5.x.x",
    "@coreui/icons": "^3.x.x",
    "@coreui/icons-angular": "^5.x.x"
  }
}
```

## 🎯 Prochaines étapes

1. ✅ Template visuel créé
2. ⏳ Créer les services Angular (`EventService`, `AiService`, `WorkflowService`)
3. ⏳ Connecter aux endpoints de l'API Gateway
4. ⏳ Implémenter la gestion d'état (NgRx/Signals si nécessaire)
5. ⏳ Ajouter la gestion des erreurs et loading states
6. ⏳ Créer les pages liées (`/events/new`, `/events/list`, `/ai`, `/workflow`)

## 📝 Notes

- **Standalone Component** : Utilise l'approche moderne d'Angular 17+
- **Pas d'appels HTTP** : Template purement visuel pour l'instant
- **Responsive** : S'adapte aux différentes tailles d'écran
- **Accessibility** : Structure sémantique avec ARIA (à améliorer)
- **Icônes** : Utilise CoreUI Icons (préfixe `cil*`)

## 🔗 Endpoints API Gateway (pour référence future)

- Events : `http://localhost:8080/events/**`
- Auth : `http://localhost:8080/auth/**`
- AI : `http://localhost:8080/ai/**`
- Workflow : `http://localhost:8080/workflow/**`

---

**Auteur** : GitHub Copilot  
**Date** : Novembre 2025  
**Version** : 1.0.0 (Template initial)
