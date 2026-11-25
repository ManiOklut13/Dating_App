import 'package:flutter/material.dart';
import '../../services/theme_service.dart';
import 'phone_entry_page.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String verifiedEmail; // Passed from the Email Verification screen

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

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
  }

  void _validatePasswordRules() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar =
          password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\];~`+=]'));
    });
  }

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
          content:
              Text('Please meet all password requirements before continuing.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // Simulated network delay or API call to set password
        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;

        // Navigate to Enter Mobile Number Screen
        if (Navigator.canPop(context)) {
          Navigator.pushNamed(
            context,
            '/enter-mobile-number',
            arguments: {
              'email': widget.verifiedEmail,
            },
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
          SnackBar(content: Text('Failed to save password: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePasswordRules);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildRuleItem(String text, bool met, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(
            met
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: met ? Colors.greenAccent : (isDark ? Colors.grey[600] : Colors.grey[400]),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met
                  ? (isDark ? Colors.greenAccent : Colors.green[800])
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontSize: 13,
              fontWeight: met ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryColor = AppColors.flamePink;

    final bgColor = isDark ? const Color(0xFF0B0B0F) : Colors.white;
    final cardColor = isDark ? const Color(0xFF16161D) : Colors.grey.shade50;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: textColor, size: 20),
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
                // Verified badge pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
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
                    prefixIcon:
                        Icon(Icons.lock_outline, color: primaryColor, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: subTextColor,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: isDark
                          ? const BorderSide(color: Colors.white12)
                          : BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!_isPasswordStrong) {
                      return 'Password does not meet all requirements below';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Rules Checklist
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password must contain:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRuleItem('At least 8 characters', _hasMinLength, isDark),
                      _buildRuleItem('One uppercase letter (A-Z)', _hasUppercase, isDark),
                      _buildRuleItem('One lowercase letter (a-z)', _hasLowercase, isDark),
                      _buildRuleItem('One number (0-9)', _hasNumber, isDark),
                      _buildRuleItem('One special character (!@#\$%^&*)', _hasSpecialChar, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(color: textColor, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: subTextColor),
                    hintText: 'Re-enter your password',
                    hintStyle: TextStyle(color: subTextColor?.withOpacity(0.6)),
                    filled: true,
                    fillColor: cardColor,
                    prefixIcon:
                        Icon(Icons.lock_reset_rounded, color: primaryColor, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: subTextColor,
                        size: 20,
                      ),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: isDark
                          ? const BorderSide(color: Colors.white12)
                          : BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Continue CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
