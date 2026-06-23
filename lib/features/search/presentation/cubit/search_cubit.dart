import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/search_models.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit()
    : super(const SearchIdle(recentSearches: [], popularProducts: [])) {
    _load();
  }

  // ── Static mock data ──────────────────────────────────────────────────────

  static const _allSuggestions = [
    'wireless headphones',
    'wireless earbuds pro',
    'wireless charger 15W',
    'wireless keyboard',
    'wireless mouse',
    'wireless speaker',
  ];

  static const _recentSearches = [
    'smartwatch',
    'sneakers',
    'day cream',
    'office chair',
    'pendant',
    '5G phone',
  ];

  static final _popularProducts = [
    const SearchProductPreview(
      id: 'p1',
      brand: 'SONARA',
      name: 'Aurora Pro Wireless Headphones',
      rating: 4.8,
      reviewCount: 2100,
      price: 18990,
      originalPrice: 24990,
      discountPercent: 24,
      badge: 'BESTSELLER',
    ),
    const SearchProductPreview(
      id: 'p2',
      brand: 'NOVA',
      name: 'Helios 5G Smartphone 256GB',
      rating: 4.6,
      reviewCount: 4900,
      price: 64999,
      originalPrice: 72999,
      discountPercent: 11,
    ),
    const SearchProductPreview(
      id: 'p3',
      brand: 'STREX',
      name: 'Velocity Pro Sneakers',
      rating: 4.5,
      reviewCount: 1800,
      price: 5499,
      originalPrice: 7999,
      discountPercent: 31,
      badge: 'NEW',
    ),
  ];

  // ── Public API ────────────────────────────────────────────────────────────

  void _load() {
    emit(
      SearchIdle(
        recentSearches: _recentSearches,
        popularProducts: _popularProducts,
      ),
    );
  }

  void onQueryChanged(String query) {
    debugPrint('Search Query: $query');

    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      emit(
        SearchIdle(
          recentSearches: _recentSearches,
          popularProducts: _popularProducts,
        ),
      );
      return;
    }

    final matches = _allSuggestions
        .where((s) => s.toLowerCase().contains(trimmed.toLowerCase()))
        .toList();

    debugPrint('Suggestions: $matches');

    emit(
      SearchSuggesting(
        query: trimmed,
        suggestions: matches,
        recentSearches: _recentSearches,
        popularProducts: _popularProducts,
      ),
    );
  }

  void onSuggestionTap(String suggestion) {
    emit(SearchSubmitted(suggestion));
  }

  void onSubmit(String query) {
    if (query.trim().isEmpty) return;
    emit(SearchSubmitted(query.trim()));
  }

  void onRecentTap(String term) {
    emit(SearchSubmitted(term));
  }

  void clearRecents() {
    final current = state;
    if (current is SearchIdle) {
      emit(
        SearchIdle(
          recentSearches: const [],
          popularProducts: current.popularProducts,
        ),
      );
    }
  }

  void toggleFavourite(String productId) {
    final current = state;
    List<SearchProductPreview> updated(List<SearchProductPreview> list) => list
        .map(
          (p) =>
              p.id == productId ? p.copyWith(isFavourite: !p.isFavourite) : p,
        )
        .toList();

    if (current is SearchIdle) {
      emit(
        SearchIdle(
          recentSearches: current.recentSearches,
          popularProducts: updated(current.popularProducts),
        ),
      );
    } else if (current is SearchSuggesting) {
      emit(
        SearchSuggesting(
          query: current.query,
          suggestions: current.suggestions,
          recentSearches: current.recentSearches,
          popularProducts: updated(current.popularProducts),
        ),
      );
    }
  }
}
