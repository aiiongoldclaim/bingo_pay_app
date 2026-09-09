// ─────────────────────────────────────────────────────────────────────────
// ORIGINAL — the Auctions screen with a plain CustomAppBar ("Auctions"
// title only, no subtitle/heart/share), kept for reference. The redesigned
// screen replaces the app bar with a custom header (back, title + tagline,
// wishlist heart, share) matching the new mockup — see the active
// AuctionScreen implementation below.
// ─────────────────────────────────────────────────────────────────────────
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'package:bingo_pay/core/theme/app_theme_colors.dart';
// import 'package:bingo_pay/core/widgets/custom_app_bar.dart';
// import 'package:bingo_pay/features/auctions/presentation/cubit/auction_cubit.dart';
// import 'package:bingo_pay/features/auctions/presentation/cubit/auction_state.dart';
//
// import '../widgets/auction_content.dart';
// import '../widgets/auction_error_view.dart';
// import 'auction_detail_screen.dart';
//
// class AuctionScreen extends StatefulWidget {
//   const AuctionScreen({super.key});
//
//   @override
//   State<AuctionScreen> createState() => _AuctionScreenState();
// }
//
// class _AuctionScreenState extends State<AuctionScreen> {
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//
//       context.read<AuctionCubit>().getAuctions();
//     });
//   }
//
//
//   Future<void> _openAuctionDetails(String auctionId) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AuctionDetailScreen(
//           auctionId: auctionId,
//         ),
//       ),
//     );
//
//     if (!mounted) return;
//
//     await context.read<AuctionCubit>().getAuctions();
//   }
//
//
//   Future<void> _retry() async {
//     if (!mounted) return;
//
//     await context.read<AuctionCubit>().getAuctions();
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return Scaffold(
//       backgroundColor: colors.background,
//
//       appBar: const CustomAppBar(
//         title: 'Auctions',
//         centerTitle: true,
//       ),
//
//       body: BlocBuilder<AuctionCubit, AuctionState>(
//         builder: (context, state) {
//           if (state is AuctionLoading ||
//               state is AuctionInitial ||
//               state is AuctionDetailLoading ||
//               state is AuctionDetailLoaded ||
//               state is AuctionDetailError) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//
//           if (state is AuctionError) {
//             return AuctionErrorView(
//               message: state.message,
//               onRetry: _retry,
//             );
//           }
//
//           if (state is AuctionLoaded) {
//             return RefreshIndicator(
//               onRefresh: () {
//                 return context.read<AuctionCubit>().getAuctions();
//               },
//               child: AuctionContent(
//                 liveAuctions: state.liveAuctions,
//                 endingSoonAuctions: state.endingSoonAuctions,
//                 upcomingAuctions: state.upcomingAuctions,
//                 onAuctionTap: _openAuctionDetails,
//               ),
//             );
//           }
//
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/theme/app_text_styles.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_cubit.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_state.dart';

import '../widgets/auction_content.dart';
import '../widgets/auction_error_view.dart';
import 'auction_detail_screen.dart';


class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  bool _screenSaved = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AuctionCubit>().getAuctions();
    });
  }

  Future<void> _openAuctionDetails(String auctionId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuctionDetailScreen(
          auctionId: auctionId,
        ),
      ),
    );

    if (!mounted) return;

    await context.read<AuctionCubit>().getAuctions();
  }

  Future<void> _retry() async {
    if (!mounted) return;

    await context.read<AuctionCubit>().getAuctions();
  }

  void _share() {
    Share.share(
      'Check out the live auctions on Vaults! Bid. Win. Own something special.',
      subject: 'Vaults Auctions',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.auctionListBackground),
        child: SafeArea(
          child: Column(
            children: [
              _AuctionsHeader(
                saved: _screenSaved,
                onToggleSaved: () {
                  setState(() => _screenSaved = !_screenSaved);
                },
                onShare: _share,
              ),
              Expanded(
                child: BlocBuilder<AuctionCubit, AuctionState>(
                  builder: (context, state) {
                    if (state is AuctionLoading ||
                        state is AuctionInitial ||
                        state is AuctionDetailLoading ||
                        state is AuctionDetailLoaded ||
                        state is AuctionDetailError) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is AuctionError) {
                      return AuctionErrorView(
                        message: state.message,
                        onRetry: _retry,
                      );
                    }

                    if (state is AuctionLoaded) {
                      return RefreshIndicator(
                        color: colors.brand,
                        backgroundColor: colors.surface,
                        onRefresh: () {
                          return context.read<AuctionCubit>().getAuctions();
                        },
                        child: AuctionContent(
                          liveAuctions: state.liveAuctions,
                          endingSoonAuctions: state.endingSoonAuctions,
                          upcomingAuctions: state.upcomingAuctions,
                          onAuctionTap: _openAuctionDetails,
                        ),
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuctionsHeader extends StatelessWidget {
  const _AuctionsHeader({
    required this.saved,
    required this.onToggleSaved,
    required this.onShare,
  });

  final bool saved;
  final VoidCallback onToggleSaved;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(2.56.w, 1.42.h, 2.56.w, 0.71.h),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Auctions',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontDisplay,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 0.24.h),
                Text(
                  'Bid. Win. Own Something Special.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            iconColor: saved ? colors.error : null,
            onTap: onToggleSaved,
          ),
          SizedBox(width: 1.79.w),
          _HeaderIconButton(
            icon: Icons.ios_share_rounded,
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 10.26.w,
        height: 10.26.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 17.sp,
          color: iconColor ?? colors.textPrimary,
        ),
      ),
    );
  }
}

