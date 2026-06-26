// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/widgets/product_card.dart';
// import '../cubit/wishlist_cubit.dart';
// import '../cubit/wishlist_state.dart';
//
// class WishlistScreen extends StatelessWidget {
//   const WishlistScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Wishlist")),
//
//       body: BlocBuilder<WishlistCubit, WishlistState>(
//         builder: (context, state) {
//           if (state.products.isEmpty) {
//             return const Center(child: Text("No favourite products"));
//           }
//
//           return GridView.builder(
//             padding: const EdgeInsets.all(16),
//
//             itemCount: state.products.length,
//
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//
//               childAspectRatio: .63,
//
//               crossAxisSpacing: 12,
//
//               mainAxisSpacing: 12,
//             ),
//
//             itemBuilder: (_, index) {
//               final product = state.products[index];
//
//               return ProductCard(
//                 brand: product.brand,
//
//                 productName: product.name,
//
//                 imageUrl: product.image,
//
//                 price: product.price,
//
//                 rating: product.rating,
//
//                 // isFavourite: true,
//
//                 // onFavouriteTap: () {
//                 //   context.read<WishlistCubit>().toggle(product);
//                 // },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
