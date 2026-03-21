enum AuthState {
  loggedOut,
  authenticating,
  authenticated,
  error;

  bool get isLoggedIn => this == authenticated;
  bool get isLoggedOut => this == loggedOut;
  bool get isAuthenticating => this == authenticating;
  bool get hasError => this == error;
}
