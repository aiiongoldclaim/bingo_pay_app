// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/theme/theme_colors.dart';
// import '../cubit/search_cubit.dart';
// import '../cubit/search_state.dart';
// import '../widgets/popular_products_section.dart';
// import '../widgets/recent_search_section.dart';
// import '../widgets/search_input_bar.dart';
// import '../widgets/suggestions_list.dart';
//
// class SearchScreen extends StatelessWidget {
//   const SearchScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => SearchCubit(),
//       child: const _SearchView(),
//     );
//   }
// }
//
// class _SearchView extends StatelessWidget {
//   const _SearchView();
//
//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.read<SearchCubit>();
//
//     return BlocListener<SearchCubit, SearchState>(
//       listenWhen: (_, state) => state is SearchSubmitted,
//       listener: (context, state) {
//         if (state is SearchSubmitted) {
//           Navigator.pop(context, state.query);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: ThemeColors.background,
//         body: SafeArea(
//           child: Column(
//             children: [
//               SearchInputBar(
//                 onChanged: cubit.onQueryChanged,
//                 onSubmit: cubit.onSubmit,
//                 onBack: () => Navigator.pop(context),
//               ),
//
//               Expanded(
//                 child: BlocBuilder<SearchCubit, SearchState>(
//                   builder: (context, state) {
//                     debugPrint(state.runtimeType.toString());
//
//                     if (state is SearchSuggesting) {
//                       return _SuggestingBody(state: state, cubit: cubit);
//                     }
//
//                     if (state is SearchIdle) {
//                       return _IdleBody(state: state, cubit: cubit);
//                     }
//
//                     return const SizedBox.shrink();
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// ─────────────────────────────────────────────────────────
// /// Idle State
// /// ─────────────────────────────────────────────────────────
//
// class _IdleBody extends StatelessWidget {
//   const _IdleBody({required this.state, required this.cubit});
//
//   final SearchIdle state;
//   final SearchCubit cubit;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//       children: [
//         RecentSearchesSection(
//           recents: state.recentSearches,
//           onTap: cubit.onRecentTap,
//           onClear: cubit.clearRecents,
//         ),
//
//         PopularProductsSection(
//           products: state.popularProducts,
//           onProductTap: (product) => cubit.onSubmit(product.name),
//           onFavouriteTap: cubit.toggleFavourite,
//         ),
//
//         const SizedBox(height: 24),
//       ],
//     );
//   }
// }
//
// /// ─────────────────────────────────────────────────────────
// /// Suggesting State
// /// ─────────────────────────────────────────────────────────
//
// class _SuggestingBody extends StatelessWidget {
//   const _SuggestingBody({required this.state, required this.cubit});
//
//   final SearchSuggesting state;
//   final SearchCubit cubit;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//       children: [
//         /// Suggestions
//         SuggestionsList(
//           query: state.query,
//           suggestions: state.suggestions,
//           onTap: cubit.onSuggestionTap,
//         ),
//
//         /// Recent Searches
//         if (state.recentSearches.isNotEmpty)
//           RecentSearchesSection(
//             recents: state.recentSearches,
//             onTap: cubit.onRecentTap,
//             onClear: cubit.clearRecents,
//           ),
//
//         /// Popular Products
//         PopularProductsSection(
//           products: state.popularProducts,
//           onProductTap: (product) => cubit.onSubmit(product.name),
//           onFavouriteTap: cubit.toggleFavourite,
//         ),
//
//         const SizedBox(height: 24),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/matrics/search_metrics.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/popular_products_section.dart';
import '../widgets/recent_search_section.dart';
import '../widgets/search_catalog.dart';
import '../widgets/search_input_bar.dart';
import '../widgets/suggestions_list.dart';
import '../widgets/trending_searches_section.dart';

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

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final GlobalKey<SearchInputBarState> _inputKey =
      GlobalKey<SearchInputBarState>();

  void _fillAndSubmit(SearchCubit cubit, String query) {
    _inputKey.currentState?.setQuery(query);
    cubit.onSubmit(query);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final m = SearchMetrics.of(context);
    final colors = context.c;

    return BlocListener<SearchCubit, SearchState>(
      listenWhen: (_, state) => state is SearchSubmitted,
      listener: (context, state) {
        if (state is SearchSubmitted) {
          context.pop(state.query);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
              child: Column(
                children: [
                  SearchInputBar(
                    key: _inputKey,
                    metrics: m,
                    onChanged: cubit.onQueryChanged,
                    onSubmit: cubit.onSubmit,
                    onBack: () => context.pop(),
                    onVoiceTap: () {},
                  ),

                  Expanded(
                    child: BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        if (state is SearchSuggesting) {
                          return _SuggestingBody(
                            metrics: m,
                            state: state,
                            cubit: cubit,
                            onQueryPicked: (q) => _fillAndSubmit(cubit, q),
                          );
                        }

                        if (state is SearchIdle) {
                          return _IdleBody(
                            metrics: m,
                            state: state,
                            cubit: cubit,
                            onQueryPicked: (q) => _fillAndSubmit(cubit, q),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IdleBody extends StatelessWidget {
  const _IdleBody({
    required this.metrics,
    required this.state,
    required this.cubit,
    required this.onQueryPicked,
  });

  final SearchMetrics metrics;
  final SearchIdle state;
  final SearchCubit cubit;
  final ValueChanged<String> onQueryPicked;

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: m.sectionGap),
      children: [
        // TrendingSearchesSection(
        //   metrics: m,
        //   items: SearchCatalog.trending,
        //   onItemTap: (item) => onQueryPicked(item.query),
        //   onViewAll: () {},
        // ),

        SizedBox(height: m.sectionGap),

        RecentSearchesSection(
          metrics: m,
          recents: state.recentSearches,
          onTap: (q) {
            cubit.onRecentTap(q);
            onQueryPicked(q);
          },
          onClear: cubit.clearRecents,
        ),

        SizedBox(height: m.sectionGap),

        SuggestedChipsSection(
          metrics: m,
          suggestions: SearchCatalog.suggested,
          onTap: onQueryPicked,
        ),

        SizedBox(height: m.sectionGap),

      ],
    );
  }
}

class _SuggestingBody extends StatelessWidget {
  const _SuggestingBody({
    required this.metrics,
    required this.state,
    required this.cubit,
    required this.onQueryPicked,
  });

  final SearchMetrics metrics;
  final SearchSuggesting state;
  final SearchCubit cubit;
  final ValueChanged<String> onQueryPicked;

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: m.sectionGap),
      children: [
        SuggestionsList(
          query: state.query,
          suggestions: state.suggestions,
          onTap: cubit.onSuggestionTap,
        ),

        if (state.recentSearches.isNotEmpty) ...[
          SizedBox(height: m.sectionGap * 0.6),
          RecentSearchesSection(
            metrics: m,
            recents: state.recentSearches,
            onTap: (q) {
              cubit.onRecentTap(q);
              onQueryPicked(q);
            },
            onClear: cubit.clearRecents,
          ),
        ],

        SizedBox(height: m.sectionGap),

        SuggestedChipsSection(
          metrics: m,
          suggestions: SearchCatalog.suggested,
          onTap: onQueryPicked,
        ),
      ],
    );
  }
}
