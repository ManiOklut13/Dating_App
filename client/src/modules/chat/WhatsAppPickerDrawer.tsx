import React, { useEffect, useMemo, useState } from 'react';
import {
  Search,
  X,
  Smile,
  Sticker as StickerIcon,
  Pencil,
  Clock,
  Star,
  Plus,
  Sparkles,
  Flame,
} from 'lucide-react';
import { DEMO_GIFS } from './mockData';

export interface StickerPick {
  id: string;
  label: string;
  emoji: string;
  packId: string;
}

interface WhatsAppPickerDrawerProps {
  activeTab: 'emoji' | 'bitmoji' | 'sticker' | 'gif';
  onTabChange: (tab: 'emoji' | 'bitmoji' | 'sticker' | 'gif') => void;
  emojis: string[];
  onInsertEmoji: (emoji: string) => void;
  onSendSticker: (sticker: { label: string; emoji: string }) => void;
  onSendGif: (gifUrl: string) => void;
}

const RECENT_EMOJIS_KEY = 'younme_tray_recent_emojis';
const RECENT_STICKERS_KEY = 'younme_tray_recent_stickers';
const RECENT_GIFS_KEY = 'younme_tray_recent_gifs';
const FAV_STICKERS_KEY = 'younme_tray_fav_stickers';

const readList = (key: string): string[] => {
  try {
    const raw = localStorage.getItem(key);
    return raw ? (JSON.parse(raw) as string[]) : [];
  } catch {
    return [];
  }
};

const writeList = (key: string, list: string[]) => {
  try {
    localStorage.setItem(key, JSON.stringify(list));
  } catch {
    /* storage unavailable - session only */
  }
};

interface StickerPack {
  id: string;
  icon: string;
  title: string;
  items: StickerPick[];
}

const STICKER_PACKS: StickerPack[] = [
  {
    id: 'love',
    icon: '❤️',
    title: 'Love & Romance',
    items: [
      { id: 's_love_1', emoji: '❤️', label: 'Heart Love', packId: 'love' },
      { id: 's_love_2', emoji: '🥰', label: 'Love Blast', packId: 'love' },
      { id: 's_love_3', emoji: '😘', label: 'Flying Kiss', packId: 'love' },
      { id: 's_love_4', emoji: '🌹', label: 'Red Rose', packId: 'love' },
      { id: 's_love_5', emoji: '💍', label: 'Soulmate', packId: 'love' },
      { id: 's_love_6', emoji: '💌', label: 'Love Letter', packId: 'love' },
      { id: 's_love_7', emoji: '💘', label: 'Cupid Arrow', packId: 'love' },
      { id: 's_love_8', emoji: '💖', label: 'Sparkling Heart', packId: 'love' },
      { id: 's_love_9', emoji: '😍', label: 'Heart Eyes', packId: 'love' },
      { id: 's_love_10', emoji: '💐', label: 'Bouquet', packId: 'love' },
      { id: 's_love_11', emoji: '🍫', label: 'Chocolates', packId: 'love' },
      { id: 's_love_12', emoji: '👩‍❤️‍👨', label: 'Together', packId: 'love' },
    ],
  },
  {
    id: 'dating',
    icon: '☕',
    title: 'Dating & Vibes',
    items: [
      { id: 's_date_1', emoji: '☕', label: 'Coffee Date?', packId: 'dating' },
      { id: 's_date_2', emoji: '🍷', label: 'Wine & Dine', packId: 'dating' },
      { id: 's_date_3', emoji: '🍕', label: 'Pizza Night', packId: 'dating' },
      { id: 's_date_4', emoji: '🎬', label: 'Movie Date', packId: 'dating' },
      { id: 's_date_5', emoji: '✨', label: 'Vibe Check', packId: 'dating' },
      { id: 's_date_6', emoji: '🚗', label: 'Long Drive', packId: 'dating' },
      { id: 's_date_7', emoji: '🌅', label: 'Sunset Walk', packId: 'dating' },
      { id: 's_date_8', emoji: '🧁', label: 'Sweet Tooth', packId: 'dating' },
    ],
  },
  {
    id: 'cute',
    icon: '🐾',
    title: 'Cute Animals',
    items: [
      { id: 's_cute_1', emoji: '🐱', label: 'Cute Kitty', packId: 'cute' },
      { id: 's_cute_2', emoji: '🐼', label: 'Panda Hug', packId: 'cute' },
      { id: 's_cute_3', emoji: '🐶', label: 'Puppy Eyes', packId: 'cute' },
      { id: 's_cute_4', emoji: '🐰', label: 'Bunny Hop', packId: 'cute' },
      { id: 's_cute_5', emoji: '🐻', label: 'Teddy Hug', packId: 'cute' },
      { id: 's_cute_6', emoji: '🦊', label: 'Clever Fox', packId: 'cute' },
      { id: 's_cute_7', emoji: '🐥', label: 'Sweet Chick', packId: 'cute' },
      { id: 's_cute_8', emoji: '🐨', label: 'Lazy Koala', packId: 'cute' },
    ],
  },
  {
    id: 'reactions',
    icon: '😂',
    title: 'Desi Reactions',
    items: [
      { id: 's_re_1', emoji: '😂', label: 'ROFL', packId: 'reactions' },
      { id: 's_re_2', emoji: '🔥', label: 'Too Hot', packId: 'reactions' },
      { id: 's_re_3', emoji: '🥳', label: 'Party Time', packId: 'reactions' },
      { id: 's_re_4', emoji: '🙈', label: 'Blushing', packId: 'reactions' },
      { id: 's_re_5', emoji: '💃', label: 'Dancing', packId: 'reactions' },
      { id: 's_re_6', emoji: '🥂', label: 'Cheers', packId: 'reactions' },
      { id: 's_re_7', emoji: '⚡', label: 'Shocked', packId: 'reactions' },
      { id: 's_re_8', emoji: '💯', label: 'Perfection', packId: 'reactions' },
    ],
  },
];

