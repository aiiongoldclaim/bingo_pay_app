import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_colors.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/popular_products_section.dart';
import '../widgets/recent_search_section.dart';
import '../widgets/search_input_bar.dart';
import '../widgets/suggestions_list.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return BlocListener<SearchCubit, SearchState>(
      listenWhen: (_, state) => state is SearchSubmitted,
      listener: (context, state) {
        if (state is SearchSubmitted) {
          Navigator.pop(context, state.query);
        }
      },
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        body: SafeArea(
          child: Column(
            children: [
              SearchInputBar(
                onChanged: cubit.onQueryChanged,
                onSubmit: cubit.onSubmit,
                onBack: () => Navigator.pop(context),
              ),

              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    debugPrint(state.runtimeType.toString());

                    if (state is SearchSuggesting) {
                      return _SuggestingBody(state: state, cubit: cubit);
                    }

                    if (state is SearchIdle) {
                      return _IdleBody(state: state, cubit: cubit);
                    }

                    return const SizedBox.shrink();
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

/// ─────────────────────────────────────────────────────────
/// Idle State
/// ─────────────────────────────────────────────────────────

class _IdleBody extends StatelessWidget {
  const _IdleBody({required this.state, required this.cubit});

  final SearchIdle state;
  final SearchCubit cubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        RecentSearchesSection(
          recents: state.recentSearches,
          onTap: cubit.onRecentTap,
          onClear: cubit.clearRecents,
        ),

        PopularProductsSection(
          products: state.popularProducts,
          onProductTap: (product) => cubit.onSubmit(product.name),
          onFavouriteTap: cubit.toggleFavourite,
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// Suggesting State
/// ─────────────────────────────────────────────────────────

class _SuggestingBody extends StatelessWidget {
  const _SuggestingBody({required this.state, required this.cubit});

  final SearchSuggesting state;
  final SearchCubit cubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        /// Suggestions
        SuggestionsList(
          query: state.query,
          suggestions: state.suggestions,
          onTap: cubit.onSuggestionTap,
        ),

        /// Recent Searches
        if (state.recentSearches.isNotEmpty)
          RecentSearchesSection(
            recents: state.recentSearches,
            onTap: cubit.onRecentTap,
            onClear: cubit.clearRecents,
          ),

        /// Popular Products
        PopularProductsSection(
          products: state.popularProducts,
          onProductTap: (product) => cubit.onSubmit(product.name),
          onFavouriteTap: cubit.toggleFavourite,
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
