import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/data/repositories/all_products_repo.dart';
import '../../data/models/search_models.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({PreferencesService? preferences, ProductRepository? productRepository})
    : _preferences = preferences ?? getIt<PreferencesService>(),
      _productRepository = productRepository ?? getIt<ProductRepository>(),
      super(const SearchIdle(recentSearches: [], popularProducts: [])) {
    _load();
  }

  final PreferencesService _preferences;
  final ProductRepository _productRepository;

  /// Recent searches are real, user-performed searches persisted locally —
  /// a new customer with no search history sees an empty list, never mock
  /// data.
  static const _maxRecentSearches = 10;

  /// Suggestions are real product/brand names matched against the catalogue
  /// — never a fixed list of names that may not correspond to any actual
  /// product.
  static const _maxSuggestions = 8;
  static const _catalogFetchLimit = 100;

  List<ProductModel>? _catalog;
  Future<List<ProductModel>>? _catalogFuture;
  int _suggestionRequestId = 0;

  // ── Static mock data ──────────────────────────────────────────────────────

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
        recentSearches: _preferences.getRecentSearches(),
        popularProducts: _popularProducts,
      ),
    );
    // Warm the catalogue cache in the background so the first keystroke's
    // suggestions don't wait on a fresh network fetch.
    unawaited(_ensureCatalog());
  }

  /// Fetches the product catalogue once and caches it for matching
  /// suggestions against. Concurrent callers share the same in-flight
  /// fetch instead of triggering duplicate requests.
  Future<List<ProductModel>> _ensureCatalog() {
    final cached = _catalog;
    if (cached != null) return Future.value(cached);

    return _catalogFuture ??= _productRepository
        .getAllProducts(page: 1, limit: _catalogFetchLimit)
        .then((products) {
          _catalog = products;
          return products;
        })
        .catchError((_) {
          const empty = <ProductModel>[];
          _catalog = empty;
          return empty;
        });
  }

  List<String> _matchingSuggestions(List<ProductModel> catalog, String needle) {
    final lower = needle.toLowerCase();
    final seen = <String>{};
    final results = <String>[];

    for (final product in catalog) {
      if (product.name.isEmpty) continue;
      final matches = product.name.toLowerCase().contains(lower) ||
          product.brand.toLowerCase().contains(lower);
      if (!matches) continue;

      if (seen.add(product.name.toLowerCase())) {
        results.add(product.name);
        if (results.length >= _maxSuggestions) break;
      }
    }

    return results;
  }

  Future<void> onQueryChanged(String query) async {
    debugPrint('Search Query: $query');

    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      emit(
        SearchIdle(
          recentSearches: _preferences.getRecentSearches(),
          popularProducts: _popularProducts,
        ),
      );
      return;
    }

    final requestId = ++_suggestionRequestId;
    final catalog = await _ensureCatalog();
    // Ignore a stale response if the query changed again while awaiting.
    if (isClosed || requestId != _suggestionRequestId) return;

    final matches = _matchingSuggestions(catalog, trimmed);

    debugPrint('Suggestions: $matches');

    emit(
      SearchSuggesting(
        query: trimmed,
        suggestions: matches,
        recentSearches: _preferences.getRecentSearches(),
        popularProducts: _popularProducts,
      ),
    );
  }

  void onSuggestionTap(String suggestion) {
    _saveRecentSearch(suggestion);
    emit(SearchSubmitted(suggestion));
  }

  void onSubmit(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _saveRecentSearch(trimmed);
    emit(SearchSubmitted(trimmed));
  }

  void onRecentTap(String term) {
    _saveRecentSearch(term);
    emit(SearchSubmitted(term));
  }

  /// Records [term] as the most recent search, de-duplicating it against
  /// any earlier entry (case-insensitive) and capping the persisted list.
  void _saveRecentSearch(String term) {
    final current = _preferences.getRecentSearches();
    final updated = [
      term,
      ...current.where((t) => t.toLowerCase() != term.toLowerCase()),
    ].take(_maxRecentSearches).toList();

    unawaited(_preferences.setRecentSearches(updated));
  }

  void clearRecents() {
    unawaited(_preferences.clearRecentSearches());

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
