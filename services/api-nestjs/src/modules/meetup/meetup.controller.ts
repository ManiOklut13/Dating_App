/**
 * YoUnMe Dating App — Meetup & Date Memories Controller
 * Production-grade endpoints for:
 * 1. POST /v1/meetup/schedule (Check active subscription free date pass or wallet coin deduction)
 * 2. PATCH /v1/meetup/:id/accept (Partner accepts date)
 * 3. PATCH /v1/meetup/:id/decline (Partner declines with 100% full refund)
 * 4. PUT /v1/meetup/:id (Edit date details with 24-hour lock rule)
 * 5. PATCH /v1/meetup/:id/reschedule (Reschedule with 24-hour lock rule + 25-coin penalty)
 * 6. PATCH /v1/meetup/:id/cancel (Cancel with 24-hour lock rule + 80% coin refund / 20% platform fee)
 * 7. CRUD /v1/meetup/:id/todos (Manage date preparation checklist items)
 * 8. POST & GET /v1/meetup/:id/memories (Upload & fetch date photos/memories)
 * 9. POST /v1/meetup/:id/memories/generate-stickers (Deduct 20 coins, generate AI bitmoji stickers)
 * 10. POST /v1/meetup/:id/memories/share-chat (Share memory card + stickers to Go chat engine)
 * 11. POST /v1/meetup/:id/rating (Submit 5-star multi-category feedback with dynamic role mapping)
 * 12. POST /v1/meetup/:id/report (Create moderation ticket in user_blocks_reports)
 */

import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { MeetupService } from './meetup.service.js';
import {
  CreateMeetupDto,
  UpdateMeetupDto,
  SubmitMeetupRatingDto,
} from './dto/create-meetup.dto.js';
import {
  RescheduleMeetupDto,
  CancelMeetupDto,
} from './dto/reschedule-cancel.dto.js';
import { CreateTodoDto, UpdateTodoDto } from './dto/todo.dto.js';
import {
  AddMemoryDto,
  GenerateStickersDto,
  ShareChatMemoryDto,
} from './dto/memories.dto.js';
import { ReportMeetupDto } from './dto/report.dto.js';
import { SplitBillConfig } from './interfaces/meetup.interface.js';
import { SupabaseAuthGuard } from '../../common/guards/supabase-auth.guard.js';
import { CurrentUser } from '../../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';

@Controller('v1/meetup')
@UseGuards(SupabaseAuthGuard)
export class MeetupController {
  constructor(private readonly meetupService: MeetupService) {}

  // ---------------------------------------------------------------------------
  // 1. SCHEDULE DATE (with free pass / coin deduction)
  // ---------------------------------------------------------------------------
  @Post('schedule')
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  schedule(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateMeetupDto,
  ) {
    if (!dto.proposer_user_id && (user?.id || user?.uid)) {
      dto.proposer_user_id = user.id || user.uid;
    }
    return this.meetupService.scheduleMeetup(dto);
  }

  // ---------------------------------------------------------------------------
  // LIST & GET MEETUPS
  // ---------------------------------------------------------------------------
  @Get()
  getMeetups(
    @CurrentUser() user: AuthenticatedUser,
    @Query('user_id') userId?: string,
    @Query('status') status?: string,
  ) {
    const effectiveUserId = userId || user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.getMeetupsForUser(effectiveUserId, status);
  }

  @Get(':id')
  getMeetupById(@Param('id') id: string) {
    return this.meetupService.getMeetupById(id);
  }

  // ---------------------------------------------------------------------------
  // 2. ACCEPT DATE (pending -> scheduled)
  // ---------------------------------------------------------------------------
  @Patch(':id/accept')
  @HttpCode(HttpStatus.OK)
  acceptMeetup(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    const effectiveUserId = user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.acceptMeetup(id, effectiveUserId);
  }

  // ---------------------------------------------------------------------------
  // 3. DECLINE DATE (pending -> declined + 100% full refund)
  // ---------------------------------------------------------------------------
  @Patch(':id/decline')
  @HttpCode(HttpStatus.OK)
  declineMeetup(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body('reason') reason?: string,
  ) {
    const effectiveUserId = user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.declineMeetup(id, effectiveUserId, reason);
  }

  // ---------------------------------------------------------------------------
  // 4. EDIT DATE DETAILS (Enforce 24-hour prior lock rule)
  // ---------------------------------------------------------------------------
  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  editMeetup(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateMeetupDto,
  ) {
    const effectiveUserId = user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.editMeetup(id, effectiveUserId, dto);
  }

