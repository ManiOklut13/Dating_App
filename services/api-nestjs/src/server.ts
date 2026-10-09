import express, { Request, Response } from 'express';
import cors from 'cors';
import http from 'http';
import { WebSocketServer, WebSocket } from 'ws';
import path from 'path';
import { fileURLToPath } from 'url';

import { authRouter } from './auth.controller.js';
import { onboardingRouter } from './onboarding.controller.js';
import { discoveryRouter } from './discovery.controller.js';
import { chatRouter } from './chat.controller.js';
import { callsRouter } from './calls.controller.js';
import { walletRouter } from './wallet.controller.js';
import { homeRouter } from './home.controller.js';
import { workerService } from '../../worker-bullmq/src/worker.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors({ origin: '*' }));
app.use(express.json());

// Public static assets (profile pictures, photos)
const clientPublicPath = path.resolve(__dirname, '../../../client/public');
app.use('/assets', express.static(clientPublicPath));
app.use(express.static(clientPublicPath));

// Healthcheck endpoint (GCP Cloud Run probe)
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'healthy',
    service: 'YoUnMe Tri-Microservices API Gateway',
    region: 'asia-south1 (Mumbai)',
    stack: {
      api: 'NestJS RESTful Service',
      realtime: 'Go WebSocket Engine / Gateway',
      worker: 'BullMQ + Redis Worker',
      database: 'Supabase Pro PostgreSQL + PostGIS (ST_DWithin)',
      media: 'LiveKit Cloud WebRTC SFU',
    },
    timestamp: new Date().toISOString(),
  });
});

// RESTful Domain Routes
app.use('/v1/auth', authRouter);
app.use('/v1/onboarding', onboardingRouter);
app.use('/v1/discovery', discoveryRouter);
app.use('/v1', discoveryRouter); // Handles /v1/swipes
app.use('/v1', chatRouter);      // Handles /v1/matches, /v1/messages, /v1/connect/*
app.use('/v1/calls', callsRouter);
app.use('/v1/wallet', walletRouter);
app.use('/v1/home', homeRouter);

// Vision AI Worker Endpoint
app.post('/v1/worker/vision-scan', async (req: Request, res: Response) => {
  const result = await workerService.processVisionScan(req.body);
  res.json({ success: true, scan_result: result });
});

// Create HTTP Server
const server = http.createServer(app);

// WebSocket Server (Port 8080 /ws path, mirroring Go microservice)
const wss = new WebSocketServer({ server, path: '/ws' });

interface WsClient {
  ws: WebSocket;
  userId: string;
  channels: Set<string>;
}
const clients = new Map<WebSocket, WsClient>();

// Channel subscriptions map
const channelSubs = new Map<string, Set<WebSocket>>();

function broadcastToChannel(channel: string, event: string, payload: any) {
  const subscribers = channelSubs.get(channel);
  if (!subscribers) return;

  const msg = JSON.stringify({
    channel,
    event,
    payload,
    timestamp: Date.now(),
  });

  for (const clientWs of subscribers) {
    if (clientWs.readyState === WebSocket.OPEN) {
      clientWs.send(msg);
    }
  }
}

wss.on('connection', (ws: WebSocket, req) => {
  const urlParams = new URLSearchParams(req.url?.split('?')[1] || '');
  const userId = urlParams.get('user_id') || '11111111-1111-1111-1111-111111111111';

  const client: WsClient = {
    ws,
    userId,
    channels: new Set(),
  };
  clients.set(ws, client);

  // Auto-subscribe to user-specific channel and presence
  const userChan = `user:${userId}`;
  const presenceChan = `presence:${userId}`;

  [userChan, presenceChan, 'presence:global'].forEach((ch) => {
    client.channels.add(ch);
    if (!channelSubs.has(ch)) channelSubs.set(ch, new Set());
    channelSubs.get(ch)!.add(ws);
  });

  // Broadcast presence
  broadcastToChannel('presence:global', 'presence:online', { user_id: userId, status: 'online' });

  console.log(`[RealTime WebSocket] Connected user: ${userId}`);

  ws.on('message', (data: string) => {
    try {
      const parsed = JSON.parse(data.toString());
      const { channel, event, payload } = parsed;

      if (event === 'subscribe' && typeof payload === 'string') {
        client.channels.add(payload);
        if (!channelSubs.has(payload)) channelSubs.set(payload, new Set());
        channelSubs.get(payload)!.add(ws);
        console.log(`[RealTime WebSocket] User ${userId} subscribed to ${payload}`);
        return;
      }

      if (event === 'unsubscribe' && typeof payload === 'string') {
        client.channels.delete(payload);
        channelSubs.get(payload)?.delete(ws);
        return;
      }

      // Forward events to channel subscribers (chat messages, typing, call signals)
      if (channel) {
        broadcastToChannel(channel, event, payload);
      }
    } catch (e) {
      console.error('[RealTime WebSocket] Message parse error:', e);
    }
  });

  ws.on('close', () => {
    for (const ch of client.channels) {
      channelSubs.get(ch)?.delete(ws);
    }
    clients.delete(ws);
    broadcastToChannel('presence:global', 'presence:offline', { user_id: userId, status: 'offline' });
    console.log(`[RealTime WebSocket] Disconnected user: ${userId}`);
  });
});

// Start Worker
workerService.start();

// Launch Server
server.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(`🚀 YoUnMe Backend Service running on http://localhost:${PORT}`);
  console.log(`⚡ WebSocket Real-Time Engine ready at ws://localhost:${PORT}/ws`);
  console.log(`🛡️  Contact Guard & Google Cloud Vision AI Active`);
  console.log(`💰 Double-Entry Ledger Engine Running`);
  console.log(`=======================================================`);
});
