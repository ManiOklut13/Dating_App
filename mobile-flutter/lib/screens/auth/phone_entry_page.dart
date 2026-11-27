import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'basic_profile_page.dart';

class PhoneEntryPage extends StatefulWidget {
  final bool startedWithEmail;

  const PhoneEntryPage({
    super.key,
    this.startedWithEmail = true,
  });

  @override
  State<PhoneEntryPage> createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends State<PhoneEntryPage> {
  final _phoneController = TextEditingController();
  String _countryCode = '+91';

  bool get _isValidPhone => _phoneController.text.trim().length == 10;

  void _onContinue() {
    if (!_isValidPhone) return;
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BasicProfilePage(),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF0B0B0F) : theme.scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF16161D) : Colors.white;
    final inputBg = isDark ? const Color(0xFF0B0B0F) : const Color(0xFFF3F4F6);
    final primaryText = isDark ? Colors.white : const Color(0xFF181A24);
    final subText = isDark ? Colors.grey[400]! : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF2E55).withOpacity(0.15),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 48).clamp(0.0, double.infinity),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back_ios_new_rounded,
                                  color: primaryText),
                              style: IconButton.styleFrom(
                                backgroundColor: cardBg,
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF2E55).withOpacity(0.25),
                                    const Color(0xFFFF6B8B).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: const Color(0xFFFF2E55)
                                        .withOpacity(0.45)),
                              ),
                              child: const Icon(Icons.phone_iphone_rounded,
                                  color: Color(0xFFFF2E55), size: 32),
                            ),
                            const SizedBox(height: 18),

                            Text(
                              'Enter Your Mobile Number',
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your mobile number to link it with your YoUnMe profile.',
                              style: TextStyle(color: subText, fontSize: 15),
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: _isValidPhone
                                      ? const Color(0xFFFF2E55).withOpacity(0.6)
                                      : (isDark
                                          ? Colors.white10
                                          : Colors.grey.shade300),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MOBILE NUMBER',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: inputBg,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _countryCode,
                                            dropdownColor: cardBg,
                                            style: TextStyle(
                                              color: primaryText,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            items: ['+91', '+1', '+44', '+971']
                                                .map((code) => DropdownMenuItem(
                                                      value: code,
                                                      child: Text(code),
                                                    ))
                                                .toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(
                                                    () => _countryCode = val);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.number,
                                          maxLength: 10,
                                          textInputAction: TextInputAction.done,
                                          onSubmitted: (_) => _onContinue(),
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          onChanged: (_) => setState(() {}),
                                          style: TextStyle(
                                            color: primaryText,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                          decoration: InputDecoration(
                                            counterText: '',
                                            hintText: '98765 43210',
                                            hintStyle: TextStyle(
                                              color: Colors.grey[600],
                                              letterSpacing: 1.2,
                                            ),
                                            suffixIcon: _isValidPhone
                                                ? const Icon(
                                                    Icons.check_circle_rounded,
                                                    color: Colors.greenAccent,
                                                  )
                                                : null,
                                            filled: true,
                                            fillColor: inputBg,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Direct Continue to Create Your Identity
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isValidPhone
                                    ? const Color(0xFFFF2E55)
                                    : (isDark
                                        ? Colors.grey[850]
                                        : Colors.grey[300]),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isValidPhone ? _onContinue : null,
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
