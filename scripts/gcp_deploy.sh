#!/usr/bin/env bash
# ==============================================================================
# YoUnMe Dating App — GCP Cloud Run Tri-Microservices Deployment Script
# Region: asia-south1 (Mumbai)
# Project Specification: v3.2 Master Technical Architecture
# ==============================================================================

set -euo pipefail

PROJECT_ID=${GCP_PROJECT_ID:-"younme-prod"}
REGION="asia-south1"
REPO="asia-docker.pkg.dev/${PROJECT_ID}/younme-repo"

echo "Deploying YoUnMe Microservices to GCP Cloud Run in ${REGION}..."

# 1. Build and Deploy NestJS REST API Service (0.25 vCPU, 512 MiB, concurrency 20)
echo "==> Deploying NestJS Core API Service..."
docker build -t "${REPO}/younme-api:latest" -f services/api-nestjs/Dockerfile services/api-nestjs
docker push "${REPO}/younme-api:latest"
gcloud run deploy younme-api \
  --image="${REPO}/younme-api:latest" \
  --region="${REGION}" \
  --platform=managed \
  --cpu=0.25 \
  --memory=512Mi \
  --concurrency=20 \
  --min-instances=1 \
  --max-instances=10 \
  --allow-unauthenticated \
  --set-env-vars="NODE_ENV=production,PORT=8080"

# 2. Build and Deploy Go Real-Time Engine (1.0 vCPU, 1.0 GiB, concurrency 100)
echo "==> Deploying Go Real-Time WebSocket Engine..."
docker build -t "${REPO}/younme-realtime:latest" -f services/realtime-go/Dockerfile services/realtime-go
docker push "${REPO}/younme-realtime:latest"
gcloud run deploy younme-realtime \
  --image="${REPO}/younme-realtime:latest" \
  --region="${REGION}" \
  --platform=managed \
  --cpu=1.0 \
  --memory=1Gi \
  --concurrency=100 \
  --min-instances=1 \
  --max-instances=20 \
  --allow-unauthenticated \
  --set-env-vars="PORT=8081"

# 3. Build and Deploy Cloud Run Background Worker (1.0 vCPU, 512 MiB, concurrency 10, auto-scale to 0)
echo "==> Deploying Cloud Run BullMQ Worker..."
docker build -t "${REPO}/younme-worker:latest" -f services/worker-bullmq/Dockerfile services/worker-bullmq
docker push "${REPO}/younme-worker:latest"
gcloud run deploy younme-worker \
  --image="${REPO}/younme-worker:latest" \
  --region="${REGION}" \
  --platform=managed \
  --cpu=1.0 \
  --memory=512Mi \
  --concurrency=10 \
  --min-instances=0 \
  --max-instances=5 \
  --no-allow-unauthenticated \
  --set-env-vars="NODE_ENV=production"

echo "Deployment complete! All 3 services deployed to GCP Cloud Run in ${REGION}."
