import { Component, EventEmitter, Input, Output } from '@angular/core';

@Component({
  selector: 'app-marketing-result-modal',
  templateUrl: './marketing-result-modal.component.html',
  styleUrls: ['./marketing-result-modal.component.scss'],
  standalone: false
})
export class MarketingResultModalComponent {
  @Input() marketingContent: string = '';
  @Output() closeModal = new EventEmitter<void>();

  copied = false;

  close(): void {
    this.closeModal.emit();
  }

  copyToClipboard(): void {
    navigator.clipboard.writeText(this.marketingContent).then(() => {
      this.copied = true;
      setTimeout(() => {
        this.copied = false;
      }, 2000);
    });
  }
}
