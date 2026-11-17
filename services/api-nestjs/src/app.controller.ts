/**
 * YoUnMe Dating App — Root Application Controller
 * Cloud Run health probe endpoint.
 */

import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get('health')
  health() {
    return {
      status: 'healthy',
      service: 'YoUnMe Tri-Microservices API Gateway',
      region: 'asia-south1 (Mumbai)',
      stack: {
        api: 'NestJS RESTful Service',
        realtime: 'Go WebSocket Engine / Gateway',
        worker: 'BullMQ + Redis Worker',
        database: 'GCP Cloud SQL + PostGIS (ST_DWithin)',
        cache: 'GCP Memorystore Redis',
        media: 'LiveKit Cloud WebRTC SFU',
      },
      timestamp: new Date().toISOString(),
    };
  }
}
