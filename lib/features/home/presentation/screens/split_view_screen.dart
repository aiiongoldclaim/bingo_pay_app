import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../cubit/dashboard_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../orders/cubit/orders_cubit.dart';
import '../../../../core/di/injection.dart';
import '../widgets/split_view_navigation.dart';

class SplitViewScreen extends StatelessWidget {
  const SplitViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<HomeCubit>()..loadHome(),
        ),
        BlocProvider(
          create: (_) => getIt<ServicesCubit>()..loadServices(),
        ),
        BlocProvider(
          create: (_) => getIt<CartCubit>()..loadCart(),
        ),
        BlocProvider(
          create: (_) => getIt<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider(
          create: (_) => getIt<OrdersCubit>()..loadOrders(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          leading: Padding(
            padding: EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              splashRadius: 24,
            ),
          ),
          title: Text('Browse & Explore', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          centerTitle: false,
          titleSpacing: 0,
        ),
        body: SafeArea(
          bottom: false,
          top: false,
          child: SplitViewNavigation(),
        ),
      ),
    );
  }
}
