import 'package:flutter/material.dart';
import 'phone_entry_page.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String verifiedEmail;

  const CreatePasswordScreen({
    super.key,
    required this.verifiedEmail,
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isPasswordFocused = false;

  // Password rule states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswordRules);
    _passwordFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isPasswordFocused = _passwordFocusNode.hasFocus;
    });
  }

  void _validatePasswordRules() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\];~`+=]'));
    });
  }

  // Visible ONLY when user taps into Create Password or has started typing
  bool get _shouldShowRulesBox =>
      _isPasswordFocused || _passwordController.text.isNotEmpty;

  bool get _isPasswordStrong =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecialChar;

  Future<void> _onContinue() async {
    if (!_isPasswordStrong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please meet all password requirements before continuing.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;

        if (Navigator.canPop(context)) {
          Navigator.pushNamed(
            context,
            '/enter-mobile-number',
            arguments: {'email': widget.verifiedEmail},
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: '/enter-mobile-number'),
              builder: (_) => const PhoneEntryPage(startedWithEmail: true),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePasswordRules);
    _passwordFocusNode.removeListener(_handleFocusChange);
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryColor = Color(0xFFE94057);

    final bgColor = isDark ? const Color(0xFF0B0B0F) : Colors.white;
    final cardColor = isDark ? const Color(0xFF16161D) : Colors.grey.shade50;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verified email badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${widget.verifiedEmail} verified',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Create a password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure your account before linking your mobile number.',
                  style: TextStyle(
                    fontSize: 15,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 28),

                // Create Password Field
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: textColor, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Create Password',
                    labelStyle: TextStyle(color: subTextColor),
                    hintText: 'Enter strong password',
                    hintStyle: TextStyle(color: subTextColor?.withOpacity(0.6)),
                    filled: true,
                    fillColor: cardColor,
                    prefixIcon: const Icon(Icons.lock_outline, color: primaryColor, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: subTextColor,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: primaryColor, width: 1.8),
                    ),
                  ),
                ),

                // Password Rules Box — Hidden by default; reveals on tap/typing
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: _shouldShowRulesBox
                      ? Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password must contain:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _RequirementRow(
                                label: 'At least 8 characters',
                                isMet: _hasMinLength,
                                isDark: isDark,
                              ),
                              _RequirementRow(
                                label: 'One uppercase letter (A-Z)',
                                isMet: _hasUppercase,
                                isDark: isDark,
                              ),
                              _RequirementRow(
                                label: 'One lowercase letter (a-z)',
                                isMet: _hasLowercase,
                                isDark: isDark,
                              ),
                              _RequirementRow(
                                label: 'One number (0-9)',
                                isMet: _hasNumber,
                                isDark: isDark,
                              ),
                              _RequirementRow(
                                label: 'One special character (!@#\$%^&*)',
                                isMet: _hasSpecialChar,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 20),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onContinue(),
                  style: TextStyle(color: textColor, fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: subTextColor),
                    hintText: 'Re-enter your password',
                    hintStyle: TextStyle(color: subTextColor?.withOpacity(0.6)),
                    filled: true,
                    fillColor: cardColor,
                    prefixIcon: const Icon(Icons.lock_reset_outlined, color: primaryColor, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: subTextColor,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: primaryColor, width: 1.8),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (_isPasswordStrong && !_isLoading) ? _onContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: isDark ? const Color(0xFF22222C) : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool isMet;
  final bool isDark;

  const _RequirementRow({
    required this.label,
    required this.isMet,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isMet
                  ? (isDark ? Colors.greenAccent : Colors.green.shade700)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