const EMOJI_CATEGORIES: { icon: string; title: string; emojis: string[] }[] = [
  {
    icon: '😀',
    title: 'Smileys',
    emojis: [
      '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
      '🙂', '🙃', '😉', '😊', '😇', '🥰', '😍', '🤩',
      '😘', '😗', '😚', '😙', '😋', '😛', '😜', '🤪',
      '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐', '🤨',
    ],
  },
  {
    icon: '❤️',
    title: 'Love & Hearts',
    emojis: [
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
      '🤎', '💔', '❣️', '💕', '💞', '💓', '💗', '💖',
      '💘', '💝', '💟', '💋', '💌', '💐', '🌹', '🥀',
    ],
  },
  {
    icon: '👋',
    title: 'People',
    emojis: [
      '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏',
      '✌️', '🤞', '🫰', '🤟', '🤘', '🤙', '👈', '👉',
      '👆', '🖕', '👇', '☝️', '👍', '👎', '✊', '👊',
    ],
  },
  {
    icon: '🍕',
    title: 'Food',
    emojis: [
      '☕', '🍵', '🧋', '🍺', '🍻', '🥂', '🍷', '🍸',
      '🍕', '🍔', '🍟', '🌭', '🥪', '🌮', '🍣', '🍱',
      '🧁', '🍰', '🎂', '🍩', '🍪', '🍫', '🍬', '🍭',
    ],
  },
  {
    icon: '🎉',
    title: 'Activities',
    emojis: [
      '🎉', '🎊', '🎈', '🎁', '🎂', '🎃', '🎄', '🎆',
      '⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🎱', '🎮',
      '🎨', '🎬', '🎤', '🎧', '🎷', '🎸', '🎹', '🎺',
    ],
  },
];

const EMOJI_ALIASES: Record<string, string> = {
  '❤️': 'heart love red', '🔥': 'fire flame hot lit', '✨': 'sparkles magic shine',
  '☕': 'coffee tea cafe', '😍': 'heart eyes love', '😂': 'joy laugh lol',
  '🥂': 'champagne cheers toast', '🍕': 'pizza food', '🌸': 'flower blossom sakura',
  '🎶': 'music notes song', '🙌': 'praise hands celebrate', '💯': 'hundred perfect',
  '😊': 'blush smile happy', '🎉': 'party tada celebrate', '🌟': 'star glowing',
  '👀': 'eyes look', '😘': 'kiss', '🥰': 'love smile hearts',
  '😎': 'cool sunglasses', '🤗': 'hug', '😅': 'sweat nervous laugh',
  '😉': 'wink', '🤩': 'starstruck wow', '😭': 'cry sob sad',
  '💖': 'sparkle heart love', '💫': 'dizzy star', '🌈': 'rainbow',
  '🌻': 'sunflower', '🍫': 'chocolate', '🍷': 'wine drink',
  '🎁': 'gift present', '💌': 'love letter',
};

