import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../cubit/dashboard_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../orders/cubit/orders_cubit.dart';
import '../../../../core/di/injection.dart';
import '../widgets/split_view_navigation.dart';

class SplitViewScreen extends StatefulWidget {
  const SplitViewScreen({super.key});

  @override
  State<SplitViewScreen> createState() => _SplitViewScreenState();
}

class _SplitViewScreenState extends State<SplitViewScreen> {


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
        appBar: CustomAppBar(
          title: "Browse & Explore",
          centerTitle: false,
          showBackButton: false,
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
