import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_sub_categories_usecase.dart';
import 'sub_categories_state.dart';

@injectable
class SubCategoriesCubit extends Cubit<SubCategoriesState> {
  final GetCategoryBreadcrumbUseCase _getBreadcrumb;
  final GetSubCategoriesUseCase _getSubCategories;

  SubCategoriesCubit(this._getBreadcrumb, this._getSubCategories)
    : super(const SubCategoriesState());

  // Number of the latest load() call, so an older response can be ignored.
  int _latestLoad = 0;

  /// Loads the breadcrumb and the children of [categoryUuid].
  Future<void> load(String categoryUuid) async {
    final thisLoad = ++_latestLoad;

    // Show loading. Keep what is already on screen, clear the old error.
    emit(
      SubCategoriesState(
        isLoading: true,
        breadcrumb: state.breadcrumb,
        subCategories: state.subCategories,
      ),
    );

    //  Start both API calls together, then wait for both.
    final breadcrumbCall = _getBreadcrumb(categoryUuid);
    final childrenCall = _getSubCategories(categoryUuid);
    final breadcrumbResult = await breadcrumbCall;
    final childrenResult = await childrenCall;

    // Screen closed, or a newer load() started: drop this response.
    if (isClosed || thisLoad != _latestLoad) return;

    // Breadcrumb is optional: if it fails, keep the old one.
    final breadcrumb = breadcrumbResult.getOrElse((_) => state.breadcrumb);

    // Children decide the result.
    childrenResult.fold(
      (failure) => emit(
        SubCategoriesState(
          breadcrumb: breadcrumb,
          subCategories: state.subCategories,
          error: failure.message,
        ),
      ),
      (children) => emit(
        SubCategoriesState(breadcrumb: breadcrumb, subCategories: children),
      ),
    );
  }
}
