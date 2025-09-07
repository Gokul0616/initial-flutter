import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_alert_dialog.dart';
import '../main/main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _displayNameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final result = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _displayNameController.text.trim(),
    );

    if (result['success']) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      _showErrorDialog(result['error']);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Sign Up Failed',
        content: message,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateUsername(String? value) {
    if (value?.isEmpty ?? true) {
      return AppStringsErrors.usernameRequired;
    }
    if (!RegExp(AppConstants.usernamePattern).hasMatch(value!)) {
      return AppStringsErrors.invalidUsername;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return AppStringsErrors.emailRequired;
    }
    if (!RegExp(AppConstants.emailPattern).hasMatch(value!)) {
      return AppStringsErrors.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return AppStringsErrors.passwordRequired;
    }
    if (value!.length < 6) {
      return AppStringsErrors.passwordTooShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return AppStringsErrors.passwordsDoNotMatch;
    }
    return null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _displayNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: context.primaryText),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Center(
                          child: Column(
                            children: [
                               Text(
                                'Create Account',
                                style: AppTextStyles.headline1,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join the community',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Username Field
                        CustomTextField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          hintText: 'Username',
                          prefixIcon: Icons.alternate_email,
                          textInputAction: TextInputAction.next,
                          validator: _validateUsername,
                          onSubmitted: (_) => _displayNameFocusNode.requestFocus(),
                        ),

                        const SizedBox(height: 16),

                        // Display Name Field
                        CustomTextField(
                          controller: _displayNameController,
                          focusNode: _displayNameFocusNode,
                          hintText: 'Display Name',
                          prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return AppStringsErrors.displayNameRequired;
                            }
                            if (value!.length > AppConstants.maxDisplayNameLength) {
                              return AppStringsErrors.displayNameTooLong;
                            }
                            return null;
                          },
                          onSubmitted: (_) => _emailFocusNode.requestFocus(),
                        ),

                        const SizedBox(height: 16),

                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                          onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          validator: _validatePassword,
                          onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password Field
                        CustomTextField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          hintText: 'Confirm Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: _validateConfirmPassword,
                          onSubmitted: (_) => _signUp(),
                        ),

                        const SizedBox(height: 32),

                        // Sign Up Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading ? null : _signUp,
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(AppStrings.createAccount),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Login Link
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: RichText(
                              text: TextSpan(
                                text: AppStrings.alreadyHaveAccount + ' ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppStrings.login,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Terms and Privacy
                        Center(
                          child: Text(
                            'By signing up, you agree to our Terms of Service and Privacy Policy',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}