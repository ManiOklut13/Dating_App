/**
 * YoUnMe Dating App — Worker Dispatch Service
 * Decoupled out-of-process integration with the Cloud Run BullMQ worker.
 * Never imports worker runtime code directly; dispatches over HTTP instead.
 */

import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface VisionScanJob {
  asset_id: string;
  user_id: string;
  image_url: string;
  type: 'profile_photo' | 'chat_media' | 'video_call_preview';
}

@Injectable()
export class WorkerService {
  private readonly logger = new Logger(WorkerService.name);

  constructor(private readonly configService: ConfigService) {}

  private get baseUrl(): string {
    return this.configService.get<string>('WORKER_BASE_URL') || 'http://localhost:8082';
  }

  async processVisionScan(job: VisionScanJob) {
    const url = `${this.baseUrl.replace(/\/$/, '')}/vision-scan`;

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(job),
      });

      if (!response.ok) {
        throw new Error(`Worker responded with status ${response.status}`);
      }

      return await response.json();
    } catch (err: any) {
      this.logger.error(`Vision scan dispatch to worker failed: ${err.message}`);
      throw new ServiceUnavailableException(
        'Background worker unavailable. Ensure the worker-bullmq service is running.',
      );
    }
  }
}
