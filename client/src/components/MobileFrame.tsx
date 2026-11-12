import React, { useEffect, useMemo, useRef, useState } from 'react';
import { BatteryFull, Monitor, Signal, Smartphone, Wifi } from 'lucide-react';

type Platform = 'ios' | 'android';

const FRAME_WIDTH = 390;
const FRAME_HEIGHT = 844;
const BEZEL = 12;
const OUTER_WIDTH = FRAME_WIDTH + BEZEL * 2;
const OUTER_HEIGHT = FRAME_HEIGHT + BEZEL * 2;
const CHROME_SPACE = 120;

const readFramePreference = () => {
  const stored = localStorage.getItem('younme:preview-frame');
  if (stored === 'on') return true;
  if (stored === 'off') return false;
  return window.innerWidth >= 700;
};

const readPlatformPreference = (): Platform =>
  localStorage.getItem('younme:preview-platform') === 'android' ? 'android' : 'ios';

const useFrameScale = () => {
  const compute = () => {
    if (typeof window === 'undefined') return 1;
    const availableHeight = window.innerHeight - CHROME_SPACE;
    const availableWidth = window.innerWidth - 32;
    return Math.max(
      0.4,
      Math.min(1, availableHeight / OUTER_HEIGHT, availableWidth / OUTER_WIDTH)
    );
  };

  const [scale, setScale] = useState(compute);

  useEffect(() => {
    const onResize = () => setScale(compute());
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

  return scale;
};

const StatusClock: React.FC = () => {
  const [now, setNow] = useState(() => new Date());

  useEffect(() => {
    const timer = window.setInterval(() => setNow(new Date()), 30000);
    return () => window.clearInterval(timer);
  }, []);

  return (
    <span>
      {now.toLocaleTimeString([], {
        hour: 'numeric',
        minute: '2-digit',
      })}
    </span>
  );
};

export const MobileFrame: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [frameEnabled, setFrameEnabled] = useState(readFramePreference);
  const [platform, setPlatform] = useState<Platform>(readPlatformPreference);
  const scale = useFrameScale();
  const iframeRef = useRef<HTMLIFrameElement>(null);

  useEffect(() => {
    localStorage.setItem('younme:preview-frame', frameEnabled ? 'on' : 'off');
  }, [frameEnabled]);

  useEffect(() => {
    localStorage.setItem('younme:preview-platform', platform);
  }, [platform]);

  useEffect(() => {
    document.body.classList.toggle('device-preview-framed', frameEnabled);
    return () => document.body.classList.remove('device-preview-framed');
  }, [frameEnabled]);

  const frameSrc = useMemo(() => {
    const url = new URL(window.location.href);
    url.searchParams.set('mobileFrame', '1');
    return url.toString();
  }, []);

  const syncIframeTheme = () => {
    const doc = iframeRef.current?.contentDocument;
    if (!doc) return;
    const isLight = doc.body.classList.contains('light-theme');
    document.body.classList.toggle('device-preview-light', isLight);
  };

  return (
    <div className={`device-preview${frameEnabled ? ' device-preview--framed' : ' device-preview--full'}`}>
      <div className="device-preview__toolbar" role="toolbar" aria-label="Device preview controls">
        <button
          type="button"
          className={`device-toggle${frameEnabled ? ' is-on' : ''}`}
          onClick={() => setFrameEnabled((value) => !value)}
          aria-pressed={frameEnabled}
        >
          <Smartphone size={15} />
          <span>Device Frame</span>
          <span className="device-toggle__track" aria-hidden="true">
            <span className="device-toggle__thumb" />
          </span>
        </button>

        {frameEnabled ? (
          <div className="device-platform" role="group" aria-label="Device platform">
            <button
              type="button"
              className={platform === 'ios' ? 'active' : ''}
              onClick={() => setPlatform('ios')}
              aria-pressed={platform === 'ios'}
            >
              iOS
            </button>
            <button
              type="button"
              className={platform === 'android' ? 'active' : ''}
              onClick={() => setPlatform('android')}
              aria-pressed={platform === 'android'}
            >
              Android
            </button>
          </div>
        ) : (
          <span className="device-preview__hint">
            <Monitor size={14} />
            Full width
          </span>
        )}
      </div>

      {frameEnabled ? (
        <div
          className="device-stage"
          style={{ width: OUTER_WIDTH * scale, height: OUTER_HEIGHT * scale }}
        >
          <div
            className={`device-frame device-frame--${platform}`}
            style={{
              width: OUTER_WIDTH,
              height: OUTER_HEIGHT,
              transform: `scale(${scale})`,
              transformOrigin: 'top left',
            }}
          >
            <div className={`device-frame__screen device-frame__screen--${platform}`}>
              <iframe
                ref={iframeRef}
                className="device-frame__iframe"
                src={frameSrc}
                title="YoUnMe mobile app preview"
                onLoad={syncIframeTheme}
              />

              <div className="device-statusbar" aria-hidden="true">
                <span className="device-statusbar__time">
                  <StatusClock />
                </span>
                <span className="device-statusbar__icons">
                  <Signal size={14} />
                  <Wifi size={14} />
                  <BatteryFull size={17} />
                </span>
              </div>

              {platform === 'ios' && <div className="device-island" aria-hidden="true" />}
              {platform === 'android' && <div className="device-punch" aria-hidden="true" />}

              <div className="device-home-indicator" aria-hidden="true" />
            </div>

            <span className="device-side-btn device-side-btn--mute" aria-hidden="true" />
            <span className="device-side-btn device-side-btn--volup" aria-hidden="true" />
            <span className="device-side-btn device-side-btn--voldown" aria-hidden="true" />
            <span className="device-side-btn device-side-btn--power" aria-hidden="true" />
          </div>
        </div>
      ) : (
        <div className="device-full">{children}</div>
      )}
    </div>
  );
};

export default MobileFrame;
