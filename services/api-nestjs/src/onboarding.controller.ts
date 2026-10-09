import { Router, Request, Response } from 'express';
import { db } from '../../../database/db.js';

export const onboardingRouter = Router();

/**
 * Calculates profile completion percentage based on 9-step criteria
 */
function calculateProgress(profileData: any): number {
  let score = 0;
  if (profileData.nickname) score += 10;
  if (profileData.dob) score += 10;
  if (profileData.gender) score += 10;
  if (profileData.bio && profileData.bio.length > 10) score += 15;
  if (profileData.photo_urls && profileData.photo_urls.length > 0) score += 20;
  if (profileData.voice_pin_url) score += 10;
  if (profileData.liveness_verified) score += 15;
  if (profileData.call_avatar_ref) score += 5;
  if (profileData.languages && profileData.languages.length > 0) score += 5;
  return Math.min(100, score);
}

/**
 * POST /v1/onboarding/wizard
 * Submits steps, calculates completion progress, auto-awards Blue Tick at >=70%
 */
onboardingRouter.post('/wizard', (req: Request, res: Response) => {
  const {
    user_id,
    step,
    nickname,
    dob,
    gender,
    bio,
    city,
    languages,
    photo_urls,
    voice_pin_url,
    liveness_verified,
    call_avatar_ref,
    lat,
    lng,
  } = req.body;

  const targetUserId = user_id || '11111111-1111-1111-1111-111111111111';
  let user = db.users.get(targetUserId);
  let profile = db.profiles.get(targetUserId);

  if (!profile) {
    profile = {
      user_id: targetUserId,
      nickname: nickname || 'New User',
      bio: bio || '',
      city: city || 'Mumbai',
      languages: languages || ['English'],
      lat: lat || 19.0596,
      lng: lng || 72.8295,
      profile_progress: 0,
      photo_urls: photo_urls || [],
      call_avatar_ref: call_avatar_ref || 'avatar_neon_tiger',
      voice_pin_url,
      liveness_verified: !!liveness_verified,
      contact_share_unlocked: false,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
    db.profiles.set(targetUserId, profile);
  } else {
    if (nickname) profile.nickname = nickname;
    if (bio !== undefined) profile.bio = bio;
    if (city) profile.city = city;
    if (languages) profile.languages = languages;
    if (photo_urls) profile.photo_urls = photo_urls;
    if (voice_pin_url) profile.voice_pin_url = voice_pin_url;
    if (liveness_verified !== undefined) profile.liveness_verified = liveness_verified;
    if (call_avatar_ref) profile.call_avatar_ref = call_avatar_ref;
    if (lat && lng) {
      profile.lat = lat;
      profile.lng = lng;
    }
    profile.updated_at = new Date().toISOString();
  }

  // Calculate dynamic progress
  const progress = calculateProgress({
    ...profile,
    dob: user?.dob || dob,
    gender: user?.gender || gender,
  });
  profile.profile_progress = progress;

  // Blue Tick rule: Auto-awarded at 70%+ completion
  const isVerified = progress >= 70 && profile.liveness_verified;
  if (user) {
    user.is_verified = isVerified;
    if (gender) user.gender = gender;
    if (dob) user.dob = dob;
    user.updated_at = new Date().toISOString();
  }

  return res.json({
    success: true,
    step_saved: step,
    profile_progress: progress,
    blue_tick_awarded: isVerified,
    profile,
    user,
  });
});

/**
 * GET /v1/onboarding/status/:userId
 */
onboardingRouter.get('/status/:userId', (req: Request, res: Response) => {
  const { userId } = req.params;
  const profile = db.profiles.get(userId);
  const user = db.users.get(userId);

  if (!profile) {
    return res.status(404).json({ error: 'Profile not found' });
  }

  return res.json({
    user_id: userId,
    progress: profile.profile_progress,
    is_verified: user?.is_verified || false,
    missing_items: [
      !profile.voice_pin_url ? 'Voice PIN recording' : null,
      !profile.liveness_verified ? 'Blink SDK oval face liveness check' : null,
      profile.photo_urls.length < 3 ? 'Upload at least 3 photos' : null,
      !profile.bio ? 'Bio introduction' : null,
    ].filter(Boolean),
  });
});
