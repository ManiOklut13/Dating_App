import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      // NestJS REST API (port 8080)
      '/v1': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
      // NestJS legacy WebSocket on port 8080
      '/ws': {
        target: 'ws://localhost:8080',
        ws: true,
        changeOrigin: true,
      },
      '/assets': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
      // Go real-time engine health (port 8081) — reachable as /rt/health
      '/rt': {
        target: 'http://localhost:8081',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/rt/, ''),
      },
      // Go real-time WebSocket (port 8081) — reachable as /ws-rt
      '/ws-rt': {
        target: 'ws://localhost:8081',
        ws: true,
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/ws-rt/, '/ws'),
      },
    },
  },
});
