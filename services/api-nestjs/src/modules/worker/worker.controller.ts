/**
 * YoUnMe Dating App — Worker Controller
 * Protected by SupabaseAuthGuard.
 */

import {
  Controller,
  Post,
  Body,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { WorkerService } from './worker.service.js';
import { VisionScanDto } from './dto/vision-scan.dto.js';
import { SupabaseAuthGuard } from '../../common/guards/supabase-auth.guard.js';

@Controller('v1/worker')
@UseGuards(SupabaseAuthGuard)
export class WorkerController {
  constructor(private readonly workerService: WorkerService) {}

  @Post('vision-scan')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async visionScan(@Body() body: VisionScanDto) {
    const result = await this.workerService.processVisionScan(body);
    return { success: true, scan_result: result };
  }
}
