import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import express, { Request, Response } from 'express';
import path from 'path';
import { WebSocketServer, WebSocket } from 'ws';
import { AppModule } from './app.module.js';

// Legacy domain routers to preserve teammates' full feature set
import { authRouter } from './auth.controller.js';
import { onboardingRouter } from './onboarding.controller.js';
import { discoveryRouter } from './discovery.controller.js';
import { chatRouter } from './chat.controller.js';
import { callsRouter } from './calls.controller.js';
import { walletRouter } from './wallet.controller.js';
import { homeRouter } from './home.controller.js';
import { workerService } from '../../worker-bullmq/src/worker.js';

export async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const allowedOrigins = (process.env.ALLOWED_ORIGINS || '')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);

  const defaultOrigins = [
    'http://localhost:5173',
    'http://localhost:3000',
    'http://localhost:8080',
    'http://127.0.0.1:5173',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:8080',
  ];

  const origins = Array.from(new Set([...allowedOrigins, ...defaultOrigins]));

  app.enableCors({
    origin: (requestOrigin, callback) => {
      // Allow requests with no origin (e.g. mobile apps, curl, Postman)
      if (!requestOrigin) return callback(null, true);

      // In development or if origin matches allowed list or localhost regex
      if (
        process.env.NODE_ENV !== 'production' ||
        origins.includes(requestOrigin) ||
        /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(requestOrigin)
      ) {
        return callback(null, true);
      }

      return callback(new Error(`CORS blocked for origin: ${requestOrigin}`), false);
    },
    methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
      'Origin',
      'X-Requested-With',
      'Content-Type',
      'Accept',
      'Authorization',
      'apikey',
      'X-Client-Info',
      'prefer',
    ],
    exposedHeaders: ['Content-Range', 'X-Total-Count'],
    credentials: true,
    preflightContinue: false,
    optionsSuccessStatus: 204,
  });

  // Configure Global /v1 prefix
  app.setGlobalPrefix('v1', {
    exclude: ['health', 'ws', 'docs', 'v1/docs', 'assets', 'assets/{*path}'],
  });

  // Setup Swagger / OpenAPI Documentation
  const swaggerConfig = new DocumentBuilder()
    .setTitle('YoUnMe Dating App API')
    .setDescription(
      'YoUnMe RESTful Core API Gateway with Supabase Authentication, Discovery, Calls, and Ledger.',
    )
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'Authorization',
        description: 'Provide a valid Supabase access token (Bearer <token>)',
        in: 'header',
      },
      'supabase-auth',
    )
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('v1/docs', app, document);
  SwaggerModule.setup('docs', app, document);

  // Mount legacy Express routes and static files seamlessly
  const expressApp = app.getHttpAdapter().getInstance();
  const clientPublicPath = path.resolve(process.cwd(), '../../client/public');
  expressApp.use('/assets', express.static(clientPublicPath));
  expressApp.use(express.static(clientPublicPath));

  // Healthcheck endpoint (GCP Cloud Run probe)
  expressApp.get('/health', (req: Request, res: Response) => {
    res.json({
      status: 'healthy',
      service: 'YoUnMe Tri-Microservices API Gateway',
      region: 'asia-south1 (Mumbai)',
      stack: {
        api: 'NestJS RESTful Service',
        realtime: 'Go WebSocket Engine / Gateway',
        worker: 'BullMQ + Redis Worker',
        database: 'PostgreSQL + PostGIS',
        media: 'LiveKit Cloud WebRTC SFU',
        auth: 'Supabase Authentication (GoTrue access tokens)',
      },
      timestamp: new Date().toISOString(),
    });
  });

  // Preserve legacy routes under /v1
  expressApp.use('/v1/onboarding', onboardingRouter);
  expressApp.use('/v1/discovery', discoveryRouter);
  expressApp.use('/v1', discoveryRouter); // Handles /v1/swipes
  expressApp.use('/v1', chatRouter); // Handles /v1/matches, /v1/messages, /v1/connect/*
  expressApp.use('/v1/calls', callsRouter);
  expressApp.use('/v1/wallet', walletRouter);
  expressApp.use('/v1/home', homeRouter);

  // Fallback to legacy OTP / logout handlers for /v1/auth
  expressApp.use('/v1/auth', authRouter);

  // Vision AI Worker Endpoint
  expressApp.post('/v1/worker/vision-scan', async (req: Request, res: Response) => {
    const result = await workerService.processVisionScan(req.body);
    res.json({ success: true, scan_result: result });
  });

  // WebSocket Server Setup on the underlying HTTP server
  const httpServer = app.getHttpServer();
  const wss = new WebSocketServer({ server: httpServer, path: '/ws' });

  interface WsClient {
    ws: WebSocket;
    userId: string;
    channels: Set<string>;
  }
  const clients = new Map<WebSocket, WsClient>();
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

    const userChan = `user:${userId}`;
    const presenceChan = `presence:${userId}`;

    [userChan, presenceChan, 'presence:global'].forEach((ch) => {
      client.channels.add(ch);
      if (!channelSubs.has(ch)) channelSubs.set(ch, new Set());
      channelSubs.get(ch)!.add(ws);
    });

    broadcastToChannel('presence:global', 'presence:online', {
      user_id: userId,
      status: 'online',
    });

    ws.on('message', (data: string) => {
      try {
        const parsed = JSON.parse(data.toString());
        const { channel, event, payload } = parsed;

        if (event === 'subscribe' && typeof payload === 'string') {
          client.channels.add(payload);
          if (!channelSubs.has(payload)) channelSubs.set(payload, new Set());
          channelSubs.get(payload)!.add(ws);
          return;
        }

        if (event === 'unsubscribe' && typeof payload === 'string') {
          client.channels.delete(payload);
          channelSubs.get(payload)?.delete(ws);
          return;
        }

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
      broadcastToChannel('presence:global', 'presence:offline', {
        user_id: userId,
        status: 'offline',
      });
    });
  });

  // Start Worker
  workerService.start();

  const PORT = process.env.PORT || 8080;
  await app.listen(PORT);

  console.log(`=======================================================`);
  console.log(`🚀 YoUnMe NestJS Backend Service running on http://localhost:${PORT}`);
  console.log(`📖 Swagger API Documentation available at http://localhost:${PORT}/v1/docs`);
  console.log(`⚡ WebSocket Real-Time Engine ready at ws://localhost:${PORT}/ws`);
  console.log(`🛡️  Contact Guard & Google Cloud Vision AI Active`);
  console.log(`💰 Double-Entry Ledger Engine Running`);
  console.log(`=======================================================`);

  return app;
}

if (process.env.NODE_ENV !== 'test') {
  bootstrap();
}
