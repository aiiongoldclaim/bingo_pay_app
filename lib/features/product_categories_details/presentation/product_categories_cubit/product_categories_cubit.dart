import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'product_categories_state.dart';

class ProductCategoriesCubit extends Cubit<ProductCategoriesState> {
  ProductCategoriesCubit() : super(ProductCategoriesInitial());
}
