import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'create_password_page.dart';
import 'email_link_waiting_page.dart';

class EmailEntryPage extends StatefulWidget {
  final bool startedWithEmail;
  final bool isPrimaryFlow;
  final String? verifiedPhone;
  final String? createdPassword;

  const EmailEntryPage({
    super.key,
    bool? startedWithEmail,
    bool? isPrimaryFlow,
    this.verifiedPhone,
    this.createdPassword,
  })  : isPrimaryFlow = isPrimaryFlow ?? startedWithEmail ?? true,
        startedWithEmail = startedWithEmail ?? isPrimaryFlow ?? true;

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
    final email = _emailController.text.trim();

    // If password was already entered (from CreatePasswordPage):
    if (widget.createdPassword != null && widget.createdPassword!.isNotEmpty) {
      setState(() => _isSending = true);
      try {
        final result = await AuthService.instance.signUp(
          email: email,
          password: widget.createdPassword!,
          phone: widget.verifiedPhone,
        );

        if (!mounted) return;
        setState(() => _isSending = false);

        if (!result.success) {
          final errorMsg = result.error ?? result.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg.isNotEmpty ? errorMsg : 'Registration failed. Please check your information.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        // Navigate to EmailLinkWaitingPage waiting for confirmation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmailLinkWaitingPage(
              email: email,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // If password not entered yet, navigate to CreatePasswordPage to set password:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePasswordPage(
          verifiedPhone: widget.verifiedPhone,
          email: email,
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF16161D),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 28),

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
                          color: const Color(0xFFFF2E55).withOpacity(0.45)),
                    ),
                    child: const Icon(Icons.mark_email_unread_rounded,
                        color: Color(0xFFFF2E55), size: 32),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Enter Your Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We’ll send a confirmation link to verify your email address.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161D),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _isValidEmail
                            ? const Color(0xFFFF2E55).withOpacity(0.6)
                            : Colors.white10,
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
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: const Icon(Icons.alternate_email_rounded,
                                color: Color(0xFFFF2E55)),
                            suffixIcon: _isValidEmail
                                ? const Icon(Icons.check_circle_rounded,
                                    color: Colors.greenAccent)
                                : null,
                            filled: true,
                            fillColor: const Color(0xFF0B0B0F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValidEmail
                            ? const Color(0xFFFF2E55)
                            : Colors.grey[850],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed:
                          _isValidEmail ? _confirmEmailAndSendLink : null,
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
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
