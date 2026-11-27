import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/app_state_provider.dart';

class RubiesScreen extends ConsumerStatefulWidget {
  const RubiesScreen({super.key});

  @override
  ConsumerState<RubiesScreen> createState() => _RubiesScreenState();
}

class _RubiesScreenState extends ConsumerState<RubiesScreen> {
  bool _howWorksOpen = false;

  final List<Map<String, dynamic>> _transactions = [
    {'title': '+40 Daily Streak Bonus', 'time': 'Today, 09:30 AM', 'amount': '+40', 'isCredit': true},
    {'title': '-20 Instant Random Call (Meera)', 'time': 'Today, 10:15 AM', 'amount': '-20', 'isCredit': false},
    {'title': '+500 Ruby Bundle (Popular Flame)', 'time': 'Yesterday', 'amount': '+550', 'isCredit': true},
    {'title': '-50 Mega Crush Dispatched (Ananya)', 'time': 'Nov 15', 'amount': '-50', 'isCredit': false},
  ];

  void _buyPackage(String name, int rubies, String price) {
    ref.read(appStateProvider.notifier).addRubies(rubies);
    setState(() {
      _transactions.insert(0, {
        'title': '+$rubies $name Top-up ($price)',
        'time': 'Just now',
        'amount': '+$rubies',
        'isCredit': true,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 $rubies Rubies added to your wallet!'),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF140A12) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1B1119) : Colors.white;
    final innerBg = isDark ? const Color(0xFF140A12) : const Color(0xFFFFF7ED);
    final borderColor = isDark ? const Color(0xFF2E1E2B) : Colors.grey.shade200;
    final primaryText = isDark ? Colors.white : const Color(0xFF181A24);
    final mutedText = isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600;
    final iconBg = isDark ? const Color(0x1AFFFFFF) : Colors.grey.shade100;
    final iconBorder = isDark ? const Color(0x26FFFFFF) : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header: < Back, "YoUnMe Rubies"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: headerBg,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: iconBorder),
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          size: 16, color: primaryText),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'YoUnMe Rubies',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Balance Card (brand gradient stays rich & legible in both modes)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF2E1225), const Color(0xFF1B1119)]
                              : [const Color(0xFFFFE4EC), const Color(0xFFFFFFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0x66EC4899)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33EC4899),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x80EC4899),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.diamond, size: 28, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CURRENT RUBY BALANCE',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: mutedText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${appState.rubyBalance} Rubies',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Expandable accordion: "How Rubies Work"
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: _howWorksOpen,
                          onExpansionChanged: (v) => setState(() => _howWorksOpen = v),
                          title: Text(
                            'How Rubies Work',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: primaryText),
                          ),
                          leading: const Icon(Icons.help_outline,
                              color: Color(0xFFEC4899), size: 20),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text(
                                '• 20 Rubies/min for HD instant live random voice & video calls.\n'
                                '• 50 Rubies to send a priority Mega Crush directly to top admirers.\n'
                                '• 10 Rubies to unlock an additional swipe rewind if daily free undo is used.\n'
                                '• Rubies never expire and can be earned daily through streaks.',
                                style: TextStyle(
                                    fontSize: 12, color: mutedText, height: 1.5),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: innerBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0x33F59E0B)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.stars,
                                          color: Color(0xFFF59E0B), size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Ways to Earn Free Rubies',
                                        style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: primaryText),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _freeRubyRow('Daily Streak check-in',
                                      '+10 to +70 Rubies daily', primaryText),
                                  _freeRubyRow(
                                      'Complete biometric face verification',
                                      '+50 Rubies instant',
                                      primaryText),
                                  _freeRubyRow('Invite a friend with your code',
                                      '+100 Rubies per invite', primaryText),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Text(
                      'Top Up Rubies (INR)',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: primaryText),
                    ),
                    const SizedBox(height: 10),

                    _buildRubyPackageCard(
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      primaryText: primaryText,
                      name: 'Starter Crush',
                      badge: 'Quick Refill',
                      rubies: 100,
                      price: '₹99',
                      isPopular: false,
                      onBuy: () => _buyPackage('Starter Crush', 100, '₹99'),
                    ),
                    const SizedBox(height: 10),

                    _buildRubyPackageCard(
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      primaryText: primaryText,
                      name: 'Popular Flame',
                      badge: 'Most Popular',
                      rubies: 550,
                      bonusText: '+50 Free Bonus',
                      price: '₹399',
                      isPopular: true,
                      onBuy: () => _buyPackage('Popular Flame', 550, '₹399'),
                    ),
                    const SizedBox(height: 10),

                    _buildRubyPackageCard(
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      primaryText: primaryText,
                      name: 'VIP Inferno',
                      badge: 'Best Value',
                      rubies: 1400,
                      bonusText: '+200 Free Bonus',
                      price: '₹799',
                      isPopular: false,
                      onBuy: () => _buyPackage('VIP Inferno', 1400, '₹799'),
                    ),
                    const SizedBox(height: 18),

                    Text(
                      'Transaction History',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: primaryText),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _transactions.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: borderColor, height: 1),
                        itemBuilder: (context, i) {
                          final tx = _transactions[i];
                          final isCredit = tx['isCredit'] as bool;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCredit
                                    ? const Color(0x2622C55E)
                                    : const Color(0x26EF4444),
                              ),
                              child: Icon(
                                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isCredit
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFEF4444),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              tx['title'] as String,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: primaryText),
                            ),
                            subtitle: Text(
                              tx['time'] as String,
                              style: TextStyle(fontSize: 11, color: mutedText),
                            ),
                            trailing: Text(
                              '${tx['amount']} 💎',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isCredit
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRubyPackageCard({
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required String name,
    required String badge,
    required int rubies,
    String? bonusText,
    required String price,
    required bool isPopular,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPopular ? const Color(0xFFEC4899) : borderColor,
          width: isPopular ? 1.5 : 1,
        ),
        boxShadow: isPopular
            ? [
                const BoxShadow(
                  color: Color(0x33EC4899),
                  blurRadius: 14,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPopular
                  ? const Color(0x33EC4899)
                  : (isDark ? const Color(0x1AFFFFFF) : Colors.pink.shade50),
            ),
            child: Icon(
              Icons.diamond,
              color: isPopular ? const Color(0xFFEC4899) : const Color(0xFFFB7185),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: primaryText),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isPopular
                            ? const Color(0x33EC4899)
                            : const Color(0x2638BDF8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isPopular
                              ? const Color(0xFFEC4899)
                              : const Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$rubies Rubies',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFB7185)),
                    ),
                    if (bonusText != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        bonusText,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF22C55E)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onBuy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: isPopular
                    ? const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFEC4899)])
                    : null,
                color: isPopular
                    ? null
                    : (isDark ? const Color(0xFF2E1E2B) : Colors.grey.shade200),
                border: isPopular
                    ? null
                    : Border.all(
                        color: isDark ? const Color(0x33FFFFFF) : Colors.grey.shade300),
              ),
              child: Text(
                price,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isPopular ? Colors.white : primaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _freeRubyRow(String title, String reward, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: textColor)),
          Text(reward,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF22C55E))),
        ],
      ),
    );
  }
}
