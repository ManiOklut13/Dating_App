import 'package:flutter/material.dart';
import 'email_link_waiting_page.dart';

class EmailEntryPage extends StatefulWidget {
  final bool startedWithEmail;
  final bool isPrimaryFlow;
  final String? verifiedPhone;
  final String? createdPassword;

  const EmailEntryPage({
    super.key,
    this.startedWithEmail = true,
    this.isPrimaryFlow = true,
    this.verifiedPhone,
    this.createdPassword,
  });

  @override
  State<EmailEntryPage> createState() => _EmailEntryPageState();
}

class _EmailEntryPageState extends State<EmailEntryPage> {
  final _emailController = TextEditingController();
  bool _isSending = false;

  bool get _isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
      .hasMatch(_emailController.text.trim());

  Future<void> _confirmEmailAndSendLink() async {
    if (!_isValidEmail || _isSending) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSending = true);

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSending = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailLinkWaitingPage(
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
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
            left: -60,
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
                              child: const Icon(
                                  Icons.mark_email_unread_rounded,
                                  color: Color(0xFFFF2E55),
                                  size: 32),
                            ),
                            const SizedBox(height: 18),

                            Text(
                              'Enter Your Email',
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We’ll send a confirmation link to verify your email address.',
                              style: TextStyle(color: subText, fontSize: 15),
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: _isValidEmail
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
                                    'EMAIL ADDRESS',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) =>
                                        _confirmEmailAndSendLink(),
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(
                                      color: primaryText,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'name@example.com',
                                      hintStyle:
                                          TextStyle(color: Colors.grey[600]),
                                      prefixIcon: const Icon(
                                        Icons.alternate_email_rounded,
                                        color: Color(0xFFFF2E55),
                                      ),
                                      suffixIcon: _isValidEmail
                                          ? const Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.greenAccent,
                                            )
                                          : null,
                                      filled: true,
                                      fillColor: inputBg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isValidEmail
                                    ? const Color(0xFFFF2E55)
                                    : (isDark
                                        ? Colors.grey[850]
                                        : Colors.grey[300]),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isValidEmail
                                  ? _confirmEmailAndSendLink
                                  : null,
                              child: _isSending
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Confirm Email',
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
