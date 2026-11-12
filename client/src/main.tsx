import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { MobileFrame } from './components/MobileFrame';
import './styles/index.css';

const isEmbeddedFrame = new URLSearchParams(window.location.search).get('mobileFrame') === '1';

if (isEmbeddedFrame) {
  document.body.classList.add('mobile-frame-mode');
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    {isEmbeddedFrame ? (
      <App />
    ) : (
      <MobileFrame>
        <App />
      </MobileFrame>
    )}
  </React.StrictMode>
);
