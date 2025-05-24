import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/features/auth/utils/auth_validator.dart';
import 'package:mone/features/auth/widgets/password_input_field.dart';
import 'package:mone/widgets/profile_image_picker.dart';
import 'package:mone/widgets/custom_button.dart';
import 'package:mone/widgets/custom_input_field.dart';
import 'dart:io';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _profileImage;
  bool _acceptedTerms = false;
  bool _isLoading = false;
  String? _usernameError;

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onProfileImageSelected(File? image) {
    setState(() {
      _profileImage = image;
    });
  }

  String? _validateUsername(String? value) {
    final allUsernamesAsync = ref.read(allUsernamesStreamProvider);
    return allUsernamesAsync.when(
      data:
          (usernames) =>
              AuthValidator.validateUsernameWithUniqueness(value, usernames),
      loading: () => AuthValidator.validateUsername(value),
      error: (_, __) => AuthValidator.validateUsername(value),
    );
  }

  void _checkUsernameAvailability(String value) {
    final allUsernamesAsync = ref.read(allUsernamesStreamProvider);

    allUsernamesAsync.when(
      data: (usernames) {
        setState(() {
          _usernameError = AuthValidator.validateUsernameRealTime(
            value,
            usernames,
          );
        });
      },
      loading: () {
        setState(() {
          _usernameError = AuthValidator.validateUsernameRealTime(value, null);
        });
      },
      error: (_, __) {
        setState(() {
          _usernameError = AuthValidator.validateUsernameRealTime(value, null);
        });
      },
    );
  }

  Future<void> _register() async {
    // Clear real-time error before form validation
    setState(() {
      _usernameError = null;
    });

    if (_formKey.currentState!.validate() && _acceptedTerms) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        await ref
            .read(userProvider.notifier)
            .register(
              _emailController.text.trim(),
              _passwordController.text,
              _displayNameController.text.trim(),
              _usernameController.text.trim(),
              _profileImage?.path,
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms of service')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildRegistrationForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Picture
          ProfileImagePickerSection(
            profileImage: _profileImage,
            displayName: _displayNameController.text,
            onImageSelected: _onProfileImageSelected,
          ),

          const SizedBox(height: 32),

          // Display Name Field
          CustomInputField(
            controller: _displayNameController,
            labelText: 'Display Name',
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: AuthValidator.validateName,
            onChanged: (_) {
              if (_profileImage == null) {
                setState(() {});
              }
            },
          ),

          const SizedBox(height: 16),

          // Username Field
          Consumer(
            builder: (context, ref, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInputField(
                    controller: _usernameController,
                    labelText: 'Username',
                    hintText: 'Choose a unique username',
                    prefixIcon: Icons.alternate_email,
                    validator: _validateUsername,
                    onChanged: _checkUsernameAvailability,
                  ),
                  if (_usernameError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 6),
                      child: Text(
                        _usernameError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Email Field
          CustomInputField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: AuthValidator.validateEmail,
          ),

          const SizedBox(height: 16),

          // Password Field
          PasswordInputField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Create a password',
            validator: AuthValidator.validatePassword,
          ),

          const SizedBox(height: 16),

          // Confirm Password Field
          PasswordInputField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            hintText: 'Confirm your password',
            validator:
                (value) => AuthValidator.validateConfirmPassword(
                  value,
                  _passwordController.text,
                ),
          ),

          const SizedBox(height: 24),

          _buildTermsCheckbox(),

          const SizedBox(height: 32),

          CustomButton(
            text: 'Create Account',
            onPressed: _register,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) {
            setState(() {
              _acceptedTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptedTerms = !_acceptedTerms;
              });
            },
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
