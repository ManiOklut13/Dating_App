# ─────────────────────────────────────────────────────────────────────────────
# YoUnMe — Background Worker Dockerfile
# Target: Google Cloud Run (asia-south1 Mumbai)
# Config: 1 vCPU, 512 MiB RAM, min-instances=1 (avoids cold-start on first job)
# ─────────────────────────────────────────────────────────────────────────────

# ── Stage 1: Build ────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies first (layer-caching)
COPY package*.json ./
RUN npm ci --include=dev

# Copy source and compile TypeScript
COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build

# ── Stage 2: Production image ─────────────────────────────────────────────────
FROM node:20-alpine AS production

# Non-root user for Cloud Run security best practices
RUN addgroup -S worker && adduser -S worker -G worker

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy compiled output from builder stage
COPY --from=builder /app/dist ./dist

# Do NOT copy src/ or tsconfig.json into the production image

USER worker

ENV NODE_ENV=production

# Cloud Run supplies PORT; worker exposes GET /health on PORT for startup/liveness probes.
ENV PORT=8082
EXPOSE 8082

# Structured log output (single-line JSON is preferred by Cloud Logging)
ENV NODE_OPTIONS="--enable-source-maps"

# The worker process must not exit after processing a single job.
# It stays alive waiting for new Redis jobs until SIGTERM is received.
CMD ["node", "dist/index.js"]
