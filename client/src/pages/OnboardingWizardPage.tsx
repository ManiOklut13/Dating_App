import React, { useState, useEffect, useRef } from 'react';
import {
  ChevronLeft,
  Sparkles,
  Camera,
  CheckCircle2,
  Mic,
  ShieldCheck,
  MapPin,
  Flame,
  ArrowRight,
  Upload,
  Calendar,
  Lock,
  Compass,
  Check,
  Plus,
  Trash2,
  Volume2,
  Eye,
  EyeOff,
  AlertCircle,
  Smartphone,
  Mail,
  Palette,
  Shield,
  Search,
  Send,
  Loader2,
  Heart,
  Radio,
  User,
  Users,
  Sliders,
  CheckCheck,
} from 'lucide-react';
import confetti from 'canvas-confetti';

export interface OnboardingProfileData {
  email: string;
  firstName: string;
  lastName: string;
  phone: string;
  userType?: 'standard' | 'verified' | 'creator';
  password?: string;
  birthDate: string;
  gender: string;
  orientation: string;
  primaryPhoto: string;
  autoEnhanced: boolean;
  intent: string;
  interests: string[];
  interestedIn?: string[];
  profession: string;
  education: string;
  city?: string;
  height: string;
  languages: string[];
  bio: string;
  galleryPhotos: string[];
  location: string;
  maxDistance: number;
  ageRangeMax: number;
  allowNotifications: boolean;
  allowLocation: boolean;
  whoCanMessage: 'everyone' | 'matches' | 'verified';
  isVoiceVerified: boolean;
  isFaceVerified: boolean;
  allowContactsSync?: boolean;
}

interface OnboardingWizardPageProps {
  onBack: () => void;
  onComplete: (userProfile: OnboardingProfileData) => void;
  onGoToSignIn: () => void;
}

// Romantic Intent Options
const INTENT_OPTIONS = [
  { id: 'long-term', icon: '💍', label: 'Long-term relationship', desc: 'Seeking deep connection, loyalty & life partnership.' },
  { id: 'short-term', icon: '🍷', label: 'Short-term dating', desc: 'Open to romance, fun dates & seeing where things lead.' },
  { id: 'casual', icon: '🥂', label: 'Casual dating', desc: 'Lighthearted conversations & weekend spontaneous hangouts.' },
  { id: 'friendship', icon: '✨', label: 'Friendship', desc: 'Meaningful platonic connections & shared passions.' },
  { id: 'new-connections', icon: '🤝', label: 'New connections', desc: 'Expanding my circle and meeting interesting people.' },
  { id: 'not-sure', icon: '💫', label: 'Not sure yet', desc: 'Open-minded and exploring what life brings.' },
  { id: 'something-else', icon: '🌈', label: 'Something else', desc: 'Unique romantic or personal connection on my own terms.' },
];

// Curated Interest Pills
const INTEREST_OPTIONS = [
  { id: 'music', label: 'Music 🎵' },
  { id: 'coffee', label: 'Coffee ☕' },
  { id: 'travel', label: 'Travel ✈️' },
  { id: 'fitness', label: 'Fitness 💪' },
  { id: 'photography', label: 'Photography 📸' },
  { id: 'foodie', label: 'Foodie 🍕' },
  { id: 'movies', label: 'Movies 🎬' },
  { id: 'gaming', label: 'Gaming 🎮' },
  { id: 'art', label: 'Modern Art 🎨' },
  { id: 'books', label: 'Reading 📚' },
  { id: 'nature', label: 'Hiking 🌿' },
  { id: 'tech', label: 'Tech & AI 💻' },
];

// Preset Avatars for Instant Selection
const PRESET_AVATARS = [
  '/ananya.jpg',
  '/aditya.jpg',
  '/kavya.jpg',
  '/zoya.jpg',
  '/arjun.jpg',
  '/dev.jpg',
];