const GIFS = [
  ...DEMO_GIFS.map((g) => ({ id: g.id, title: g.title, url: g.url })),
  { id: 'gif-6', title: 'Heart Eyes', url: 'https://media.giphy.com/media/3oKIPnAiaMCws8nOsE/giphy.gif' },
];

export const WhatsAppPickerDrawer: React.FC<WhatsAppPickerDrawerProps> = ({
  activeTab,
  onTabChange,
  emojis,
  onInsertEmoji,
  onSendSticker,
  onSendGif,
}) => {
  const [searchOpen, setSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [emojiView, setEmojiView] = useState<'recent' | number>(0);
  const [stickerView, setStickerView] = useState<'recent' | 'fav' | number>(0);
  const [gifView, setGifView] = useState<'recent' | 'trending'>('trending');

  const [recentEmojis, setRecentEmojis] = useState<string[]>(() => readList(RECENT_EMOJIS_KEY));
  const [recentStickers, setRecentStickers] = useState<string[]>(() => readList(RECENT_STICKERS_KEY));
  const [recentGifs, setRecentGifs] = useState<string[]>(() => readList(RECENT_GIFS_KEY));
  const [favStickers, setFavStickers] = useState<string[]>(() => readList(FAV_STICKERS_KEY));

  useEffect(() => { writeList(RECENT_EMOJIS_KEY, recentEmojis); }, [recentEmojis]);
  useEffect(() => { writeList(RECENT_STICKERS_KEY, recentStickers); }, [recentStickers]);
  useEffect(() => { writeList(RECENT_GIFS_KEY, recentGifs); }, [recentGifs]);
  useEffect(() => { writeList(FAV_STICKERS_KEY, favStickers); }, [favStickers]);

  const allStickers = useMemo(
    () => STICKER_PACKS.flatMap((p) => p.items),
    [],
  );
  const stickerById = useMemo(
    () => new Map(allStickers.map((s) => [s.id, s])),
    [allStickers],
  );
  const allEmojis = useMemo(
    () => EMOJI_CATEGORIES.flatMap((c) => c.emojis).concat(emojis),
    [emojis],
  );

  const closeSearch = () => {
    setSearchOpen(false);
    setSearchQuery('');
  };

  const handlePickEmoji = (emoji: string) => {
    setRecentEmojis((prev) => [emoji, ...prev.filter((e) => e !== emoji)].slice(0, 24));
    onInsertEmoji(emoji);
  };

  const handlePickSticker = (sticker: StickerPick) => {
    setRecentStickers((prev) => [sticker.id, ...prev.filter((id) => id !== sticker.id)].slice(0, 24));
    onSendSticker({ label: sticker.label, emoji: sticker.emoji });
  };

  const handlePickGif = (gif: { id: string; url: string }) => {
    setRecentGifs((prev) => [gif.id, ...prev.filter((id) => id !== gif.id)].slice(0, 12));
    onSendGif(gif.url);
  };

  const toggleFav = (e: React.MouseEvent, stickerId: string) => {
    e.stopPropagation();
    setFavStickers((prev) =>
      prev.includes(stickerId) ? prev.filter((id) => id !== stickerId) : [stickerId, ...prev],
    );
  };

  const query = searchQuery.trim().toLowerCase();

  // ── Emoji content ──
  const emojiList = query
    ? allEmojis.filter(
        (e) =>
          (EMOJI_ALIASES[e] || '').includes(query) ||
          EMOJI_CATEGORIES.some((c) => c.title.toLowerCase().includes(query) && c.emojis.includes(e)),
      )
    : emojiView === 'recent'
      ? recentEmojis
      : EMOJI_CATEGORIES[emojiView as number].emojis;

  // ── Sticker content ──
  const stickerList = query
    ? allStickers.filter((s) => s.label.toLowerCase().includes(query))
    : stickerView === 'recent'
      ? recentStickers.map((id) => stickerById.get(id)).filter(Boolean as unknown as (v: StickerPick | undefined) => v is StickerPick)
      : stickerView === 'fav'
        ? favStickers.map((id) => stickerById.get(id)).filter(Boolean as unknown as (v: StickerPick | undefined) => v is StickerPick)
        : STICKER_PACKS[stickerView as number].items;

  // ── GIF content ──
  const gifList = query
    ? GIFS.filter((g) => g.title.toLowerCase().includes(query))
    : gifView === 'recent'
      ? recentGifs.map((id) => GIFS.find((g) => g.id === id)).filter(Boolean as unknown as (v: typeof GIFS[number] | undefined) => v is typeof GIFS[number])
      : GIFS;

  const searchPlaceholder =
    activeTab === 'emoji' ? 'Search emojis...' : activeTab === 'gif' ? 'Search GIFs...' : activeTab === 'bitmoji' ? 'Search Bitmoji...' : 'Search stickers...';

  const renderEmpty = (message: string) => (
    <div className="chat-picker-empty">
      <Search size={26} />
      <span>{message}</span>
    </div>
  );

  const renderStickerCard = (sticker: StickerPick) => {
    const isFav = favStickers.includes(sticker.id);
    return (
      <div
        key={sticker.id}
        className="chat-picker-sticker-card"
        onClick={() => handlePickSticker(sticker)}
        role="button"
        tabIndex={0}
        onKeyDown={(e) => { if (e.key === 'Enter') handlePickSticker(sticker); }}
        aria-label={`Send sticker: ${sticker.label}`}
      >
        <button
          type="button"
          className="sticker-fav-btn"
          onClick={(e) => toggleFav(e, sticker.id)}
          title={isFav ? 'Remove from favorites' : 'Add to favorites'}
          aria-label={isFav ? 'Remove from favorites' : 'Add to favorites'}
        >
          <Star size={11} color={isFav ? '#ffd700' : 'currentColor'} fill={isFav ? '#ffd700' : 'none'} />
        </button>
        <span className="chat-picker-sticker-emoji">{sticker.emoji}</span>
        <span className="chat-picker-sticker-overlay">{sticker.label}</span>
      </div>
    );
  };

  const renderStickerBody = () => (
    <div className="chat-picker-grid chat-picker-grid-sticker">
      <div
        className="chat-picker-create"
        onClick={() => alert('Custom sticker maker is coming soon!')}
        role="button"
        tabIndex={0}
        onKeyDown={(e) => { if (e.key === 'Enter') alert('Custom sticker maker is coming soon!'); }}
        aria-label="Create sticker"
      >
        <div className="chat-picker-create-icon">
          <Plus size={22} strokeWidth={2.5} />
          <Sparkles size={11} className="create-sparkle" />
        </div>
        <span className="chat-picker-create-label">Create sticker</span>
      </div>
      {stickerList.map(renderStickerCard)}
      {stickerList.length === 0 && (
        <div className="chat-picker-empty chat-picker-empty-inline">
          <Star size={22} />
          <span>
            {query
              ? 'No stickers match your search'
              : stickerView === 'recent'
                ? 'No recent stickers yet. Send one and it shows up here.'
                : 'No favorites yet. Tap the star on any sticker to save it.'}
          </span>
        </div>
      )}
    </div>
  );

  return (
    <div className="chat-tray">
      {/* 1. Top Drawer Navigation Bar: Search | Emoji | GIF | Stickers | Edit */}
      <div className="chat-picker-topbar" role="tablist" aria-label="Media picker navigation">
        {searchOpen ? (
          <>
            <button
              type="button"
              className="chat-picker-topbtn"
              onClick={closeSearch}
              title="Close search"
              aria-label="Close search"
            >
              <X size={17} />
            </button>
            <div className="chat-picker-searchfield">
              <Search size={14} />
              <input
                autoFocus
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder={searchPlaceholder}
                aria-label={searchPlaceholder}
              />
              {searchQuery && (
                <button type="button" onClick={() => setSearchQuery('')} aria-label="Clear search">
                  <X size={14} />
                </button>
              )}
            </div>
          </>
        ) : (
          <>
            <button
              type="button"
              className="chat-picker-topbtn"
              onClick={() => setSearchOpen(true)}
              title="Search emojis, stickers & GIFs"
              aria-label="Search emojis, stickers and GIFs"
            >
              <Search size={17} />
            </button>
            <div className="chat-picker-tabs">
              <button
                type="button"
                role="tab"
                aria-selected={activeTab === 'emoji'}
                className={`chat-picker-tab${activeTab === 'emoji' ? ' active' : ''}`}
                onClick={() => onTabChange('emoji')}
                title="Emoji"
              >
                <Smile size={16} />
                <span>Emoji</span>
              </button>
              <button
                type="button"
                role="tab"
                aria-selected={activeTab === 'bitmoji'}
                className={`chat-picker-tab${activeTab === 'bitmoji' ? ' active' : ''}`}
                onClick={() => onTabChange('bitmoji')}
                title="Bitmoji"
              >
                <Sparkles size={16} />
                <span>Bitmoji</span>
              </button>
              <button
                type="button"
                role="tab"
                aria-selected={activeTab === 'sticker'}
                className={`chat-picker-tab${activeTab === 'sticker' ? ' active' : ''}`}
                onClick={() => onTabChange('sticker')}
                title="Stickers"
              >
                <StickerIcon size={16} />
                <span>Stickers</span>
              </button>
              <button
                type="button"
                role="tab"
                aria-selected={activeTab === 'gif'}
                className={`chat-picker-tab${activeTab === 'gif' ? ' active' : ''}`}
                onClick={() => onTabChange('gif')}
                title="GIFs"
              >
                <span className="chat-picker-gif-badge">GIF</span>
              </button>
            </div>
            <button
              type="button"
              className="chat-picker-topbtn"
              onClick={() => alert('Custom sticker maker is coming soon!')}
              title="Customize stickers"
              aria-label="Customize stickers"
            >
              <Pencil size={15} />
            </button>
          </>
        )}
      </div>

      {/* 2. Scrollable Content Area */}
      <div className="chat-picker-body">
        {activeTab === 'emoji' &&
          (emojiList.length > 0 ? (
            <div className="chat-picker-grid chat-picker-grid-emoji">
              {emojiList.map((emoji) => (
                <button
                  key={emoji}
                  type="button"
                  onClick={() => handlePickEmoji(emoji)}
                  style={{ fontSize: '23px' }}
                  aria-label={`Insert emoji ${emoji}`}
                >
                  {emoji}
                </button>
              ))}
            </div>
          ) : renderEmpty('No recent emojis yet. Pick a few and they will show up here.'))}

        {activeTab === 'bitmoji' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <button
              type="button"
              onClick={() => alert('Create your avatar coming soon!')}
              style={{
                width: '100%',
                height: '44px',
                borderRadius: '999px',
                background: 'linear-gradient(135deg, #FF3D77 0%, #B45CFF 100%)',
                border: 'none',
                color: '#F5F2F7',
                fontWeight: 700,
                fontSize: '13px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
                cursor: 'pointer',
              }}
            >
              <Sparkles size={16} />
              Create your avatar
            </button>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '8px' }}>
              {['😊', '😍', '😂', '🥰', '😎', '😘'].map((emo, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => onInsertEmoji(emo)}
                  style={{
                    height: '90px',
                    borderRadius: '14px',
                    background: '#1A1722',
                    border: '1px solid #26212F',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '42px',
                    cursor: 'pointer',
                  }}
                >
                  {emo}
                </button>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'sticker' && renderStickerBody()}

        {activeTab === 'gif' &&
          (gifList.length > 0 ? (
            <div className="chat-picker-grid chat-picker-grid-gif">
              {gifList.map((gif) => (
                <button
                  key={gif.id}
                  type="button"
                  className="chat-picker-gif"
                  onClick={() => handlePickGif(gif)}
                  aria-label={`Send GIF: ${gif.title}`}
                >
                  <img
                    src={gif.url}
                    alt={gif.title}
                    loading="lazy"
                    onError={(e) => {
                      (e.currentTarget as HTMLImageElement).style.display = 'none';
                      const parent = (e.currentTarget as HTMLImageElement).parentElement;
                      if (parent && !parent.querySelector('.gif-fallback')) {
                        const fallback = document.createElement('div');
                        fallback.className = 'gif-fallback';
                        fallback.style.cssText = 'display:flex;align-items:center;justify-content:center;height:100%;color:#B3AEC0;font-size:11px;text-align:center;padding:8px;';
                        fallback.textContent = 'Tap to retry';
                        parent.appendChild(fallback);
                      }
                    }}
                  />
                  <span>{gif.title}</span>
                </button>
              ))}
            </div>
          ) : renderEmpty('No recent GIFs yet. Send one and it shows up here.'))}
      </div>

      {/* 3. Bottom Category & Pack Bar */}
      <div className="chat-picker-catbar">
        {activeTab === 'emoji' && (
          <>
            <button
              type="button"
              className={`chat-picker-cat${emojiView === 'recent' ? ' active' : ''}`}
              onClick={() => { setEmojiView('recent'); setSearchQuery(''); }}
              title="Recent emojis"
              aria-label="Recent emojis"
            >
              <Clock size={15} />
            </button>
            <span className="chat-picker-cat-sep" />
            {EMOJI_CATEGORIES.map((cat, idx) => (
              <button
                key={cat.title}
                type="button"
                className={`chat-picker-cat${emojiView === idx && !query ? ' active' : ''}`}
                onClick={() => { setEmojiView(idx); setSearchQuery(''); }}
                title={cat.title}
                aria-label={cat.title}
              >
                {cat.icon}
              </button>
            ))}
          </>
        )}

        {activeTab === 'sticker' && (
          <>
            <button
              type="button"
              className={`chat-picker-cat${stickerView === 'recent' ? ' active' : ''}`}
              onClick={() => { setStickerView('recent'); setSearchQuery(''); }}
              title="Recent stickers"
              aria-label="Recent stickers"
            >
              <Clock size={15} />
            </button>
            <button
              type="button"
              className={`chat-picker-cat${stickerView === 'fav' ? ' active' : ''}`}
              onClick={() => { setStickerView('fav'); setSearchQuery(''); }}
              title="Favorite stickers"
              aria-label="Favorite stickers"
            >
              <Star size={15} />
            </button>
            <span className="chat-picker-cat-sep" />
            {STICKER_PACKS.map((pack, idx) => (
              <button
                key={pack.id}
                type="button"
                className={`chat-picker-cat${stickerView === idx && !query ? ' active' : ''}`}
                onClick={() => { setStickerView(idx); setSearchQuery(''); }}
                title={pack.title}
                aria-label={pack.title}
              >
                {pack.icon}
              </button>
            ))}
            <button
              type="button"
              className="chat-picker-cat chat-picker-cat-plus"
              onClick={() => alert('Sticker store is coming soon!')}
              title="Get more sticker packs"
              aria-label="Get more sticker packs"
            >
              <Plus size={16} />
            </button>
          </>
        )}

        {activeTab === 'gif' && (
          <>
            <button
              type="button"
              className={`chat-picker-cat${gifView === 'recent' ? ' active' : ''}`}
              onClick={() => { setGifView('recent'); setSearchQuery(''); }}
              title="Recent GIFs"
              aria-label="Recent GIFs"
            >
              <Clock size={15} />
            </button>
            <span className="chat-picker-cat-sep" />
            <button
              type="button"
              className={`chat-picker-cat${gifView === 'trending' ? ' active' : ''}`}
              onClick={() => { setGifView('trending'); setSearchQuery(''); }}
              title="Trending GIFs"
              aria-label="Trending GIFs"
            >
              <Flame size={15} />
            </button>
            <button
              type="button"
              className="chat-picker-cat chat-picker-cat-plus"
              onClick={() => alert('GIF library search is coming soon!')}
              title="More GIFs"
              aria-label="More GIFs"
            >
              <Plus size={16} />
            </button>
          </>
        )}
      </div>
    </div>
  );
};
