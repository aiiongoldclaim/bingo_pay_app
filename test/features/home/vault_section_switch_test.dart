import 'package:bingo_pay/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:bingo_pay/features/categories/data/models/categories_response_model.dart';
import 'package:bingo_pay/features/home/data/models/product_model.dart';
import 'package:bingo_pay/features/home/data/repositories/all_products_repo.dart';
import 'package:bingo_pay/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:bingo_pay/features/home/presentation/cubit/dashboard_state.dart';
import 'package:bingo_pay/features/home/presentation/models/vault_section.dart';
import 'package:bingo_pay/features/profile/domain/enities/profile_entity.dart';
import 'package:bingo_pay/features/profile/domain/usecase/get_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRemoteDataSource extends Mock
    implements CategoryRemoteDataSource {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockProductRepository extends Mock implements ProductRepository {}

Map<String, dynamic> _productJson(String id, {String? listingLevel}) => {
  'uuid': id,
  'brand': {'name': 'Brand'},
  'title': 'Product $id',
  'media': <dynamic>[],
  'variants': <dynamic>[],
  'listingLevel': ?listingLevel,
};

const _profile = ProfileEntity(
  id: 'u1',
  uuid: 'u1',
  fullName: 'Test User',
  email: 'test@example.com',
  phone: '',
  kycStatus: KycStatus.approved,
  emailVerified: true,
  phoneVerified: true,
);

/// Sets up a [HomeCubit] whose regular (untiered) catalogue fetch returns
/// [productJsons], and whose Vaults Luxe / Ultra Luxe `?listingLevel=...`
/// queries return [luxeJsons] / [ultraLuxeJsons] respectively — mirroring
/// that these are genuinely separate backend calls, not a local filter over
/// the regular catalogue.
Future<
  ({
    HomeCubit cubit,
    MockProductRepository productRepository,
  })
>
_setUp({
  List<Map<String, dynamic>> productJsons = const [],
  List<Map<String, dynamic>> luxeJsons = const [],
  List<Map<String, dynamic>> ultraLuxeJsons = const [],
}) async {
  final categoryDataSource = MockCategoryRemoteDataSource();
  final getProfile = MockGetProfileUseCase();
  final productRepository = MockProductRepository();

  when(() => categoryDataSource.getCategories()).thenAnswer(
    (_) async => const CategoryResponseModel(success: true, data: []),
  );
  when(() => getProfile()).thenAnswer((_) async => const Right(_profile));
  when(() => productRepository.getAllProducts(page: 1, limit: 20)).thenAnswer(
    (_) async => productJsons.map(ProductModel.fromJson).toList(),
  );
  when(
    () => productRepository.getAllProducts(
      page: 1,
      limit: 20,
      listingLevel: 'LUXE',
    ),
  ).thenAnswer((_) async => luxeJsons.map(ProductModel.fromJson).toList());
  when(
    () => productRepository.getAllProducts(
      page: 1,
      limit: 20,
      listingLevel: 'ULTRA_LUXE',
    ),
  ).thenAnswer(
    (_) async => ultraLuxeJsons.map(ProductModel.fromJson).toList(),
  );

  final cubit = HomeCubit(categoryDataSource, getProfile, productRepository);
  await cubit.loadHome();
  return (cubit: cubit, productRepository: productRepository);
}

void main() {
  group('HomeCubit.selectVaultSection', () {
    test(
      'TheVaults stays the default section with content already loaded',
      () async {
        final env = await _setUp(productJsons: [_productJson('p1')]);
        addTearDown(env.cubit.close);

        expect(env.cubit.state.selectedVaultSection, VaultSection.theVaults);
        expect(env.cubit.state.vaultContentStatus, VaultContentStatus.loaded);
      },
    );

    test(
      'selecting Vaults Luxe fetches the LUXE tier from the backend '
      '(?listingLevel=LUXE), not a filter over the regular catalogue',
      () async {
        final env = await _setUp(
          productJsons: [_productJson('regular-item')],
          luxeJsons: [_productJson('luxe-item', listingLevel: 'LUXE')],
        );
        addTearDown(env.cubit.close);

        final future = env.cubit.selectVaultSection(VaultSection.vaultsLuxe);

        expect(env.cubit.state.selectedVaultSection, VaultSection.vaultsLuxe);
        expect(env.cubit.state.vaultContentStatus, VaultContentStatus.loading);

        await future;

        expect(env.cubit.state.vaultContentStatus, VaultContentStatus.loaded);
        final shown = [
          ...env.cubit.state.flashDeals,
          ...env.cubit.state.recommended,
        ].map((p) => p.uuid);
        expect(shown, ['luxe-item']);
        verify(
          () => env.productRepository.getAllProducts(
            page: 1,
            limit: 20,
            listingLevel: 'LUXE',
          ),
        ).called(1);
      },
    );

    test(
      'selecting Ultra Luxe fetches the ULTRA_LUXE tier from the backend',
      () async {
        final env = await _setUp(
          ultraLuxeJsons: [_productJson('ultra-item', listingLevel: 'ULTRA_LUXE')],
        );
        addTearDown(env.cubit.close);

        await env.cubit.selectVaultSection(VaultSection.ultraLuxe);

        final shown = [
          ...env.cubit.state.flashDeals,
          ...env.cubit.state.recommended,
        ].map((p) => p.uuid);
        expect(shown, ['ultra-item']);
        verify(
          () => env.productRepository.getAllProducts(
            page: 1,
            limit: 20,
            listingLevel: 'ULTRA_LUXE',
          ),
        ).called(1);
      },
    );

    test(
      'a tier the backend returns nothing for shows an empty result, not '
      'the regular catalogue',
      () async {
        final env = await _setUp(
          productJsons: [_productJson('regular-1'), _productJson('regular-2')],
        );
        addTearDown(env.cubit.close);

        await env.cubit.selectVaultSection(VaultSection.ultraLuxe);

        expect(env.cubit.state.flashDeals, isEmpty);
        expect(env.cubit.state.recommended, isEmpty);
      },
    );

    test(
      'if the tier fetch fails, the section is left with an empty (not '
      'stale/wrong) result rather than throwing',
      () async {
        final categoryDataSource = MockCategoryRemoteDataSource();
        final getProfile = MockGetProfileUseCase();
        final productRepository = MockProductRepository();

        when(() => categoryDataSource.getCategories()).thenAnswer(
          (_) async => const CategoryResponseModel(success: true, data: []),
        );
        when(
          () => getProfile(),
        ).thenAnswer((_) async => const Right(_profile));
        when(
          () => productRepository.getAllProducts(page: 1, limit: 20),
        ).thenAnswer((_) async => []);
        when(
          () => productRepository.getAllProducts(
            page: 1,
            limit: 20,
            listingLevel: 'ULTRA_LUXE',
          ),
        ).thenThrow(Exception('network error'));

        final cubit = HomeCubit(
          categoryDataSource,
          getProfile,
          productRepository,
        );
        addTearDown(cubit.close);
        await cubit.loadHome();

        await cubit.selectVaultSection(VaultSection.ultraLuxe);

        expect(cubit.state.vaultContentStatus, VaultContentStatus.loaded);
        expect(cubit.state.flashDeals, isEmpty);
        expect(cubit.state.recommended, isEmpty);
      },
    );

    test(
      'switching sections again mid-load abandons the stale in-flight result',
      () async {
        final env = await _setUp(
          luxeJsons: [_productJson('luxe-item', listingLevel: 'LUXE')],
          ultraLuxeJsons: [
            _productJson('ultra-item', listingLevel: 'ULTRA_LUXE'),
          ],
        );
        addTearDown(env.cubit.close);

        final firstSwitch = env.cubit.selectVaultSection(
          VaultSection.vaultsLuxe,
        );
        // Immediately change the mind before the first switch's fetch settles.
        final secondSwitch = env.cubit.selectVaultSection(
          VaultSection.ultraLuxe,
        );

        await Future.wait([firstSwitch, secondSwitch]);

        expect(
          env.cubit.state.selectedVaultSection,
          VaultSection.ultraLuxe,
          reason: 'the later tap must win over the abandoned earlier one',
        );
        expect(env.cubit.state.vaultContentStatus, VaultContentStatus.loaded);
        final shown = [
          ...env.cubit.state.flashDeals,
          ...env.cubit.state.recommended,
        ].map((p) => p.uuid);
        expect(shown, ['ultra-item']);
      },
    );

    test(
      're-tapping the already-selected, already-loaded section is a no-op',
      () async {
        final env = await _setUp(productJsons: [_productJson('p1')]);
        addTearDown(env.cubit.close);

        await env.cubit.selectVaultSection(VaultSection.theVaults);

        expect(env.cubit.state.selectedVaultSection, VaultSection.theVaults);
        expect(env.cubit.state.vaultContentStatus, VaultContentStatus.loaded);
      },
    );
  });
}
