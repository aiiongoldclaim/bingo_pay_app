import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/account_model/account_model.dart';
import '../cubit/account_cubit.dart';
import '../cubit/account_state.dart';
import '../widgets/account_header.dart';
import '../widgets/account_menu_list.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static final List<AccountMenuItem> _menuItems = const [
    AccountMenuItem(
      title: 'My Orders',
      subtitle: 'Track, return or buy again',
      iconAsset: 'orders',
      route: AppRoutes.orders,
    ),
    AccountMenuItem(
      title: 'Wishlist',
      subtitle: '24 saved items',
      iconAsset: 'wishlist',
      route: '/wishlist',
    ),
    AccountMenuItem(
      title: 'Addresses',
      subtitle: '2 saved',
      iconAsset: 'addresses',
      route: '/addresses',
    ),
    AccountMenuItem(
      title: 'Payment methods',
      subtitle: 'UPI, cards & wallet',
      iconAsset: 'payments',
      route: '/payments',
    ),
    AccountMenuItem(
      title: 'Coupons & offers',
      subtitle: '5 available',
      iconAsset: 'coupons',
      route: '/coupons',
    ),
    AccountMenuItem(
      title: 'Help & support',
      subtitle: 'FAQs, chat with us',
      iconAsset: 'help',
      route: '/help',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        if (state is AccountLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AccountError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }

        final loaded = state as AccountLoaded;
        final cubit = context.read<AccountCubit>();

        return Scaffold(
          backgroundColor: ThemeColors.blue,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Blue gradient header ─────────────────────────────────
                AccountHeader(
                  account: loaded.account,
                  onEdit: cubit.onEditProfile,
                  onWalletTap: () => _openWallet(context),
                ),

                SizedBox(height: 2.5.h),

                // ── Menu card ────────────────────────────────────────────
                AccountMenuList(
                  items: _menuItems,
                  onTap: (item) => context.push(item.route),
                ),

                SizedBox(height: 3.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: AppButton(
                    label: 'LogOut',
                    onPressed: () {},
                    prefixIcon: Icons.logout_rounded,
                    variant: AppButtonVariant.secondary,
                  ),
                ),
                SizedBox(height: 5.5.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openWallet(BuildContext context) {
    context.push(AppRoutes.wallet);
  }
}
