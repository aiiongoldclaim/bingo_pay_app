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

  // ── Common ───────────────────────────────────────────────────────
  static const String cancel = 'Cancel';
  static const String clear = 'Clear';
  static const String close = 'CLOSE';

  // ── Wishlist ─────────────────────────────────────────────────────
  static const String wishlistTitle = 'Wishlist';
  static const String wishlistAdded =
      'Product added to Wishlist successfully.';
  static const String productCurrentlyUnavailable =
      'This product is currently unavailable';
  static const String multipleOptionsInStock =
      'This item has multiple options in stock — pick one on the product '
      'page to add it to your bag.';
  static const String clearWishlistTitle = 'Clear wishlist?';
  static const String clearWishlistContent = 'All saved items will be removed.';
  static const String viewProduct = 'View Product';
  static const String removeFromWishlist = 'Remove from Wishlist';
  static const String wishlistEmptyTitle = 'Your wishlist is empty';
  static const String wishlistEmptySubtitle =
      'Tap the heart icon on any product\nto save it here.';
  static const String exploreNowUppercase = 'EXPLORE NOW';
  static const String promoWishlistTitle = 'Good things\nare waiting!';
  static const String promoWishlistSubtitle =
      'Add more items you love\nto your wishlist.';
  static const String exploreNow = 'Explore Now';
  static const String outOfStock = 'Out of stock';
  static const String moveToBag = 'Move to Bag';
  static const String addingEllipsis = 'Adding...';

  static String itemMovedToBag(String name) => '$name moved to bag';
  static String discountOff(int percent) => '$percent% off';

  // ── Cart ─────────────────────────────────────────────────────────
  static const String myCart = 'My Cart';
  static const String moveAllToWishlist = 'Move All to Wishlist';
  static const String moveToWishlist = 'Move to Wishlist';
  static const String movedToWishlist = 'Moved to wishlist';
  static const String allItemsMovedToWishlist = 'All items moved to wishlist';
  static const String clearCartTitle = 'Clear cart?';
  static const String clearCartContent =
      'All items in your bag will be removed.';
  static const String cartEmptyTitle = 'Your bag feels light!';
  static const String cartEmptySubtitle =
      "Add items you love and they'll show up right here,\nready for "
      'checkout.';
  static const String startShopping = 'START SHOPPING';
  static const String orderSummary = 'Order Summary';
  static const String shippingFee = 'Shipping Fee';
  static const String free = 'FREE';
  static const String totalAmount = 'Total Amount';
  static const String securePaymentsNote =
      'Secure Payments. Easy Returns. 100% Authentic.';
  static const String freeDeliveryUnlockedTitle =
      'Yay! You are getting free delivery';
  static const String freeDeliverySubtitle =
      'Add more items to unlock extra savings';
  static const String couponsOffers = 'Coupons & Offers';
  static const String viewAllOffers = 'View all available offers';
  static const String noCouponsAvailable = 'No coupons available';
  static const String checkBackLaterOffers =
      'Offers ke liye baad me check karein.';
  static const String genericAddItemError =
      'Something went wrong. Please try again.';

  static String cartItemsInBag(int count) =>
      '$count item${count == 1 ? '' : 's'} in your bag';
  static String bagTotal(int count) =>
      'Bag Total ($count item${count == 1 ? '' : 's'})';
  static String proceedToPay(String amount) => 'PROCEED TO PAY  •  $amount';

  // ── Home / Dashboard ─────────────────────────────────────────────
  static const String appBrandName = 'TheVaults';
  static const String introStep1 =
      'Welcome to TheVaults! 👋\nDiscover amazing products and services in '
      'our marketplace.';
  static const String introStep2 =
      'Featured Campaign\n\nCheck out our latest seasonal collections and '
      'offers.';
  static const String introStep3 =
      'Search & Discover\n\nFind products and brands instantly using our '
      'search bar.';
  static const String introStep4 =
      'Book Services\n\nBeauty, home repairs, cleaning and more — book in a '
      'tap.';
  static const String introStep5 =
      "Today's Deals\n\nHandpicked products with the biggest discounts "
      'right now.';
  static const String introStep6 =
      'Recommended For You\n\nPersonalized recommendations based on your '
      'preferences.';
  static const String searchHint = 'Search for products, brands and more';
  static const String allTab = 'All';
  static const String bookService = 'Book Service';
  static const String bookServiceSubtitle = 'Beauty, Home, Repairs & more';
  static const String bookNow = 'Book Now';
  static const String todaysDeals = "Today's Deals";
  static const String viewAll = 'View All';
  static const String recommendedForYou = 'Recommended For You';
  static const String productUnavailableError =
      'This product is currently unavailable.';
  static const String addedToCart = 'Added to cart.';
  static const String noProductsRightNow = 'No Products Right Now';
  static const String noProductsRightNowSubtitle =
      "We're stocking up with amazing deals.\nCheck back soon for exclusive "
      'offers!';
  static const String refresh = 'Refresh';
  static const String checkConnectionRetry =
      'Check your internet connection and try again.';
  static const String retry = 'Retry';

  static String cartBadgeCount(int count) => count > 99 ? '99+' : '$count';

  // ── All Products ─────────────────────────────────────────────────
  static const String allProducts = 'All Products';
  static const String goToCart = 'GO TO CART';
  static const String failedToLoadProducts = 'Failed to load products';
  static const String checkConnectionRetryLater =
      'Check your internet connection and try again later.';
  static const String retryUppercase = 'RETRY';
  static const String noProductsAvailable = 'No products available';
  static const String newProductsComingSoon = 'New Products coming soon.';
  static const String refreshUppercase = 'REFRESH';

  static String itemAddedToCart(String name) => '$name added to cart';
  static String productCount(int count) =>
      '$count product${count == 1 ? '' : 's'}';

  // ── Product Detail ───────────────────────────────────────────────
  static const String addedToWishlist = 'Added to wishlist';
  static const String newBadge = 'NEW';
  static const String offer1Title = '10% Instant Discount on Bank Cards';
  static const String offer1Subtitle = 'Min. spend \$50 | T&C';
  static const String offer2Title = 'Extra 5% off on Wallet';
  static const String offer2Subtitle = 'Max. discount \$10';
  static const String outOfStockTitleCase = 'Out of Stock';
  static const String buyNow = 'Buy Now';
  static const String goToCartTitleCase = 'Go to Cart';
  static const String addToCartLabel = 'Add to Cart';
  static const String somethingWentWrongLower = 'Something went wrong';
  static const String inclusiveOfTaxes = 'Inclusive of all taxes';
  static const String quantityLabel = 'Quantity';
  static const String decreaseQuantityTooltip = 'Decrease quantity';
  static const String increaseQuantityTooltip = 'Increase quantity';
  static const String offersForYou = 'Offers For You';
  static const String productDetailsTitle = 'Product Details';
  static const String colorLabel = 'Color';
  static const String availableOptions = 'Available Options';
  static const String inStock = 'In Stock';
  static const String ratingsReviews = 'Ratings & Reviews';

  static String availableStockCount(int n) => '$n available';
  static String selectedQuantitySemantics(int n) => 'Selected quantity: $n';
  static String viewAllOffersCount(int n) => 'View All Offers ($n)';
  static String ratingsCount(String count) => '$count Ratings';
  static String optionIndex(int i) => 'Option $i';

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
  static const String notAvailable = 'N/A';
  static const String showingCachedResults = 'Showing cached results — refreshing…';
  static const String pricesMayBeOutdated =
      'Prices and availability may be outdated.';

  static String retryInSeconds(int seconds) => 'Retry in $seconds sec';
  static String showingCachedResultsUpdated(String timeAgo) =>
      'Showing cached results (updated $timeAgo) — refreshing…';
  static String pricesMayBeOutdatedUpdated(String timeAgo) =>
      'Prices and availability may be outdated (last updated $timeAgo).';
  static String discountPercentLabel(int discount) => '-$discount%';
  static String resultsCount(String formattedCount) => '$formattedCount results';

  static const String filtersLabel = 'Filters';
  static const String sortLabel = 'Sort';
  static const String sortBy = 'Sort by';
  static const List<String> priceFilters = [
    'Under \$20k',
    '\$20k–\$50k',
    'Above \$50k',
  ];
  static const List<String> ratingFilters = ['4★ & up', '3★ & up'];
  static const String sortMostRelevant = 'Most Relevant';
  static const String sortPriceLowToHigh = 'Price: Low to High';
  static const String sortPriceHighToLow = 'Price: High to Low';
  static const String sortHighestRated = 'Highest Rated';
}