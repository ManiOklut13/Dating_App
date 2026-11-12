import React, { useRef } from 'react';
import { 
  Film, 
  UtensilsCrossed, 
  Coffee, 
  Gamepad2, 
  Star, 
  Music, 
  ChefHat, 
  TreePine, 
  Mic2, 
  Cake, 
  Palette, 
  BookOpen 
} from 'lucide-react';
import { planDateTheme } from '../theme';

interface DateType {
  id: string;
  label: string;
  icon: React.ReactNode;
}

interface DateTypeCardProps {
  types: DateType[];
  selectedType: string;
  onTypeSelect: (typeId: string) => void;
}

const getIconForType = (label: string): React.ReactNode => {
  const iconMap: Record<string, React.ReactNode> = {
    'Movie Night': <Film size={26} />,
    'Dinner': <UtensilsCrossed size={26} />,
    'Coffee': <Coffee size={26} />,
    'Game Night': <Gamepad2 size={26} />,
    'Stargazing': <Star size={26} />,
    'Music Jam': <Music size={26} />,
    'Cook Together': <ChefHat size={26} />,
    'Park Walk': <TreePine size={26} />,
    'Karaoke': <Mic2 size={26} />,
    'Dessert': <Cake size={26} />,
    'Art & Paint': <Palette size={26} />,
    'Book Chat': <BookOpen size={26} />,
  };
  return iconMap[label] || <Film size={26} />;
};

export const DateTypeCard: React.FC<DateTypeCardProps> = ({
  types,
  selectedType,
  onTypeSelect,
}) => {
  const scrollRef = useRef<HTMLDivElement>(null);

  return (
    <div>
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '10px',
          padding: `0 ${planDateTheme.spacing.screenPadding}px`,
        }}
      >
        <h3
          style={{
            fontSize: '16px',
            fontWeight: planDateTheme.typography.weights.bold,
            color: planDateTheme.colors.text,
            margin: 0,
            fontFamily: planDateTheme.typography.fontFamily,
          }}
        >
          Date Type
        </h3>
        <span
          style={{
            fontSize: '12px',
            fontWeight: planDateTheme.typography.weights.semibold,
            color: planDateTheme.colors.muted,
            fontFamily: planDateTheme.typography.fontFamily,
          }}
        >
          Swipe for more &gt;
        </span>
      </div>

      <div
        ref={scrollRef}
        style={{
          display: 'flex',
          gap: '10px',
          overflowX: 'auto',
          overflowY: 'hidden',
          scrollSnapType: 'x mandatory',
          padding: `0 ${planDateTheme.spacing.screenPadding}px`,
          margin: `0 -${planDateTheme.spacing.screenPadding}px`,
          scrollbarWidth: 'none',
          msOverflowStyle: 'none',
        }}
        className="date-type-scroll"
      >
        {types.map((type) => {
          const isSelected = selectedType === type.id;
          return (
            <button
              key={type.id}
              onClick={() => onTypeSelect(type.id)}
              aria-label={`Select ${type.label}`}
              style={{
                width: '104px',
                height: '92px',
                borderRadius: `${planDateTheme.borderRadius.large}px`,
                background: isSelected ? planDateTheme.gradients.primary : planDateTheme.colors.idleChip,
                border: isSelected ? 'none' : `1px solid ${planDateTheme.colors.idleChipBorder}`,
                color: '#FFFFFF',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '6px',
                cursor: 'pointer',
                flexShrink: 0,
                scrollSnapAlign: 'start',
                padding: '8px',
                transition: 'all 0.2s ease',
                minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
                minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
              }}
            >
              <div style={{ strokeWidth: 1.8 }}>
                {getIconForType(type.label)}
              </div>
              <span
                style={{
                  fontSize: '13px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  fontFamily: planDateTheme.typography.fontFamily,
                  textAlign: 'center',
                  lineHeight: '1.2',
                }}
              >
                {type.label}
              </span>
            </button>
          );
        })}
      </div>

      <style>{`
        .date-type-scroll::-webkit-scrollbar {
          display: none;
        }
      `}</style>
    </div>
  );
};

export const VIRTUAL_DATE_TYPES: DateType[] = [
  { id: 'movie-night', label: 'Movie Night', icon: 'film' },
  { id: 'dinner', label: 'Dinner', icon: 'utensils' },
  { id: 'coffee', label: 'Coffee', icon: 'coffee' },
  { id: 'game-night', label: 'Game Night', icon: 'gamepad' },
  { id: 'stargazing', label: 'Stargazing', icon: 'star' },
  { id: 'music-jam', label: 'Music Jam', icon: 'music' },
  { id: 'cook-together', label: 'Cook Together', icon: 'chef' },
  { id: 'park-walk', label: 'Park Walk', icon: 'tree' },
  { id: 'karaoke', label: 'Karaoke', icon: 'mic' },
  { id: 'dessert', label: 'Dessert', icon: 'cake' },
  { id: 'art-paint', label: 'Art & Paint', icon: 'palette' },
  { id: 'book-chat', label: 'Book Chat', icon: 'book' },
];

export const OFFLINE_DATE_TYPES: DateType[] = [
  { id: 'dinner', label: 'Dinner', icon: 'utensils' },
  { id: 'coffee', label: 'Coffee', icon: 'coffee' },
  { id: 'movie-night', label: 'Movie Night', icon: 'film' },
  { id: 'park-walk', label: 'Park Walk', icon: 'tree' },
  { id: 'dessert', label: 'Dessert', icon: 'cake' },
  { id: 'live-music', label: 'Live Music', icon: 'music' },
  { id: 'bowling', label: 'Bowling', icon: 'gamepad' },
  { id: 'art-paint', label: 'Art & Paint', icon: 'palette' },
  { id: 'picnic', label: 'Picnic', icon: 'tree' },
];