  // ---------------------------------------------------------------------------
  // 5. RESCHEDULE DATE (24-hour lock rule + 25-coin penalty)
  // ---------------------------------------------------------------------------
  @Patch(':id/reschedule')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  rescheduleMeetup(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: RescheduleMeetupDto,
  ) {
    const effectiveUserId = user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.rescheduleMeetup(id, effectiveUserId, dto);
  }

  // ---------------------------------------------------------------------------
  // 6. CANCEL DATE (24-hour lock rule + 80% coin refund, 20% platform fee)
  // ---------------------------------------------------------------------------
  @Patch(':id/cancel')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  cancelMeetup(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: CancelMeetupDto,
  ) {
    const effectiveUserId = user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.cancelMeetup(id, effectiveUserId, dto);
  }

  // ---------------------------------------------------------------------------
  // 7. CRUD /v1/meetup/:id/todos (Date preparation checklist)
  // ---------------------------------------------------------------------------
  @Get(':id/todos')
  getTodos(@Param('id') id: string) {
    return this.meetupService.getTodos(id);
  }

  @Post(':id/todos')
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  addTodo(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: CreateTodoDto,
  ) {
    const effectiveUserId = user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.addTodo(id, effectiveUserId, dto);
  }

  @Patch(':id/todos/:todoId')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  updateTodo(
    @Param('id') id: string,
    @Param('todoId') todoId: string,
    @Body() dto: UpdateTodoDto,
  ) {
    return this.meetupService.updateTodo(id, todoId, dto);
  }

  @Delete(':id/todos/:todoId')
  @HttpCode(HttpStatus.OK)
  deleteTodo(
    @Param('id') id: string,
    @Param('todoId') todoId: string,
  ) {
    return this.meetupService.deleteTodo(id, todoId);
  }

  // ---------------------------------------------------------------------------
  // 8. DATE MEMORIES (Upload date photos into date_memories)
  // ---------------------------------------------------------------------------
  @Post(':id/memories')
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  addMemory(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() body: AddMemoryDto,
  ) {
    const effectiveUserId = body.user_id || user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.addMemory(
      id,
      effectiveUserId,
      body.photo_uri,
      body.custom_gift_note,
    );
  }

  @Get(':id/memories')
  getMemories(@Param('id') id: string) {
    return this.meetupService.getMemories(id);
  }

  // ---------------------------------------------------------------------------
  // 9. AI STICKER GENERATION (Deduct 20 coins, generate bitmoji stickers)
  // ---------------------------------------------------------------------------
  @Post(':id/memories/generate-stickers')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  generateStickers(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: GenerateStickersDto,
  ) {
    const effectiveUserId = user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.generateStickers(id, effectiveUserId, dto);
  }

  // ---------------------------------------------------------------------------
  // 10. SHARE MEMORY TO CHAT (Format memory card + event dispatch to Go Engine)
  // ---------------------------------------------------------------------------
  @Post(':id/memories/share-chat')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  shareMemoryToChat(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: ShareChatMemoryDto,
  ) {
    const effectiveUserId = user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.shareMemoryToChat(id, effectiveUserId, dto);
  }

  // ---------------------------------------------------------------------------
  // 11. SUBMIT RATING (Dynamic role mapping: proposer vs partner)
  // ---------------------------------------------------------------------------
  @Post(':id/rating')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  submitRating(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: SubmitMeetupRatingDto,
  ) {
    const effectiveUserId = dto.user_id || user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.submitRating(id, effectiveUserId, dto);
  }

  // ---------------------------------------------------------------------------
  // 12. REPORT DATE (Create moderation ticket in user_blocks_reports)
  // ---------------------------------------------------------------------------
  @Post(':id/report')
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  reportMeetup(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: ReportMeetupDto,
  ) {
    const effectiveUserId = dto.actor_user_id || user?.id || user?.uid || '11111111-1111-1111-1111-111111111111';
    return this.meetupService.reportMeetup(id, effectiveUserId, dto);
  }

  // ---------------------------------------------------------------------------
  // LEGACY / COMPATIBILITY ROUTES
  // ---------------------------------------------------------------------------
  @Patch(':id/status')
  updateStatus(
    @Param('id') id: string,
    @Body('status') status: any,
  ) {
    return this.meetupService.updateStatus(id, status);
  }

  @Put(':id/status')
  updateStatusPut(
    @Param('id') id: string,
    @Body('status') status: any,
  ) {
    return this.meetupService.updateStatus(id, status);
  }

  @Post(':id/split-bill')
  updateSplitBill(
    @Param('id') id: string,
    @Body('split_bill_config') splitBillConfig: SplitBillConfig,
  ) {
    return this.meetupService.updateSplitBill(id, splitBillConfig);
  }
}
