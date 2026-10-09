# Multi-stage production build for GCP Cloud Run (asia-south1)
FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod go.sum* ./
RUN go mod download || true

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o younme-realtime .

FROM alpine:3.19
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/
COPY --from=builder /app/younme-realtime .

EXPOSE 8081
ENV PORT=8081
CMD ["./younme-realtime"]
