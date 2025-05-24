class AuthValidator {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldName ?? 'this field'}';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    return validateRequired(value, fieldName: 'your name');
  }

  // Username validation (basic format validation only)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }

    // Remove whitespace and convert to lowercase for validation
    final cleanValue = value.trim().toLowerCase();

    if (cleanValue.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (cleanValue.length > 20) {
      return 'Username must be 20 characters or less';
    }

    // Allow only alphanumeric characters and underscores
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(cleanValue)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    // Username cannot start or end with underscore
    if (cleanValue.startsWith('_') || cleanValue.endsWith('_')) {
      return 'Username cannot start or end with underscore';
    }

    // Username cannot have consecutive underscores
    if (cleanValue.contains('__')) {
      return 'Username cannot have consecutive underscores';
    }

    return null;
  }

  // Username validation with uniqueness check
  static String? validateUsernameWithUniqueness(
    String? value,
    List<String> existingUsernames,
  ) {
    // First check basic validation
    final basicValidation = validateUsername(value);
    if (basicValidation != null) return basicValidation;

    // Then check uniqueness
    if (existingUsernames.contains(value!.toLowerCase())) {
      return 'Username is already taken';
    }

    return null;
  }

  // Real-time username validation for onChange
  static String? validateUsernameRealTime(
    String? value,
    List<String>? existingUsernames,
  ) {
    if (value == null || value.isEmpty) {
      return null; // Don't show error for empty field in real-time
    }

    // Check basic validation first
    final basicValidation = validateUsername(value);
    if (basicValidation != null) return basicValidation;

    // Check uniqueness if usernames list is available
    if (existingUsernames != null) {
      if (existingUsernames.contains(value.toLowerCase())) {
        return 'Username is already taken';
      }
    }

    return null;
  }
}
