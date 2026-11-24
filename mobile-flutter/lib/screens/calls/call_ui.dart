import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared design tokens + small widgets for the call surfaces.
// ─────────────────────────────────────────────────────────────────────────────
class CallUi {
  CallUi._();

  static const Color bg = Color(0xFF08060C);
  static const Color panel = Color(0xFF120F17);
  static const Color card = Color(0xFF150F1C);
  static const Color sheet = Color(0xFF13101A);
  static const Color pink = Color(0xFFFF2D55);
  static const Color pinkSoft = Color(0xFFFF6B8B);
  static const Color audio = Color(0xFF22D3EE);
  static const Color video = Color(0xFFFF2D6A);
  static const Color green = Color(0xFF22C55E);
  static const Color verified = Color(0xFF4DA3FF);
  static const Color muted = Color(0xFF8E88A0);
  static const Color border = Color(0x1FFFFFFF);

  static const LinearGradient audioTab = LinearGradient(
    colors: [Color(0xFFFF4D7E), Color(0xFFE0264F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient videoTab = LinearGradient(
    colors: [Color(0xFFFF4D7E), Color(0xFFD6249B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient historyTab = LinearGradient(
    colors: [Color(0xFFC026D3), Color(0xFFFF4D7E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Local avatar asset for a demo contact (assets are already bundled).
  static String? avatarAssetFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('ananya') || n.contains('meera kapoor') || n.contains('tara')) {
      return 'assets/images/ananya.jpg';
    }
    if (n.contains('riya') || n.contains('meera') || n.contains('aanya')) {
      return 'assets/images/riya.jpg';
    }
    if (n.contains('kabir') || n.contains('arjun')) {
      return 'assets/images/aditya.jpg';
    }
    if (n.contains('vikram') || n.contains('rohit')) {
      return 'assets/images/rohit.jpg';
    }
    return null;
  }
}

/// Rounded contact avatar with an initials fallback.
class CallAvatar extends StatelessWidget {
  final String name;
  final String? asset;
  final double size;
  final double radius;

  const CallAvatar({
    super.key,
    required this.name,
    this.asset,
    this.size = 52,
    this.radius = 14,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      color: const Color(0xFF2A2036),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.32,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: asset == null
          ? fallback
          : Image.asset(
              asset!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }
}

/// Circular audio/video call button used on contact and history rows.
class CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  const CallActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.10),
        shape: CircleBorder(
          side: BorderSide(color: color.withValues(alpha: 0.35)),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: color, size: size * 0.45),
          ),
        ),
      ),
    );
  }
}

/// "Today, 9:15 AM" / "Yesterday, 6:20 PM" / "3 days ago".
String callTimeLabel(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dt.year, dt.month, dt.day);
  final diff = today.difference(date).inDays;
  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';

  if (diff <= 0) return 'Today, $hour12:$minute $period';
  if (diff == 1) return 'Yesterday, $hour12:$minute $period';
  return '$diff days ago';
}

/// "14m 20s" / "12s" duration label.
String callDurationLabel(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  if (minutes == 0) return '${seconds}s';
  if (seconds == 0) return '${minutes}m';
  return '${minutes}m ${seconds}s';
}
