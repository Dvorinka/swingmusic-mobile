enum AuthState {
  loggedOut,
  authenticating,
  authenticated,
  error;

  String get displayName {
    switch (this) {
      case AuthState.loggedOut:
        return 'Logged Out';
      case AuthState.authenticating:
        return 'Authenticating';
      case AuthState.authenticated:
        return 'Authenticated';
      case AuthState.error:
        return 'Error';
    }
  }

  bool get isLoggedIn => this == AuthState.authenticated;
  bool get isLoggedOut => this == AuthState.loggedOut;
  bool get isAuthenticating => this == AuthState.authenticating;
  bool get hasError => this == AuthState.error;
}
