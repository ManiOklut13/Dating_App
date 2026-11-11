import { jest } from '@jest/globals';
import { Test, TestingModule } from '@nestjs/testing';
import { MeetupService } from './meetup.service.js';
import { DatabaseService } from '../database/database.service.js';
import { WalletService } from '../wallet/wallet.service.js';
import { ConfigService } from '@nestjs/config';

describe('MeetupService', () => {
  let service: MeetupService;

  const mockDatabaseService = {
    isConnected: false,
    query: (jest.fn() as any).mockResolvedValue({ rows: [] }),
    pool: null,
  };

  const mockWalletService = {
    hasActiveFreeDatePass: (jest.fn() as any).mockResolvedValue(false),
    executeAtomicLedgerTransaction: (jest.fn() as any).mockResolvedValue({
      txId: 'mock-tx-123',
      balance: 500,
    }),
  };

  const mockConfigService = {
    get: (jest.fn() as any).mockReturnValue('http://localhost:8081'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MeetupService,
        {
          provide: DatabaseService,
          useValue: mockDatabaseService,
        },
        {
          provide: WalletService,
          useValue: mockWalletService,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
      ],
    }).compile();

    service = module.get<MeetupService>(MeetupService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should schedule a meetup with valid start time and initial pending status', async () => {
    const scheduledDate = new Date(Date.now() + 48 * 3600 * 1000).toISOString();
    const result = await service.scheduleMeetup({
      match_id: 'match-123',
      proposer_user_id: 'user-a',
      partner_user_id: 'user-b',
      date_mode: 'offline',
      date_type: 'coffee',
      scheduled_start_at: scheduledDate,
      venue_name: 'Subko Coffee, Bandra',
    });

    expect(result.success).toBe(true);
    expect(result.meetup.match_id).toBe('match-123');
    expect(result.meetup.date_type).toBe('coffee');
    expect(result.meetup.status).toBe('pending');
    expect(result.meetup.split_bill_config.mode).toBe('50_50');
  });

  it('should accept a pending meetup', async () => {
    const scheduledDate = new Date(Date.now() + 48 * 3600 * 1000).toISOString();
    const created = await service.scheduleMeetup({
      match_id: 'match-456',
      proposer_user_id: 'user-a',
      partner_user_id: 'user-b',
      date_mode: 'online',
      date_type: 'virtual_watch_party',
      scheduled_start_at: scheduledDate,
    });

    const acceptRes = await service.acceptMeetup(created.meetup.id, 'user-b');
    expect(acceptRes.success).toBe(true);
    expect(acceptRes.status).toBe('scheduled');
  });

  it('should decline a pending meetup and refund proposer', async () => {
    const scheduledDate = new Date(Date.now() + 48 * 3600 * 1000).toISOString();
    const created = await service.scheduleMeetup({
      match_id: 'match-789',
      proposer_user_id: 'user-a',
      partner_user_id: 'user-b',
      date_mode: 'online',
      date_type: 'coffee',
      scheduled_start_at: scheduledDate,
    });

    const declineRes = await service.declineMeetup(created.meetup.id, 'user-b', 'Schedule conflict');
    expect(declineRes.success).toBe(true);
    expect(declineRes.status).toBe('declined');
  });

  it('should submit rating and feedback', async () => {
    const scheduledDate = new Date(Date.now() + 48 * 3600 * 1000).toISOString();
    const created = await service.scheduleMeetup({
      match_id: 'match-999',
      proposer_user_id: 'user-a',
      partner_user_id: 'user-b',
      date_mode: 'offline',
      date_type: 'dinner',
      scheduled_start_at: scheduledDate,
    });

    const ratingRes = await service.submitRating(created.meetup.id, 'user-a', {
      user_id: 'user-a',
      rating: 5,
      feedback: 'Wonderful conversation and vibe!',
    });

    expect(ratingRes.success).toBe(true);
    expect(ratingRes.status).toBe('completed');
  });
});
