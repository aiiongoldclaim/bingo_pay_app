// Example: How to use the rate limit error widget in your screens
// This file demonstrates practical integration patterns

// Example 1: Using with BLoC (recommended pattern)
/*
BlocBuilder<ProductsBloc, ProductsState>(
  builder: (context, state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      success: (products) => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => ProductCard(product: products[index]),
      ),

      error: (failure) => failure.buildErrorWidget(
        onRetry: () {
          context.read<ProductsBloc>().add(const FetchProductsEvent());
        },
        fullScreen: true,
      ),
    );
  },
);
*/

// Example 2: Product details screen with embedded error
/*
class ProductDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
        builder: (context, state) {
          return state.when(
            loading: () => const Center(child: CircularProgressIndicator()),

            success: (product) => SingleChildScrollView(
              child: Column(
                children: [
                  ProductImageCarousel(product: product),
                  ProductInfo(product: product),
                  ProductPolicies(product: product),
                  AddToCartButton(product: product),
                ],
              ),
            ),

            error: (failure) => Padding(
              padding: const EdgeInsets.all(16),
              child: failure.buildErrorWidget(
                onRetry: () {
                  context.read<ProductDetailsBloc>()
                      .add(RefreshProductDetailsEvent());
                },
                fullScreen: false, // embedded, not full screen
              ),
            ),
          );
        },
      ),
    );
  }
}
*/

// Example 3: Manual error handling (if not using BLoC)
/*
class ShoppingCartScreen extends StatefulWidget {
  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  Failure? _error;

  Future<void> _refreshCart() async {
    try {
      // Fetch cart items
      setState(() => _error = null);
    } catch (e) {
      setState(() => _error = Failure(/* ... */));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _error!.buildErrorWidget(
        onRetry: _refreshCart,
        fullScreen: true,
      );
    }

    return CartItemsList(onRefresh: _refreshCart);
  }
}
*/

// Example 4: Using RateLimitErrorWidget directly
/*
class MyCustomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBloc, MyState>(
      builder: (context, state) {
        if (state.failure is RateLimitFailure) {
          return RateLimitErrorWidget(
            failure: state.failure as RateLimitFailure,
            onRetry: () {
              context.read<MyBloc>().add(RetryEvent());
            },
            fullScreen: true,
          );
        }

        if (state.failure != null) {
          return AppErrorWidget(
            failure: state.failure!,
            onRetry: () {
              context.read<MyBloc>().add(RetryEvent());
            },
          );
        }

        return MyContent();
      },
    );
  }
}
*/

class ExampleErrorHandling {
  // This class just serves as documentation
  // Copy the examples above into your actual screens
}
