# Production Dockerfile for NestJS / Express API on Google Cloud Run (asia-south1)
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build || true

FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY --from=builder /app ./

EXPOSE 8080
ENV PORT=8080
ENV NODE_ENV=production

CMD ["npm", "start"]
