import 'package:equatable/equatable.dart';
import '../../data/models/search_models.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

/// Initial / idle — query is empty, show recents + popular.
class SearchIdle extends SearchState {
  final List<String> recentSearches;
  final List<SearchProductPreview> popularProducts;

  const SearchIdle({
    required this.recentSearches,
    required this.popularProducts,
  });

  @override
  List<Object?> get props => [recentSearches, popularProducts];
}

/// User is typing — show autocomplete suggestions.
class SearchSuggesting extends SearchState {
  final String query;
  final List<String> suggestions;
  final List<String> recentSearches;
  final List<SearchProductPreview> popularProducts;

  const SearchSuggesting({
    required this.query,
    required this.suggestions,
    required this.recentSearches,
    required this.popularProducts,
  });

  @override
  List<Object?> get props => [
    query,
    suggestions,
    recentSearches,
    popularProducts,
  ];
}

/// User submitted — navigate away (handled in UI layer).
class SearchSubmitted extends SearchState {
  final String query;
  const SearchSubmitted(this.query);
  @override
  List<Object?> get props => [query];
}