export const OnboardingWizardPage: React.FC<OnboardingWizardPageProps> = ({
  onBack,
  onComplete,
  onGoToSignIn,
}) => {
  const [currentStep, setCurrentStep] = useState<number>(1);
  const [step1SubPage, setStep1SubPage] = useState<'A' | 'B'>('A');
  const [userType, setUserType] = useState<'standard' | 'verified' | 'creator'>('standard');
  const [step1AError, setStep1AError] = useState<string | null>(null);
  const [step1BError, setStep1BError] = useState<string | null>(null);

  // STEP 1 STATE: Account & Credentials
  const [firstName, setFirstName] = useState('Aarav');
  const [lastName, setLastName] = useState('Kapoor');
  const [email, setEmail] = useState('aarav.kapoor@younme.love');
  const [phone, setPhone] = useState('98765 43210');
  const [password, setPassword] = useState('Love@2026');
  const [confirmPassword, setConfirmPassword] = useState('Love@2026');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  // Send OTP States
  const [isSendingEmailOtp, setIsSendingEmailOtp] = useState(false);
  const [isSendingPhoneOtp, setIsSendingPhoneOtp] = useState(false);
  const [emailOtpSent, setEmailOtpSent] = useState(false);
  const [phoneOtpSent, setPhoneOtpSent] = useState(false);
  const [otpSentTarget, setOtpSentTarget] = useState<'email' | 'phone' | null>(null);
  const [activeContactMethod, setActiveContactMethod] = useState<'email' | 'phone'>('email');
  const [otpDigits, setOtpDigits] = useState<string[]>(['2', '0', '2', '6']);
  const [otpTimer, setOtpTimer] = useState<number>(45);
  const [emailFeedback, setEmailFeedback] = useState<string | null>(null);
  const [phoneFeedback, setPhoneFeedback] = useState<string | null>(null);

  const emailInputRef = useRef<HTMLInputElement | null>(null);
  const phoneInputRef = useRef<HTMLInputElement | null>(null);
  const otpRefs = useRef<(HTMLInputElement | null)[]>([]);

  // STEP 2 STATE: Basic Profile Details
  const [birthDay, setBirthDay] = useState('15');
  const [birthMonth, setBirthMonth] = useState('06');
  const [birthYear, setBirthYear] = useState('2000');
  const [gender, setGender] = useState<'Male' | 'Female' | 'Non-Binary'>('Male');
  const [orientation, setOrientation] = useState('Straight');
  const [primaryPhoto, setPrimaryPhoto] = useState<string>('/aditya.jpg');
  const [autoEnhanced, setAutoEnhanced] = useState(true);
  const photoInputRef = useRef<HTMLInputElement | null>(null);

  // STEP 3 STATE: Match Preferences & Interests
  const [intent, setIntent] = useState('long-term');
  const [interests, setInterests] = useState<string[]>(['music', 'coffee', 'travel', 'photography']);
  const [customInterestInput, setCustomInterestInput] = useState('');

  // STEP 4 STATE: Profile Enrichment & Discovery Sliders
  const [profession, setProfession] = useState('UI/UX Architect');
  const [education, setEducation] = useState('IIT Bombay');
  const [bio, setBio] = useState('Passionate about clean design, acoustic sunsets, and cozy weekend cafes ✨');
  const [city, setCity] = useState('Mumbai, Bandra West');
  const [maxAge, setMaxAge] = useState<number>(32);
  const [maxDistance, setMaxDistance] = useState<number>(25);
  const [isDetectingCity, setIsDetectingCity] = useState(false);

  // STEP 5 STATE: Verification & Permissions
  const [allowNotifications, setAllowNotifications] = useState(true);
  const [allowLocation, setAllowLocation] = useState(true);
  const [whoCanMessage, setWhoCanMessage] = useState<'everyone' | 'matches' | 'verified'>('matches');
  const [isVoiceRecording, setIsVoiceRecording] = useState(false);
  const [isVoiceVerified, setIsVoiceVerified] = useState(true);
  const [isFaceScanning, setIsFaceScanning] = useState(false);
  const [isFaceVerified, setIsFaceVerified] = useState(true);
  const [allowContactsSync, setAllowContactsSync] = useState(false);

  // OTP Countdown timer
  useEffect(() => {
    let interval: ReturnType<typeof setInterval>;
    if (otpTimer > 0) {
      interval = setInterval(() => setOtpTimer((t) => (t > 0 ? t - 1 : 0)), 1000);
    }
    return () => clearInterval(interval);
  }, [otpTimer]);

  // Handle Send OTP to Email
  const handleSendEmailOtp = () => {
    if (!email.trim() || !email.includes('@')) {
      setEmailFeedback('Please enter a valid email address.');
      emailInputRef.current?.focus();
      return;
    }
    setIsSendingEmailOtp(true);
    setEmailFeedback(null);
    setTimeout(() => {
      setIsSendingEmailOtp(false);
      setEmailOtpSent(true);
      setOtpSentTarget('email');
      setActiveContactMethod('email');
      setOtpTimer(45);
      setOtpDigits(['2', '0', '2', '6']);
      setEmailFeedback(`Code sent to ${email}`);
      otpRefs.current[0]?.focus();
    }, 450);
  };

  // Handle Send OTP to Phone
  const handleSendPhoneOtp = () => {
    const cleaned = phone.replace(/\D/g, '');
    if (cleaned.length < 8) {
      setPhoneFeedback('Please enter at least 8 digits.');
      phoneInputRef.current?.focus();
      return;
    }
    setIsSendingPhoneOtp(true);
    setPhoneFeedback(null);
    setTimeout(() => {
      setIsSendingPhoneOtp(false);
      setPhoneOtpSent(true);
      setOtpSentTarget('phone');
      setActiveContactMethod('phone');
      setOtpTimer(45);
      setOtpDigits(['2', '0', '2', '6']);
      setPhoneFeedback(`SMS code sent to +91 ${phone}`);
      otpRefs.current[0]?.focus();
    }, 450);
  };

  const handleToggleOrMethod = () => {
    if (activeContactMethod === 'email') {
      setActiveContactMethod('phone');
      phoneInputRef.current?.focus();
    } else {
      setActiveContactMethod('email');
      emailInputRef.current?.focus();
    }
  };

  // Toggle Interest Tag
  const toggleInterest = (id: string) => {
    setInterests((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  // Add Custom Interest Tag
  const handleAddCustomInterest = () => {
    const trimmed = customInterestInput.trim();
    if (trimmed && !interests.includes(trimmed)) {
      setInterests((prev) => [...prev, trimmed]);
      setCustomInterestInput('');
    }
  };

  // Auto detect location
  const handleAutoDetectCity = () => {
    setIsDetectingCity(true);
    setTimeout(() => {
      setIsDetectingCity(false);
      setCity('Mumbai, Bandra West (GPS Active)');
    }, 600);
  };

  // Photo file upload
  const handlePhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        if (event.target?.result) {
          setPrimaryPhoto(event.target.result as string);
        }
      };
      reader.readAsDataURL(file);
    }
  };

  // Voice recording simulation
  const handleVoiceRecordToggle = () => {
    if (isVoiceRecording) {
      setIsVoiceRecording(false);
      setIsVoiceVerified(true);
    } else {
      setIsVoiceRecording(true);
      setTimeout(() => {
        setIsVoiceRecording(false);
        setIsVoiceVerified(true);
      }, 2500);
    }
  };

  // Face scanning simulation
  const handleFaceScan = () => {
    setIsFaceScanning(true);
    setTimeout(() => {
      setIsFaceScanning(false);
      setIsFaceVerified(true);
    }, 2200);
  };

  // Step 1 Validation
  const hasValidContact =
    (email.trim().length > 0 && email.includes('@')) ||
    phone.replace(/\D/g, '').length >= 8;

  const isStep1Valid =
    firstName.trim().length >= 1 &&
    hasValidContact &&
    password.length >= 6 &&
    password === confirmPassword;

  // Next / Back handlers
  const handleNext = () => {
    if (currentStep < 5) {
      setCurrentStep((s) => s + 1);
    } else {
      // Step 5 Finish: Confetti and Complete
      try {
        confetti({
          particleCount: 80,
          spread: 70,
          origin: { y: 0.6 },
          colors: ['#ff8da1', '#ff4d88', '#ffffff', '#ffd700'],
        });
      } catch {
        // Safe fallback
      }
      setTimeout(() => {
        onComplete({
          firstName,
          lastName,
          email,
          phone,
          userType,
          password,
          birthDate: `${birthYear}-${birthMonth}-${birthDay}`,
          gender,
          orientation,
          primaryPhoto,
          autoEnhanced,
          intent,
          interests,
          profession,
          education,
          city,
          height: `5' 11"`,
          languages: ['English', 'Hindi'],
          bio,
          galleryPhotos: [primaryPhoto, '/arjun.jpg', '/dev.jpg'],
          location: city,
          maxDistance,
          ageRangeMax: maxAge,
          allowNotifications,
          allowLocation,
          whoCanMessage,
          isVoiceVerified,
          isFaceVerified,
          allowContactsSync,
        });
      }, 500);
    }
  };

  const handleBackStep = () => {
    if (currentStep === 1) {
      if (step1SubPage === 'B') {
        setStep1SubPage('A');
        setStep1BError(null);
      } else {
        onBack();
      }
    } else if (currentStep > 1) {
      if (currentStep === 2) {
        setCurrentStep(1);
        setStep1SubPage('B');
      } else {
        setCurrentStep((s) => s - 1);
      }
    }
  };

  const handleContinueFrom1A = () => {
    if (!firstName.trim()) {
      setStep1AError('Please enter your first name.');
      return;
    }
    if (!lastName.trim()) {
      setStep1AError('Please enter your last name.');
      return;
    }
    if (!email.trim() || !email.includes('@')) {
      setStep1AError('Please enter a valid email address.');
      return;
    }
    const cleanPhone = phone.replace(/\D/g, '');
    if (cleanPhone.length < 8) {
      setStep1AError('Please enter a valid phone number.');
      return;
    }
    setStep1AError(null);
    setStep1SubPage('B');
  };

  const handleVerifyAndContinueToStep2 = () => {
    const enteredOtp = otpDigits.join('');
    if (enteredOtp.length < 4) {
      setStep1BError('Please enter the 4-digit verification code.');
      return;
    }
    if (!password || password.length < 6) {
      setStep1BError('Password must be at least 6 characters.');
      return;
    }
    if (password !== confirmPassword) {
      setStep1BError('Passwords do not match. Please verify both fields.');
      return;
    }
    setStep1BError(null);
    setCurrentStep(2);
  };

  const handleSocialSelect = (provider: 'google' | 'apple' | 'facebook') => {
    if (provider === 'google') {
      setFirstName('Aarav');
      setLastName('Kapoor');
      setEmail('aarav.google@younme.love');
      setPhone('98765 43210');
    } else if (provider === 'apple') {
      setFirstName('Aarav');
      setLastName('Kapoor');
      setEmail('aarav.apple@younme.love');
      setPhone('98765 43210');
    } else {
      setFirstName('Aarav');
      setLastName('Kapoor');
      setEmail('aarav.fb@younme.love');
      setPhone('98765 43210');
    }
    setOtpDigits(['2', '0', '2', '6']);
    setStep1AError(null);
    setStep1SubPage('B');
  };

  return (
    <div className="auth-page-wrapper">
      {/* Ambient pink glow circles */}
      <div className="ambient-glow-pink ambient-glow-top-right" />
      <div className="ambient-glow-pink ambient-glow-mid-left" />

      {/* Main Top Header: Back Button + Step Progress Bar */}
      <div className="auth-nav-header">
        <button
          type="button"
          onClick={handleBackStep}
          className="auth-nav-btn"
          aria-label="Go Back"
        >
          <ChevronLeft size={20} />
        </button>

        <div className="auth-progress-container">
          <div className="auth-progress-text">
            <span>Step {currentStep} of 5</span>
            <span style={{ color: '#ffffff' }}>
              {currentStep === 1
                ? (step1SubPage === 'A' ? "Let's get started" : 'Verify & Security')
                : currentStep === 2
                  ? 'Profile'
                  : currentStep === 3
                    ? 'Intent & Vibe'
                    : currentStep === 4
                      ? 'Story'
                      : 'Verification'}
            </span>
          </div>
          <div className="auth-progress-track">
            <div
              className="auth-progress-fill"
              style={{
                width: currentStep === 1
                  ? (step1SubPage === 'A' ? '10%' : '20%')
                  : `${(currentStep / 5) * 100}%`
              }}
            />
          </div>
        </div>
      </div>

      {/* Dynamic Content Per Step */}
      <div style={{ flex: 1, position: 'relative', zIndex: 5, overflowY: 'auto', paddingRight: '2px' }}>
        {/* ========================================================= */}
        {/* STEP 1: Let's Get Started (Two Sequential Sub-Pages)     */}
        {/* ========================================================= */}
        {currentStep === 1 && step1SubPage === 'A' && (
          <div>
            <h1 className="auth-step-title">Let's get started</h1>
            <p className="auth-step-subtitle" style={{ color: '#94a3b8' }}>
              Enter your details or continue with a social account.
            </p>

            {step1AError && (
              <div className="auth-error-banner">
                <AlertCircle size={14} />
                <span>{step1AError}</span>
              </div>
            )}

            {/* First Name & Last Name Grid */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', marginBottom: '12px' }}>
              <div className="form-field-group" style={{ marginBottom: 0 }}>
                <label className="form-field-label">
                  <span className="form-field-label-text" style={{ color: '#f8fafc' }}>
                    <User size={13} color="#f43f5e" /> First Name
                  </span>
                </label>
                <div className="form-field-input-wrap" style={{ background: '#191c24', borderColor: 'rgba(255, 255, 255, 0.08)' }}>
                  <input
                    type="text"
                    value={firstName}
                    onChange={(e) => {
                      setFirstName(e.target.value);
                      if (step1AError) setStep1AError(null);
                    }}
                    placeholder="Aarav"
                    className="form-field-input"
                    required
                  />
                </div>
              </div>

              <div className="form-field-group" style={{ marginBottom: 0 }}>
                <label className="form-field-label">
                  <span className="form-field-label-text" style={{ color: '#f8fafc' }}>Last Name</span>
                </label>
                <div className="form-field-input-wrap" style={{ background: '#191c24', borderColor: 'rgba(255, 255, 255, 0.08)' }}>
                  <input
                    type="text"
                    value={lastName}
                    onChange={(e) => {
                      setLastName(e.target.value);
                      if (step1AError) setStep1AError(null);
                    }}
                    placeholder="Kapoor"
                    className="form-field-input"
                  />
                </div>
              </div>
            </div>

            {/* Email Address */}
            <div className="form-field-group">
              <label className="form-field-label">
                <span className="form-field-label-text" style={{ color: '#f8fafc' }}>
                  <Mail size={13} color="#f43f5e" /> Email Address
                </span>
              </label>
              <div className="form-field-input-wrap" style={{ background: '#191c24', borderColor: 'rgba(255, 255, 255, 0.08)' }}>
                <input
                  ref={emailInputRef}
                  type="email"
                  value={email}
                  onChange={(e) => {
                    setEmail(e.target.value);
                    if (step1AError) setStep1AError(null);
                  }}
                  placeholder="name@example.com"
                  className="form-field-input"
                />
              </div>
            </div>

            {/* Phone Number with Country Code */}
            <div className="form-field-group">
              <label className="form-field-label">
                <span className="form-field-label-text" style={{ color: '#f8fafc' }}>
                  <Smartphone size={13} color="#f43f5e" /> Phone Number
                </span>
              </label>
              <div className="phone-input-row">
                <div className="country-code-pill" style={{ background: '#191c24', borderColor: 'rgba(255, 255, 255, 0.08)', color: '#f8fafc' }}>
                  <span>🇮🇳 +91</span>
                </div>
                <div className="form-field-input-wrap" style={{ flex: 1, background: '#191c24', borderColor: 'rgba(255, 255, 255, 0.08)' }}>
                  <input
                    ref={phoneInputRef}
                    type="tel"
                    value={phone}
                    onChange={(e) => {
                      setPhone(e.target.value);
                      if (step1AError) setStep1AError(null);
                    }}
                    placeholder="98765 43210"
                    className="form-field-input"
                  />
                </div>
              </div>
            </div>

            {/* Primary Action Button: Continue to Page 1B */}
            <button
              type="button"
              onClick={handleContinueFrom1A}
              className="btn-rose-primary"
              style={{ width: '100%', marginTop: '8px' }}
            >
              <span>Continue</span>
              <ArrowRight size={17} />
            </button>

            {/* Clean Horizontal Divider with "or" */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', margin: '16px 0 12px' }}>
              <div style={{ flex: 1, height: '1px', background: 'rgba(255, 255, 255, 0.1)' }} />
              <span style={{ fontSize: '11px', color: '#94a3b8', textTransform: 'uppercase', fontWeight: 700, letterSpacing: '0.6px' }}>
                or
              </span>
              <div style={{ flex: 1, height: '1px', background: 'rgba(255, 255, 255, 0.1)' }} />
            </div>

            {/* Social Sign-Up Buttons Stack */}
            <div className="social-buttons-stack">
              <button
                type="button"
                onClick={() => handleSocialSelect('google')}
                className="social-auth-card"
                style={{ background: '#191c24', borderColor: 'rgba(255, 255, 255, 0.08)' }}
              >
                <svg width="17" height="17" viewBox="0 0 24 24">
                  <path fill="#EA4335" d="M12 5c1.57 0 2.98.57 4.09 1.5l3.07-3.07C17.29 1.63 14.81 1 12 1 7.42 1 3.51 3.56 1.6 7.28l3.66 2.84C6.14 7.03 8.84 5 12 5z" />
                  <path fill="#4285F4" d="M23.49 12.27c0-.79-.07-1.54-.19-2.27H12v4.51h6.47c-.29 1.48-1.14 2.73-2.4 3.58l3.72 2.88c2.18-2.01 3.7-4.99 3.7-8.7z" />
                  <path fill="#FBBC05" d="M5.26 14.88A7.04 7.04 0 0 1 4.88 12c0-1.02.14-2 .38-2.88L1.6 6.28A11.97 11.97 0 0 0 0 12c0 1.92.46 3.74 1.28 5.36l3.98-2.48z" />
                  <path fill="#34A853" d="M12 23c3.24 0 5.95-1.08 7.93-2.91l-3.72-2.88c-1.08.72-2.45 1.16-4.21 1.16-3.16 0-5.86-2.03-6.74-5.12L1.6 15.68C3.51 19.44 7.42 23 12 23z" />
                </svg>
                <span style={{ color: '#f8fafc', fontWeight: 600 }}>Continue with Google</span>
              </button>

              <button
                type="button"
                onClick={() => handleSocialSelect('apple')}
                className="social-auth-card"
                style={{ background: '#191c24', borderColor: 'rgba(255, 255, 255, 0.08)' }}
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="#ffffff">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 6.37c.62-.75 1.04-1.8 0.93-2.85-.9.04-1.99.6-2.64 1.36-.56.65-1.06 1.72-.93 2.74 1.01.08 2.03-.5 2.64-1.25z" />
                </svg>
                <span style={{ color: '#f8fafc', fontWeight: 600 }}>Continue with Apple</span>
              </button>

              <button
                type="button"
                onClick={() => handleSocialSelect('facebook')}
                className="social-auth-card"
                style={{ background: '#191c24', borderColor: 'rgba(255, 255, 255, 0.08)' }}
              >
                <svg width="17" height="17" viewBox="0 0 24 24" fill="#1877F2">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
                </svg>
                <span style={{ color: '#f8fafc', fontWeight: 600 }}>Continue with Facebook</span>
              </button>
            </div>
          </div>
        )}

        {/* STEP 1: Sub-Page 1B (OTP Verification & Password Creation) */}
        {currentStep === 1 && step1SubPage === 'B' && (
          <div style={{
            background: 'rgba(15, 23, 42, 0.35)',
            backdropFilter: 'blur(12px)',
            WebkitBackdropFilter: 'blur(12px)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            borderRadius: '18px',
            padding: '16px 14px',
            boxSizing: 'border-box',
          }}>
            <h1 className="auth-step-title" style={{ fontSize: '18px', fontWeight: 700, margin: '0 0 3px' }}>
              Verify & Secure Account
            </h1>
            <p className="auth-step-subtitle" style={{ fontSize: '11.5px', color: '#94a3b8', margin: '0 0 14px' }}>
              Enter the verification code and set your account password.
            </p>

            {step1BError && (
              <div className="auth-error-banner" style={{ padding: '6px 10px', fontSize: '11px', marginBottom: '10px' }}>
                <AlertCircle size={13} />
                <span>{step1BError}</span>
              </div>
            )}

            {/* 4-Digit OTP Verification Card */}
            <div
              className="otp-verification-card"
              style={{
                background: 'rgba(15, 23, 42, 0.35)',
                backdropFilter: 'blur(12px)',
                WebkitBackdropFilter: 'blur(12px)',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                borderRadius: '14px',
                padding: '10px 12px',
                marginBottom: '12px',
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '11.5px', fontWeight: 700, color: '#f8fafc', display: 'flex', alignItems: 'center', gap: '5px' }}>
                  <ShieldCheck size={13} color="#f43f5e" /> Verification Code (OTP)
                </span>
                <span style={{ fontSize: '10.5px', fontWeight: 600, color: otpTimer > 0 ? '#94a3b8' : '#f43f5e' }}>
                  {otpTimer > 0 ? `Resend in 0:${otpTimer < 10 ? `0${otpTimer}` : otpTimer}` : 'Expired'}
                </span>
              </div>
              <div style={{ fontSize: '10px', color: '#94a3b8', marginTop: '1px' }}>
                Code sent to {phone ? `+91 ${phone}` : email}
              </div>
              <div className="otp-boxes-row" style={{ margin: '8px 0 6px' }}>
                {otpDigits.map((digit, idx) => (
                  <input
                    key={idx}
                    ref={(el) => (otpRefs.current[idx] = el)}
                    type="text"
                    maxLength={1}
                    value={digit}
                    onChange={(e) => {
                      const val = e.target.value.replace(/\D/g, '').slice(-1);
                      const updated = [...otpDigits];
                      updated[idx] = val;
                      setOtpDigits(updated);
                      if (step1BError) setStep1BError(null);
                      if (val && idx < 3) otpRefs.current[idx + 1]?.focus();
                    }}
                    onKeyDown={(e) => {
                      if (e.key === 'Backspace' && !digit && idx > 0) {
                        otpRefs.current[idx - 1]?.focus();
                      }
                    }}
                    className="otp-digit-input"
                    style={{
                      width: '38px',
                      height: '42px',
                      borderRadius: '10px',
                      fontSize: '16px',
                      fontWeight: 700,
                      background: 'rgba(15, 23, 42, 0.5)',
                      border: '1px solid rgba(255, 255, 255, 0.12)',
                      color: '#f8fafc',
                    }}
                  />
                ))}
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '10.5px', color: '#94a3b8' }}>
                <span>Didn't receive code?</span>
                <button
                  type="button"
                  disabled={otpTimer > 0}
                  onClick={() => {
                    setOtpTimer(45);
                    setOtpDigits(['2', '0', '2', '6']);
                    if (step1BError) setStep1BError(null);
                  }}
                  style={{
                    background: 'transparent',
                    border: 'none',
                    color: otpTimer > 0 ? '#64748b' : '#f43f5e',
                    fontWeight: 700,
                    cursor: otpTimer > 0 ? 'default' : 'pointer',
                    padding: 0,
                    fontSize: '10.5px',
                  }}
                >
                  Resend Code
                </button>
              </div>
            </div>

            {/* Create Password & Confirm Password (Stacked Vertically, Compact) */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '14px' }}>
              <div className="form-field-group" style={{ marginBottom: 0, gap: '4px' }}>
                <label className="form-field-label" style={{ fontSize: '11px', marginBottom: 0 }}>
                  <span className="form-field-label-text" style={{ color: '#f8fafc' }}>
                    <Lock size={11} color="#f43f5e" /> Create Password
                  </span>
                </label>
                <div
                  className="form-field-input-wrap"
                  style={{
                    height: '42px',
                    padding: '0 12px',
                    borderRadius: '12px',
                    background: 'rgba(15, 23, 42, 0.35)',
                    backdropFilter: 'blur(12px)',
                    WebkitBackdropFilter: 'blur(12px)',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                  }}
                >
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => {
                      setPassword(e.target.value);
                      if (step1BError) setStep1BError(null);
                    }}
                    placeholder="Min 6 characters"
                    className="form-field-input"
                    style={{ fontSize: '13px' }}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    style={{ background: 'transparent', border: 'none', color: '#94a3b8', cursor: 'pointer', padding: '2px' }}
                    aria-label={showPassword ? 'Hide password' : 'Show password'}
                  >
                    {showPassword ? <EyeOff size={14} /> : <Eye size={14} />}
                  </button>
                </div>
              </div>

              <div className="form-field-group" style={{ marginBottom: 0, gap: '4px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <label className="form-field-label" style={{ fontSize: '11px', marginBottom: 0 }}>
                    <span className="form-field-label-text" style={{ color: '#f8fafc' }}>
                      <Lock size={11} color="#f43f5e" /> Confirm Password
                    </span>
                  </label>
                  {confirmPassword && (
                    <span style={{ fontSize: '10px', fontWeight: 600, color: password === confirmPassword ? '#4ade80' : '#f87171' }}>
                      {password === confirmPassword ? '✓ Passwords match' : 'Passwords do not match'}
                    </span>
                  )}
                </div>
                <div
                  className="form-field-input-wrap"
                  style={{
                    height: '42px',
                    padding: '0 12px',
                    borderRadius: '12px',
                    background: 'rgba(15, 23, 42, 0.35)',
                    backdropFilter: 'blur(12px)',
                    WebkitBackdropFilter: 'blur(12px)',
                    border: confirmPassword && password !== confirmPassword ? '1px solid rgba(239, 68, 68, 0.45)' : '1px solid rgba(255, 255, 255, 0.1)',
                  }}
                >
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => {
                      setConfirmPassword(e.target.value);
                      if (step1BError) setStep1BError(null);
                    }}
                    placeholder="Re-enter your password"
                    className="form-field-input"
                    style={{ fontSize: '13px' }}
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    style={{ background: 'transparent', border: 'none', color: '#94a3b8', cursor: 'pointer', padding: '2px' }}
                    aria-label={showConfirmPassword ? 'Hide confirm password' : 'Show confirm password'}
                  >
                    {showConfirmPassword ? <EyeOff size={14} /> : <Eye size={14} />}
                  </button>
                </div>
              </div>
            </div>

            {/* Primary Action Button: Verify & Continue */}
            <button
              type="button"
              onClick={handleVerifyAndContinueToStep2}
              className="btn-rose-primary"
              style={{ width: '100%', height: '44px', fontSize: '13.5px', marginTop: '4px' }}
            >
              <span>Verify & Continue</span>
              <ArrowRight size={16} />
            </button>
          </div>
        )}

        {/* STEP 2: Basic Profile Details (DOB, Gender, Orientation, Photo) */}
        {/* ========================================================= */}
        {currentStep === 2 && (
          <div>
            <h1 className="auth-step-title">Basic Profile Details 💖</h1>
            <p className="auth-step-subtitle">
              Tell us about yourself so matches get an authentic first impression.
            </p>

            {/* Date of Birth Selector */}
            <div className="form-field-group">
              <label className="form-field-label">
                <span className="form-field-label-text">
                  <Calendar size={12} color="#ff8da1" /> Date of Birth
                </span>
                <span style={{ fontSize: '11px', color: '#4CD964', fontWeight: 700 }}>
                  24 yrs old • 18+ Verified ✓
                </span>
              </label>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1.3fr', gap: '8px' }}>
                <div className="form-field-input-wrap">
                  <input
                    type="number"
                    min="1"
                    max="31"
                    value={birthDay}
                    onChange={(e) => setBirthDay(e.target.value)}
                    placeholder="Day"
                    className="form-field-input"
                  />
                </div>
                <div className="form-field-input-wrap">
                  <input
                    type="number"
                    min="1"
                    max="12"
                    value={birthMonth}
                    onChange={(e) => setBirthMonth(e.target.value)}
                    placeholder="Month"
                    className="form-field-input"
                  />
                </div>
                <div className="form-field-input-wrap">
                  <input
                    type="number"
                    min="1950"
                    max="2006"
                    value={birthYear}
                    onChange={(e) => setBirthYear(e.target.value)}
                    placeholder="Year"
                    className="form-field-input"
                  />
                </div>
              </div>
            </div>

            {/* Selectable Gender Pills */}
            <div className="form-field-group">
              <label className="form-field-label">
                <span className="form-field-label-text">I am a</span>
              </label>
              <div className="selectable-pills-row">
                {(['Male', 'Female', 'Non-Binary'] as const).map((g) => (
                  <button
                    key={g}
                    type="button"
                    onClick={() => setGender(g)}
                    className={`romantic-pill ${gender === g ? 'active' : ''}`}
                    style={{ flex: 1, justifyContent: 'center' }}
                  >
                    <span>{g === 'Male' ? '👨 Male' : g === 'Female' ? '👩 Female' : '✨ Non-Binary'}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Orientation Dropdown */}
            <div className="form-field-group">
              <label className="form-field-label">
                <span className="form-field-label-text">Sexual Orientation</span>
              </label>
              <div className="form-field-input-wrap">
                <select
                  value={orientation}
                  onChange={(e) => setOrientation(e.target.value)}
                  className="form-field-input"
                  style={{ background: 'transparent', color: '#ffffff' }}
                >
                  <option value="Straight" style={{ background: '#200816' }}>Straight</option>
                  <option value="Gay" style={{ background: '#200816' }}>Gay</option>
                  <option value="Lesbian" style={{ background: '#200816' }}>Lesbian</option>
                  <option value="Bisexual" style={{ background: '#200816' }}>Bisexual</option>
                  <option value="Pansexual" style={{ background: '#200816' }}>Pansexual</option>
                  <option value="Queer" style={{ background: '#200816' }}>Queer</option>
                </select>
              </div>
            </div>

            {/* Primary Profile Photo Upload Box */}
            <div className="form-field-group">
              <label className="form-field-label">
                <span className="form-field-label-text">
                  <Camera size={12} color="#ff8da1" /> Primary Profile Photo
                </span>
                <span style={{ fontSize: '11px', color: '#ff8da1', fontWeight: 600 }}>Face Centered</span>
              </label>

              <input
                ref={photoInputRef}
                type="file"
                accept="image/*"
                onChange={handlePhotoUpload}
                style={{ display: 'none' }}
              />

              <div
                onClick={() => photoInputRef.current?.click()}
                className="photo-upload-dashed-box"
              >
                {primaryPhoto ? (
                  <div style={{ position: 'relative', width: '100%', height: '100%' }}>
                    <img
                      src={primaryPhoto}
                      alt="Primary Photo Preview"
                      style={{
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover',
                        filter: autoEnhanced ? 'contrast(1.05) saturate(1.1)' : 'none',
                      }}
                    />
                    <div
                      style={{
                        position: 'absolute',
                        inset: 0,
                        background: 'linear-gradient(180deg, transparent 60%, rgba(20, 4, 14, 0.85) 100%)',
                        display: 'flex',
                        alignItems: 'flex-end',
                        justifyContent: 'space-between',
                        padding: '10px 14px',
                      }}
                    >
                      <span style={{ fontSize: '11px', color: '#ffffff', fontWeight: 700 }}>Tap to Change Photo</span>
                      {autoEnhanced && (
                        <span style={{ fontSize: '10px', color: '#ff8da1', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '3px' }}>
                          <Sparkles size={11} /> AI Enhanced
                        </span>
                      )}
                    </div>
                  </div>
                ) : (
                  <>
                    <Camera size={32} color="#ff8da1" />
                    <span style={{ fontSize: '13px', fontWeight: 700, color: '#ffffff' }}>Upload Primary Photo</span>
                    <span style={{ fontSize: '11px', color: '#e2c0ce' }}>High-res JPG or PNG portrait</span>
                  </>
                )}
              </div>

              {/* Instant Preset Avatars Strip */}
              <div style={{ marginTop: '10px' }}>
                <span style={{ fontSize: '11px', color: '#e2c0ce', display: 'block', marginBottom: '6px' }}>
                  Or select a demo avatar:
                </span>
                <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '4px' }}>
                  {PRESET_AVATARS.map((avatar, idx) => (
                    <img
                      key={idx}
                      src={avatar}
                      alt={`Preset ${idx}`}
                      onClick={() => setPrimaryPhoto(avatar)}
                      style={{
                        width: '42px',
                        height: '42px',
                        borderRadius: '12px',
                        objectFit: 'cover',
                        cursor: 'pointer',
                        border: primaryPhoto === avatar ? '2px solid #ff8da1' : '1px solid rgba(255, 141, 161, 0.3)',
                        transform: primaryPhoto === avatar ? 'scale(1.08)' : 'scale(1)',
                        transition: 'all 0.15s ease',
                      }}
                    />
                  ))}
                </div>
              </div>

              {/* Auto-Enhance Photo Toggle */}
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  marginTop: '12px',
                  padding: '10px 14px',
                  borderRadius: '14px',
                  background: 'rgba(43, 9, 28, 0.55)',
                  border: '1px solid rgba(255, 141, 161, 0.2)',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <Sparkles size={15} color="#ff8da1" />
                  <div>
                    <span style={{ fontSize: '12px', fontWeight: 700, color: '#ffffff', display: 'block' }}>Auto-Enhance Photo</span>
                    <span style={{ fontSize: '10.5px', color: '#e2c0ce' }}>Optimizes skin glow & lighting</span>
                  </div>
                </div>
                <input
                  type="checkbox"
                  checked={autoEnhanced}
                  onChange={(e) => setAutoEnhanced(e.target.checked)}
                  style={{ width: '18px', height: '18px', accentColor: '#ff4d88', cursor: 'pointer' }}
                />
              </div>
            </div>
          </div>
        )}

        {/* ========================================================= */}
        {/* STEP 3: Match Preferences & Interests                     */}
        {/* ========================================================= */}
        {currentStep === 3 && (
          <div>
            <h1 className="auth-step-title">Intentions & Interests 💫</h1>
            <p className="auth-step-subtitle">
              Clear romantic intentions help you match with people on the same page.
            </p>

            {/* 2x2 Grid of Dating Intent Cards */}
            <div style={{ marginBottom: '16px' }}>
              <label className="form-field-label" style={{ marginBottom: '8px' }}>
                <span className="form-field-label-text">
                  <Heart size={12} color="#ff8da1" /> What are you looking for?
                </span>
              </label>

              <div className="intent-grid">
                {INTENT_OPTIONS.map((item) => (
                  <div
                    key={item.id}
                    onClick={() => setIntent(item.id)}
                    className={`intent-card ${intent === item.id ? 'active' : ''}`}
                  >
                    <span style={{ fontSize: '24px', marginBottom: '4px' }}>{item.icon}</span>
                    <span style={{ fontSize: '13px', fontWeight: 800, color: '#ffffff', marginBottom: '2px' }}>
                      {item.label}
                    </span>
                    <span style={{ fontSize: '10.5px', color: '#e2c0ce', lineHeight: 1.35 }}>
                      {item.desc}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Interactive Multi-Select Pill Tags */}
            <div className="form-field-group">
              <label className="form-field-label" style={{ marginBottom: '8px' }}>
                <span className="form-field-label-text">
                  <Palette size={12} color="#ff8da1" /> Your Interests ({interests.length} selected)
                </span>
                <span style={{ fontSize: '10.5px', color: '#ff8da1', fontWeight: 600 }}>Min 3 recommended</span>
              </label>
              <div className="selectable-pills-row">
                {INTEREST_OPTIONS.map((pill) => {
                  const isSelected = interests.includes(pill.id);
                  return (
                    <button
                      key={pill.id}
                      type="button"
                      onClick={() => toggleInterest(pill.id)}
                      className={`romantic-pill ${isSelected ? 'active' : ''}`}
                    >
                      <span>{pill.label}</span>
                    </button>
                  );
                })}
              </div>

              {/* Add Custom Interest Chip & Input (Architecture Diagram: Add Your Own Interest) */}
              <div style={{ marginTop: '10px', display: 'flex', gap: '8px' }}>
                <input
                  type="text"
                  value={customInterestInput}
                  onChange={(e) => setCustomInterestInput(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      handleAddCustomInterest();
                    }
                  }}
                  placeholder="Add your own interest (e.g. Sourdough, Anime)"
                  className="form-field-input"
                  style={{ flex: 1, padding: '7px 12px', fontSize: '12px' }}
                />
                <button
                  type="button"
                  onClick={handleAddCustomInterest}
                  disabled={!customInterestInput.trim()}
                  style={{
                    padding: '7px 14px',
                    borderRadius: '10px',
                    background: customInterestInput.trim() ? 'linear-gradient(135deg, #f43f5e, #f97316)' : 'rgba(255, 255, 255, 0.08)',
                    border: 'none',
                    color: '#ffffff',
                    fontSize: '11.5px',
                    fontWeight: 700,
                    cursor: customInterestInput.trim() ? 'pointer' : 'default',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '4px',
                  }}
                >
                  <Plus size={14} />
                  <span>Add</span>
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ========================================================= */}
        {/* STEP 4: Profile Enrichment & Discovery Sliders           */}
        {/* ========================================================= */}
        {currentStep === 4 && (
          <div>
            <h1 className="auth-step-title">Enrich Your Story 📖</h1>
            <p className="auth-step-subtitle">
              Add context on your career, passions, and set discovery distance limits.
            </p>

            {/* Profession & Education */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', marginBottom: '12px' }}>
              <div className="form-field-group" style={{ marginBottom: 0 }}>
                <label className="form-field-label">
                  <span className="form-field-label-text">Profession</span>
                </label>
                <div className="form-field-input-wrap">
                  <input
                    type="text"
                    value={profession}
                    onChange={(e) => setProfession(e.target.value)}
                    placeholder="UI/UX Architect"
                    className="form-field-input"
                  />
                </div>
              </div>

              <div className="form-field-group" style={{ marginBottom: 0 }}>
                <label className="form-field-label">
                  <span className="form-field-label-text">Education</span>
                </label>
                <div className="form-field-input-wrap">
                  <input
                    type="text"
                    value={education}
                    onChange={(e) => setEducation(e.target.value)}
                    placeholder="IIT Bombay"
                    className="form-field-input"
                  />
                </div>
              </div>
            </div>

            {/* Short Bio Textarea */}
            <div className="form-field-group">
              <label className="form-field-label">
                <span className="form-field-label-text">About Me (Bio)</span>
                <span style={{ fontSize: '10.5px', color: '#ff8da1' }}>{bio.length}/300</span>
              </label>
              <div
                className="form-field-input-wrap"
                style={{ height: '82px', padding: '10px 14px', alignItems: 'flex-start' }}
              >
                <textarea
                  value={bio}
                  onChange={(e) => setBio(e.target.value.slice(0, 300))}
                  placeholder="Share a fun fact, ideal weekend date, or what makes you smile..."
                  className="form-field-input"
                  style={{ height: '100%', resize: 'none', lineHeight: 1.4 }}
                />
              </div>
            </div>

            {/* Location with Auto-detect */}
            <div className="form-field-group">
              <label className="form-field-label">
                <span className="form-field-label-text">
                  <MapPin size={12} color="#ff8da1" /> City / Location
                </span>
                <button
                  type="button"
                  onClick={handleAutoDetectCity}
                  style={{
                    background: 'transparent',
                    border: 'none',
                    color: '#ff8da1',
                    fontSize: '11px',
                    fontWeight: 700,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '4px',
                  }}
                >
                  <Compass size={11} /> {isDetectingCity ? 'Locating...' : 'Auto-detect GPS'}
                </button>
              </label>
              <div className="form-field-input-wrap">
                <input
                  type="text"
                  value={city}
                  onChange={(e) => setCity(e.target.value)}
                  placeholder="Mumbai, Bandra West"
                  className="form-field-input"
                />
              </div>
            </div>

            {/* Single-Bar Sliders: Maximum Age & Maximum Distance */}
            <div
              style={{
                padding: '14px',
                borderRadius: '16px',
                background: 'rgba(43, 9, 28, 0.55)',
                border: '1px solid rgba(255, 141, 161, 0.22)',
                display: 'flex',
                flexDirection: 'column',
                gap: '14px',
              }}
            >
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '6px' }}>
                  <span style={{ fontSize: '12px', fontWeight: 700, color: '#ffffff', display: 'flex', alignItems: 'center', gap: '5px' }}>
                    <Sliders size={12} color="#ff8da1" /> Maximum Match Age
                  </span>
                  <span style={{ fontSize: '12px', fontWeight: 800, color: '#ff8da1' }}>18 - {maxAge} yrs</span>
                </div>
                <input
                  type="range"
                  min="21"
                  max="55"
                  value={maxAge}
                  onChange={(e) => setMaxAge(Number(e.target.value))}
                  style={{ width: '100%', accentColor: '#ff4d88', cursor: 'pointer' }}
                />
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '6px' }}>
                  <span style={{ fontSize: '12px', fontWeight: 700, color: '#ffffff', display: 'flex', alignItems: 'center', gap: '5px' }}>
                    <MapPin size={12} color="#ff8da1" /> Maximum Distance (km)
                  </span>
                  <span style={{ fontSize: '12px', fontWeight: 800, color: '#ff8da1' }}>Up to {maxDistance} km</span>
                </div>
                <input
                  type="range"
                  min="5"
                  max="100"
                  value={maxDistance}
                  onChange={(e) => setMaxDistance(Number(e.target.value))}
                  style={{ width: '100%', accentColor: '#ff4d88', cursor: 'pointer' }}
                />
              </div>
            </div>
          </div>
        )}

        {/* ========================================================= */}
        {/* STEP 5: Verification & Permissions                       */}
        {/* ========================================================= */}
        {currentStep === 5 && (
          <div>
            <h1 className="auth-step-title">Safety & Verification 🛡️</h1>
            <p className="auth-step-subtitle">
              Verify your authenticity to get the Pink Verified Badge and higher match priority.
            </p>

            {/* Notification & Location Permissions Toggles */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', marginBottom: '14px' }}>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 14px',
                  borderRadius: '16px',
                  background: 'rgba(43, 9, 28, 0.55)',
                  border: '1px solid rgba(255, 141, 161, 0.22)',
                }}
              >
                <div>
                  <span style={{ fontSize: '13px', fontWeight: 700, color: '#ffffff', display: 'block' }}>
                    Push Notifications
                  </span>
                  <span style={{ fontSize: '11px', color: '#e2c0ce' }}>Get notified for mutual matches and calls</span>
                </div>
                <input
                  type="checkbox"
                  checked={allowNotifications}
                  onChange={(e) => setAllowNotifications(e.target.checked)}
                  style={{ width: '18px', height: '18px', accentColor: '#ff4d88', cursor: 'pointer' }}
                />
              </div>

              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 14px',
                  borderRadius: '16px',
                  background: 'rgba(43, 9, 28, 0.55)',
                  border: '1px solid rgba(255, 141, 161, 0.22)',
                }}
              >
                <div>
                  <span style={{ fontSize: '13px', fontWeight: 700, color: '#ffffff', display: 'block' }}>
                    Live GPS Location
                  </span>
                  <span style={{ fontSize: '11px', color: '#e2c0ce' }}>Powers accurate kilometer distance radar</span>
                </div>
                <input
                  type="checkbox"
                  checked={allowLocation}
                  onChange={(e) => setAllowLocation(e.target.checked)}
                  style={{ width: '18px', height: '18px', accentColor: '#ff4d88', cursor: 'pointer' }}
                />
              </div>
            </div>

            {/* Who Can Message Me Pills */}
            <div className="form-field-group" style={{ marginBottom: '14px' }}>
              <label className="form-field-label">
                <span className="form-field-label-text">Who Can Message Me</span>
              </label>
              <div className="selectable-pills-row">
                {(['everyone', 'matches', 'verified'] as const).map((opt) => (
                  <button
                    key={opt}
                    type="button"
                    onClick={() => setWhoCanMessage(opt)}
                    className={`romantic-pill ${whoCanMessage === opt ? 'active' : ''}`}
                    style={{ flex: 1, justifyContent: 'center' }}
                  >
                    <span>
                      {opt === 'everyone' ? 'Everyone' : opt === 'matches' ? 'Matches Only' : 'Verified Only 🛡️'}
                    </span>
                  </button>
                ))}
              </div>
            </div>

            {/* Face Liveness Scanner Frame */}
            <div
              style={{
                padding: '14px',
                borderRadius: '16px',
                background: 'rgba(43, 9, 28, 0.65)',
                border: '1px solid rgba(255, 141, 161, 0.25)',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
                <span style={{ fontSize: '12.5px', fontWeight: 700, color: '#ffffff', display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <ShieldCheck size={14} color="#ff8da1" /> Blink Face Liveness
                </span>
                {isFaceVerified && (
                  <span style={{ fontSize: '11px', color: '#4CD964', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '3px' }}>
                    <CheckCircle2 size={12} /> Verified ✓
                  </span>
                )}
              </div>

              {/* Oval Camera Reticle Frame */}
              <div className="face-scan-oval" style={{ height: '140px', width: '110px' }}>
                <img
                  src={primaryPhoto}
                  alt="Face Scan Reticle"
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />
                {isFaceScanning && (
                  <div
                    style={{
                      position: 'absolute',
                      top: 0,
                      left: 0,
                      right: 0,
                      height: '2px',
                      background: '#ff8da1',
                      boxShadow: '0 0 10px #ff4d88',
                      animation: 'scanLine 1s infinite alternate',
                    }}
                  />
                )}
              </div>

              <button
                type="button"
                onClick={handleFaceScan}
                disabled={isFaceScanning}
                className="btn-rose-primary"
                style={{ height: '38px', fontSize: '12px', width: '100%', marginTop: '10px' }}
              >
                {isFaceScanning ? 'Scanning Landmarks...' : isFaceVerified ? 'Face Verified ✓ (Re-verify)' : '1-Tap Verify Face'}
              </button>
            </div>

            {/* Add Friends by Contacts Permissions (Architecture Diagram: Safety & Completion) */}
            <div
              style={{
                marginTop: '12px',
                padding: '12px 14px',
                borderRadius: '16px',
                background: 'rgba(255, 255, 255, 0.04)',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <div>
                <div style={{ fontSize: '12.5px', fontWeight: 700, color: '#f8fafc', display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <Users size={14} color="#f43f5e" /> Add Friends by Contacts
                </div>
                <div style={{ fontSize: '10.5px', color: '#94a3b8', marginTop: '2px' }}>
                  Sync contacts to find friends & hide profile from relatives
                </div>
              </div>

              <input
                type="checkbox"
                checked={allowContactsSync}
                onChange={(e) => setAllowContactsSync(e.target.checked)}
                style={{ width: '18px', height: '18px', accentColor: '#f43f5e', cursor: 'pointer' }}
              />
            </div>
          </div>
        )}
      </div>

      {/* Primary Sticky Footer Actions (Steps 2 to 5) */}
      {currentStep > 1 && (
        <div className="auth-footer-actions">
          <button
            type="button"
            onClick={handleBackStep}
            className="btn-glass-secondary"
          >
            Back
          </button>

          <button
            type="button"
            onClick={handleNext}
            className="btn-rose-primary"
          >
            <span>{currentStep === 5 ? 'Complete Setup & Start Swiping' : 'Continue'}</span>
            <ArrowRight size={18} />
          </button>
        </div>
      )}
    </div>
  );
};
