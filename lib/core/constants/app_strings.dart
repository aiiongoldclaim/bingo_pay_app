class AppStrings {
  AppStrings._();

  // ── App ──────────────────────────────────────────────────────────
  static const String appTitle = 'BIGOD';

  // ── Auth buttons ─────────────────────────────────────────────────
  static const String loginCta = 'Login';
  static const String registerCta = 'Register';
  static const String createAccount = 'Create Account';
  static const String sendOtp = 'Send OTP';
  static const String resendOtp = 'Resend OTP';
  static const String verifyOtp = 'Verify OTP';
  static const String resetPasswordCta = 'Reset Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = 'No Account';
  static const String signup = 'Sign Up';
  static const String signin = 'Sign In';
  static const String alreadyAccount = 'Already have an account?';
  static const String continueButton = 'Continue';
  static const String secureLogin = 'Back to secure login?';

  // ── Wishlist ─────────────────────────────────────────────────────
  static const String wishlistAdded =
      'Product added to Wishlist successfully.';

  // ── Error states ─────────────────────────────────────────────────
  static const String rateLimitedTitle = 'High Demand! 🚀';
  static const String rateLimitedSubtitle = "Everyone's Shopping Right Now";
  static const String rateLimitedBody =
      "Our servers are buzzing with shoppers! We're working at full capacity "
      'to keep everything running smoothly.';
  static const String rateLimitedFooter = 'Your cart and wishlist are safe 💙';

  static const String errorTitle = 'Oops!';
  static const String errorSubtitle = 'Something Went Wrong';
  static const String errorFooter = "We're here to help. Try again shortly.";

  static const String retryNow = 'Try Again';
  static const String retryWaiting = 'Waiting for you...';

  // ── Product listing ──────────────────────────────────────────────
  static const String emptyFilteredTitle = 'No matching products';
  static const String emptyFilteredBody =
      'Try adjusting or clearing your filters to see more results.';
  static const String emptyTitle = 'No products yet';
  static const String emptyBody =
      'This category is currently empty. Check back later for new arrivals.';
  static const String clearFilters = 'Clear filters';

  static String retryInSeconds(int seconds) => 'Retry in $seconds sec';
}