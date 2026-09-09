import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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



  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Auctions',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),

      body: BlocBuilder<AuctionCubit, AuctionState>(
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
    );
  }
}



