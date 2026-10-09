# Cloud Run Background Worker Dockerfile (asia-south1)
FROM node:20-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production || npm install

COPY . .
ENV NODE_ENV=production
CMD ["node", "dist/worker.js"]
