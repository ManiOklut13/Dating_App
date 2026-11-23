import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'email_entry_page.dart';
import 'email_link_waiting_page.dart';

class CreatePasswordPage extends StatefulWidget {
  final String? verifiedPhone;
  final String? email;

  const CreatePasswordPage({super.key, this.verifiedPhone, this.email});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  String get _password => _passwordController.text;
  String get _confirm => _confirmController.text;

  bool get _hasMinLength => _password.length >= 8;
  bool get _hasUppercase => _password.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _password.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar =>
      _password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase && _hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecialChar) score++;
    return score;
  }

  bool get _isPasswordStrong =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecialChar;

  bool get _passwordsMatch => _password.isNotEmpty && _password == _confirm;

  bool get _canProceed => _isPasswordStrong && _passwordsMatch;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -50,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF2E55).withOpacity(0.15),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
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
                  const SizedBox(height: 24),

                  // Glowing Shield Icon
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
                    child: const Icon(Icons.shield_rounded,
                        color: Color(0xFFFF2E55), size: 32),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Create Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set a strong password to protect your YoUnMe profile.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                  const SizedBox(height: 24),

                  // Card Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161D),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePass,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            labelStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: Color(0xFFFF2E55)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0B0B0F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 4-Segment Strength Bar
                        Row(
                          children: List.generate(4, (index) {
                            final active = index < _strengthScore;
                            Color barColor = Colors.white12;
                            if (active) {
                              if (_strengthScore <= 2) {
                                barColor = Colors.orangeAccent;
                              } else if (_strengthScore == 3) {
                                barColor = Colors.amberAccent;
                              } else {
                                barColor = Colors.greenAccent;
                              }
                            }
                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: 5,
                                margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 14),

                        // Compact Criteria Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _criteriaPill('8+ Chars', _hasMinLength),
                            _criteriaPill('Uppercase (A-Z)', _hasUppercase),
                            _criteriaPill('Lowercase (a-z)', _hasLowercase),
                            _criteriaPill('Number (0-9)', _hasNumber),
                            _criteriaPill('Symbol (@#\$)', _hasSpecialChar),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Field
                        TextField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(
                              _passwordsMatch
                                  ? Icons.check_circle_rounded
                                  : Icons.lock_reset_rounded,
                              color: _passwordsMatch
                                  ? Colors.greenAccent
                                  : const Color(0xFFFF2E55),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0B0B0F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        if (_confirm.isNotEmpty && !_passwordsMatch)
                          const Padding(
                            padding: EdgeInsets.only(top: 10, left: 4),
                            child: Text(
                              'Passwords do not match yet.',
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canProceed
                            ? const Color(0xFFFF2E55)
                            : Colors.grey[850],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: (_canProceed && !_isSubmitting)
                          ? () async {
                              final email = widget.email;
                              if (email != null && email.isNotEmpty) {
                                setState(() => _isSubmitting = true);
                                try {
                                  final result = await AuthService.instance.signUp(
                                    email: email,
                                    password: _password,
                                    phone: widget.verifiedPhone,
                                  );

                                  if (!mounted) return;
                                  setState(() => _isSubmitting = false);

                                  if (!result.success) {
                                    final errorMsg = result.error ?? result.message;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMsg.isNotEmpty
                                            ? errorMsg
                                            : 'Registration failed. Please check your information.'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

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
                                  setState(() => _isSubmitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Network error: ${e.toString()}'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EmailEntryPage(
                                    isPrimaryFlow: false,
                                    verifiedPhone: widget.verifiedPhone,
                                    createdPassword: _password,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Continue',
                              style:
                                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _criteriaPill(String text, bool met) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: met
            ? Colors.greenAccent.withOpacity(0.15)
            : const Color(0xFF0B0B0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: met ? Colors.greenAccent : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_rounded : Icons.circle,
            size: met ? 14 : 6,
            color: met ? Colors.greenAccent : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.greenAccent : Colors.grey[400],
              fontSize: 12,
              fontWeight: met ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
