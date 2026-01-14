import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ReactiveFormsModule } from '@angular/forms';

import { DashboardComponent } from './dashboard.component';
import { CreateEventModalComponent } from '../../components/create-event-modal/create-event-modal.component';
import { EventDetailsModalComponent } from '../../components/event-details-modal/event-details-modal.component';
import { AiGenerateModalComponent } from '../../components/ai-generate-modal/ai-generate-modal.component';
import { AiMarketingModalComponent } from '../../components/ai-marketing-modal/ai-marketing-modal.component';
import { MarketingResultModalComponent } from '../../components/marketing-result-modal/marketing-result-modal.component';
import { routes } from './routes';

@NgModule({
  declarations: [
    DashboardComponent,
    CreateEventModalComponent,
    EventDetailsModalComponent,
    AiGenerateModalComponent,
    AiMarketingModalComponent,
    MarketingResultModalComponent
  ],
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule.forChild(routes)
  ]
})
export class DashboardModule { }
