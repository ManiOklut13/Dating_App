/**
 * Procedural call SFX synthesizer (Web Audio API).
 * All sounds are generated at runtime — no audio assets required.
 *
 * Handlers:
 *   ensureAudio()          – lazily create/unlock the AudioContext on user gesture
 *   playRingback()         – 440+480 Hz US-style ring, pulses every 5s until stopped
 *   stopRingback()         – kill the ringback loop
 *   playConnectBeep()      – short two-note ascending confirmation blip
 *   playDtmf(key)          – standards-compliant DTMF dual-tone per keypad key
 *   playClick()            – tiny UI tick for toggles (mic, camera, speaker)
 *   playDisconnect()       – descending "call ended" sweep with low thud
 */

let ctx: AudioContext | null = null;

export const ensureAudio = (): AudioContext | null => {
  try {
    if (!ctx) {
      const AC: typeof AudioContext | undefined =
        window.AudioContext || (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
      if (!AC) return null;
      ctx = new AC();
    }
    if (ctx.state === 'suspended') {
      void ctx.resume().catch(() => undefined);
    }
    return ctx;
  } catch {
    return null;
  }
};

/* Generic one-shot tone with a soft attack/release envelope. */
const playTone = (
  freqs: number[],
  durationMs: number,
  volume = 0.08,
  type: OscillatorType = 'sine',
) => {
  const ac = ensureAudio();
  if (!ac) return;
  const gain = ac.createGain();
  gain.connect(ac.destination);
  const t = ac.currentTime;
  gain.gain.setValueAtTime(0, t);
  gain.gain.linearRampToValueAtTime(volume, t + 0.015);
  gain.gain.setValueAtTime(volume, t + durationMs / 1000 - 0.02);
  gain.gain.linearRampToValueAtTime(0, t + durationMs / 1000);
  freqs.forEach((f) => {
    const osc = ac.createOscillator();
    osc.type = type;
    osc.frequency.setValueAtTime(f, t);
    osc.connect(gain);
    osc.start(t);
    osc.stop(t + durationMs / 1000);
  });
};

/* ---------- ringback loop ---------- */
interface RingbackHandle {
  gain: GainNode;
  oscillators: OscillatorNode[];
  intervalId: number;
}
let ringback: RingbackHandle | null = null;

export const playRingback = (): void => {
  stopRingback();
  const ac = ensureAudio();
  if (!ac) return;
  const gain = ac.createGain();
  gain.gain.setValueAtTime(0, ac.currentTime);
  gain.connect(ac.destination);

  const oscillators = [440, 480].map((f) => {
    const osc = ac.createOscillator();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(f, ac.currentTime);
    osc.connect(gain);
    osc.start();
    return osc;
  });

  // 1.2s ring pulse every 5 seconds (US ringback cadence)
  const pulse = () => {
    const t = ac.currentTime;
    gain.gain.cancelScheduledValues(t);
    gain.gain.setValueAtTime(0, t);
    gain.gain.linearRampToValueAtTime(0.07, t + 0.05);
    gain.gain.setValueAtTime(0.07, t + 1.05);
    gain.gain.linearRampToValueAtTime(0, t + 1.2);
  };
  pulse();
  const intervalId = window.setInterval(pulse, 5000);
  ringback = { gain, oscillators, intervalId };
};

export const stopRingback = (): void => {
  if (!ringback) return;
  const { gain, oscillators, intervalId } = ringback;
  ringback = null;
  window.clearInterval(intervalId);
  try {
    const ac = ensureAudio();
    if (ac) {
      const t = ac.currentTime;
      gain.gain.cancelScheduledValues(t);
      gain.gain.setValueAtTime(gain.gain.value, t);
      gain.gain.linearRampToValueAtTime(0, t + 0.05);
      oscillators.forEach((o) => o.stop(t + 0.08));
    }
  } catch {
    /* context may already be closed */
  }
};

/* ---------- one-shot SFX ---------- */
export const playConnectBeep = (): void => {
  const ac = ensureAudio();
  if (!ac) return;
  playTone([950], 140, 0.09);
  window.setTimeout(() => playTone([1250], 180, 0.09), 150);
};

export const playDisconnect = (): void => {
  const ac = ensureAudio();
  if (!ac) return;
  const t = ac.currentTime;
  const osc = ac.createOscillator();
  const gain = ac.createGain();
  osc.type = 'sine';
  gain.gain.setValueAtTime(0.09, t);
  gain.gain.linearRampToValueAtTime(0, t + 0.38);
  osc.frequency.setValueAtTime(760, t);
  osc.frequency.exponentialRampToValueAtTime(280, t + 0.36);
  osc.connect(gain);
  gain.connect(ac.destination);
  osc.start(t);
  osc.stop(t + 0.4);
  window.setTimeout(() => playTone([180, 120], 120, 0.12, 'triangle'), 330);
};

export const playClick = (): void => {
  playTone([1800], 40, 0.045, 'square');
};

/* ---------- DTMF keypad tones (ITU-T Q.23 frequencies) ---------- */
const DTMF_FREQS: Record<string, [number, number]> = {
  '1': [697, 1209],
  '2': [697, 1336],
  '3': [697, 1477],
  '4': [770, 1209],
  '5': [770, 1336],
  '6': [770, 1477],
  '7': [852, 1209],
  '8': [852, 1336],
  '9': [852, 1477],
  '*': [941, 1209],
  '0': [941, 1336],
  '#': [941, 1477],
};

export const playDtmf = (key: string): void => {
  const freqs = DTMF_FREQS[key];
  if (freqs) playTone(freqs, 160, 0.09);
};
