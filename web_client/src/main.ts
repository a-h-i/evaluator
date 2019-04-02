import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { enableProdMode } from '@angular/core';

if (process.env.IS_PRODUCTION) {
  enableProdMode();
}

import { EvaluatorModule } from './app/evaluator.module';

platformBrowserDynamic().bootstrapModule(EvaluatorModule);