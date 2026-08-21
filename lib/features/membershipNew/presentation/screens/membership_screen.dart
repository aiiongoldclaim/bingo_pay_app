// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:bingo_pay/core/di/injection.dart';
// import 'package:bingo_pay/core/router/app_routes.dart';
// import 'package:bingo_pay/core/theme/app_theme_colors.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
//
// import '../../data/models/member_ship_model.dart';
// import '../../data/models/membership_plan_model.dart';
// import '../cubit/member_ship_cubit.dart';
// import '../cubit/member_ship_state.dart';
// import '../widgets/action_sheets.dart';
// import '../widgets/benifits_tile.dart';
// import '../widgets/details_card.dart';
// import '../widgets/feature_strip.dart';
// import '../widgets/hero_card.dart';
// import '../widgets/landing_widgets.dart';
// import '../widgets/membership_formatters.dart';
// import '../widgets/membership_metrices.dart';
// import '../widgets/membership_plan_widgets.dart';
// import '../widgets/status_view.dart';
//
// class MembershipScreen extends StatelessWidget {
//   const MembershipScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<MembershipCubit>(
//           create: (_) => getIt<MembershipCubit>()..load(),
//         ),
//         BlocProvider<MembershipPlansCubit>(
//           create: (_) => getIt<MembershipPlansCubit>()..load(),
//         ),
//       ],
//       child: const _MembershipView(),
//     );
//   }
// }
//
// class _MembershipView extends StatefulWidget {
//   const _MembershipView();
//
//   @override
//   State<_MembershipView> createState() => _MembershipViewState();
// }
//
// class _MembershipViewState extends State<_MembershipView> {
//   @override
//   void initState() {
//     super.initState();
//     // cancel / resume ka backend message snackbar me
//     context.read<MembershipCubit>().events.listen(_onEvent);
//   }
//
//   void _onEvent(MembershipEvent event) {
//     if (!mounted) return;
//     final c = context.c;
//
//     final (String text, Color bg) = switch (event) {
//       MembershipActionSuccess(:final result) => (
//       result.message.isEmpty ? 'Done' : result.message,
//       c.statusSuccess,
//       ),
//       MembershipActionFailed(:final message) => (message, c.statusWarning),
//     };
//
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(text),
//           backgroundColor: bg,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//
//     return LayoutBuilder(
//       builder: (context, _) {
//         final m = MembershipMetrics.of(context);
//
//         return Scaffold(
//           backgroundColor: c.background,
//           appBar: AppBar(
//             backgroundColor: c.background,
//             leading: IconButton(
//               onPressed: () {
//                 if (context.canPop()) context.pop();
//               },
//               icon: Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 size: m.smallIcon,
//                 color: c.textPrimary,
//               ),
//             ),
//             title: Text(
//               'Membership',
//               style: TextStyle(
//                 fontSize: m.screenTitleSize,
//                 fontWeight: FontWeight.w600,
//                 color: c.textPrimary,
//               ),
//             ),
//           ),
//           body: SafeArea(
//             top: false,
//             child: BlocBuilder<MembershipCubit, MembershipState>(
//               builder: (context, state) => switch (state) {
//                 MembershipInitial() ||
//                 MembershipLoading() => MembershipLoadingView(metrics: m),
//                 MembershipError(:final message) => MembershipErrorView(
//                   metrics: m,
//                   message: message,
//                   onRetry: () => context.read<MembershipCubit>().load(),
//                 ),
//                 MembershipLoaded() => _Body(
//                   state: state,
//                   metrics: m,
//                   onCancel: _onCancel,
//                   onResume: _onResume,
//                 ),
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // ---------------- cancel / resume ----------------
//
//   Future<void> _onCancel(
//       MembershipModel membership,
//       MembershipMetrics m,
//       ) async {
//     final sub = membership.subscription;
//     if (sub == null) return;
//
//     final ok = await MembershipActionSheets.confirmCancel(
//       context,
//       metrics: m,
//       planName: membership.plan?.name ?? 'Membership',
//       validTill: formatMembershipDate(sub.endAt),
//     );
//     if (!ok || !mounted) return;
//     context.read<MembershipCubit>().cancel(sub.uuid);
//   }
//
//   Future<void> _onResume(
//       MembershipModel membership,
//       MembershipMetrics m,
//       ) async {
//     final sub = membership.subscription;
//     if (sub == null) return;
//
//     final ok = await MembershipActionSheets.confirmResume(
//       context,
//       metrics: m,
//       planName: membership.plan?.name ?? 'Membership',
//     );
//     if (!ok || !mounted) return;
//     context.read<MembershipCubit>().resume(sub.uuid);
//   }
// }
//
//
// class _Body extends StatelessWidget {
//   const _Body({
//     required this.state,
//     required this.metrics,
//     required this.onCancel,
//     required this.onResume,
//   });
//
//   final MembershipLoaded state;
//   final MembershipMetrics metrics;
//   final Future<void> Function(MembershipModel, MembershipMetrics) onCancel;
//   final Future<void> Function(MembershipModel, MembershipMetrics) onResume;
//
//   MembershipModel get membership => state.membership;
//
//   bool get isMember => membership.subscription != null;
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//
//     return Column(
//       mainAxisSize: MainAxisSize.max,
//       children: [
//         Expanded(
//           child: RefreshIndicator(
//             color: c.brand,
//             backgroundColor: c.surface,
//             onRefresh: () async {
//               await context.read<MembershipCubit>().refresh();
//               if (!context.mounted) return;
//               await context.read<MembershipPlansCubit>().load();
//             },
//             child: SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               padding: EdgeInsets.fromLTRB(
//                 m.hPad,
//                 m.vPad,
//                 m.hPad,
//                 m.sectionGap * 0.6,
//               ),
//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: m.maxContentWidth),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: isMember
//                         ? _memberSections(context, m)
//                         : _guestSections(context, m),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         _BottomBar(
//           state: state,
//           metrics: m,
//           onCancel: () => onCancel(membership, m),
//           onResume: () => onResume(membership, m),
//         ),
//       ],
//     );
//   }
//
//   // ---------------- member view ----------------
//
//   List<Widget> _memberSections(BuildContext context, MembershipMetrics m) {
//     final sub = membership.subscription!;
//
//     final enabled = [
//       ...membership.benefits.where((e) => e.enabled),
//       ...membership.accessRights.where((e) => e.enabled),
//     ];
//     final locked = [
//       ...membership.benefits.where((e) => !e.enabled),
//       ...membership.accessRights.where((e) => !e.enabled),
//     ];
//
//     return [
//       MembershipHeroCard(
//         plan: membership.plan,
//         subscription: sub,
//         metrics: m,
//         activeBenefitCount: membership.activeBenefitCount,
//       ),
//       SizedBox(height: m.sectionGap),
//
//       if (enabled.isNotEmpty) ...[
//         MembershipSectionHeader(title: 'Your benefits', metrics: m),
//         SizedBox(height: m.rowGap),
//         MembershipBenefitsStrip(items: enabled.take(4).toList(), metrics: m),
//         SizedBox(height: m.sectionGap),
//       ],
//
//       MembershipSectionHeader(title: 'Subscription details', metrics: m),
//       SizedBox(height: m.tileGap),
//       MembershipDetailsCard(
//         plan: membership.plan,
//         subscription: sub,
//         metrics: m,
//       ),
//
//       if (locked.isNotEmpty) ...[
//         SizedBox(height: m.sectionGap),
//         MembershipSectionHeader(title: 'Not in your plan', metrics: m),
//         SizedBox(height: m.tileGap),
//         _EntitlementGrid(items: locked, metrics: m),
//       ],
//
//       SizedBox(height: m.sectionGap),
//       _PlansSection(title: 'Other plans', metrics: m, currentPlan: membership.plan),
//
//       SizedBox(height: m.sectionGap * 0.8),
//       MembershipInfoStrip(metrics: m),
//     ];
//   }
//
//   // ---------------- guest view ----------------
//
//   List<Widget> _guestSections(BuildContext context, MembershipMetrics m) => [
//     MembershipPlansHero(metrics: m),
//     SizedBox(height: m.sectionGap),
//     _PlanBenefitsPreview(metrics: m),
//     SizedBox(height: m.sectionGap),
//     _PlansSection(title: 'Choose your plan', metrics: m, currentPlan: null),
//     SizedBox(height: m.sectionGap * 0.8),
//     MembershipInfoStrip(metrics: m),
//   ];
// }
//
//
//
// class _PlanBenefitsPreview extends StatelessWidget {
//   const _PlanBenefitsPreview({required this.metrics});
//
//   final MembershipMetrics metrics;
//
//   @override
//   Widget build(BuildContext context) {
//     final m = metrics;
//
//     return BlocBuilder<MembershipPlansCubit, MembershipPlansState>(
//       builder: (context, state) {
//         if (state is! MembershipPlansLoaded || state.plans.isEmpty) {
//           return const SizedBox.shrink();
//         }
//
//         // unique features, order preserve
//         final seen = <String>{};
//         final features = <MembershipPlanFeature>[];
//         for (final plan in state.plans) {
//           for (final f in plan.features) {
//             if (f.isIncluded && seen.add(f.key)) features.add(f);
//           }
//         }
//         if (features.isEmpty) return const SizedBox.shrink();
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             MembershipSectionHeader(
//               title: 'Membership Benefits',
//               metrics: m,
//             ),
//             SizedBox(height: m.rowGap),
//             MembershipFeatureStrip(
//               features: features.take(4).toList(),
//               metrics: m,
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
//
// class _PlansSection extends StatelessWidget {
//   const _PlansSection({
//     required this.title,
//     required this.metrics,
//     required this.currentPlan,
//   });
//
//   final String title;
//   final MembershipMetrics metrics;
//   final MembershipPlan? currentPlan;
//
//   @override
//   Widget build(BuildContext context) {
//     final m = metrics;
//
//     final cubit = context.read<MembershipPlansCubit?>();
//     if (cubit == null) return const SizedBox.shrink();
//
//     return BlocBuilder<MembershipPlansCubit, MembershipPlansState>(
//       builder: (context, state) {
//         if (state is MembershipPlansLoading ||
//             state is MembershipPlansInitial) {
//           return const SizedBox.shrink();
//         }
//
//         if (state is MembershipPlansError) {
//           return _PlansErrorRow(message: state.message, metrics: m);
//         }
//
//         final loaded = state as MembershipPlansLoaded;
//
//         // member view me current plan hata do
//         final plans = currentPlan == null
//             ? loaded.plans
//             : loaded.plans.where((p) => p.uuid != currentPlan!.uuid).toList();
//
//         if (plans.isEmpty) return const SizedBox.shrink();
//
//         final cubit = context.read<MembershipPlansCubit>();
//
//         Widget card(MembershipPlanOption plan) => MembershipPlanTierCard(
//           plan: plan,
//           selected: loaded.selectedPlan?.uuid == plan.uuid,
//           metrics: m,
//           onTap: () => cubit.selectPlan(plan.uuid),
//         );
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             MembershipSectionHeader(title: title, metrics: m),
//             SizedBox(height: m.rowGap),
//             if (m.isPhone && !m.isLandscape)
//               SizedBox(
//                 height: m.iconCircle * 7.6,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.zero,
//                   itemCount: plans.length,
//                   separatorBuilder: (_, __) => SizedBox(width: m.tileGap),
//                   itemBuilder: (context, i) => SizedBox(
//                     width: MediaQuery.sizeOf(context).width * 0.64,
//                     child: card(plans[i]),
//                   ),
//                 ),
//               )
//             else
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   final columns = plans.length <= 3 ? plans.length : 3;
//                   final itemWidth =
//                       (constraints.maxWidth - m.tileGap * (columns - 1)) /
//                           columns;
//
//                   return Wrap(
//                     spacing: m.tileGap,
//                     runSpacing: m.tileGap,
//                     children: [
//                       for (final plan in plans)
//                         SizedBox(width: itemWidth, child: card(plan)),
//                     ],
//                   );
//                 },
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _PlansErrorRow extends StatelessWidget {
//   const _PlansErrorRow({required this.message, required this.metrics});
//
//   final String message;
//   final MembershipMetrics metrics;
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//
//     return Container(
//       padding: EdgeInsets.all(m.cardPad * 0.8),
//       decoration: BoxDecoration(
//         color: c.statusWarningSoft,
//         borderRadius: BorderRadius.circular(m.radiusMd),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.error_outline_rounded,
//             size: m.smallIcon,
//             color: c.statusWarning,
//           ),
//           SizedBox(width: m.cardPad * 0.5),
//           Expanded(
//             child: Text(
//               'Plans could not be loaded. $message',
//               style: TextStyle(
//                 fontSize: m.captionSize,
//                 fontWeight: FontWeight.w500,
//                 color: c.textPrimary,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () => context.read<MembershipPlansCubit>().load(),
//             style: TextButton.styleFrom(foregroundColor: c.brand),
//             child: Text(
//               'Retry',
//               style: TextStyle(
//                 fontSize: m.captionSize,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// class _BottomBar extends StatelessWidget {
//   const _BottomBar({
//     required this.state,
//     required this.metrics,
//     required this.onCancel,
//     required this.onResume,
//   });
//
//   final MembershipLoaded state;
//   final MembershipMetrics metrics;
//   final VoidCallback onCancel;
//   final VoidCallback onResume;
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//     final sub = state.membership.subscription;
//     final busy = state.isActionInProgress;
//
//     return Container(
//       padding: EdgeInsets.fromLTRB(m.hPad, m.rowGap * 0.7, m.hPad, m.rowGap),
//       decoration: BoxDecoration(
//         color: c.background,
//         border: Border(top: BorderSide(color: c.border)),
//       ),
//       child: Center(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxWidth: m.maxContentWidth),
//           child: sub == null
//               ? _joinButton(context, m)
//               : _manageRow(context, m, sub, busy),
//         ),
//       ),
//     );
//   }
//
//   // guest -> "Join <plan>"
//   Widget _joinButton(BuildContext context, MembershipMetrics m) {
//     final c = context.c;
//
//     return BlocBuilder<MembershipPlansCubit, MembershipPlansState>(
//       builder: (context, plansState) {
//         final plan = plansState is MembershipPlansLoaded
//             ? plansState.selectedPlan
//             : null;
//
//         return SizedBox(
//           width: double.infinity,
//           height: m.buttonHeight,
//           child: ElevatedButton(
//             onPressed: plan == null
//                 ? null
//                 : () => context.push(AppRoutes.membershipCheckout, extra: plan),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: c.brand,
//               foregroundColor: ThemeColors.white,
//               disabledBackgroundColor: c.brand.withValues(alpha: 0.45),
//               elevation: 0,
//               minimumSize: Size.zero,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(m.radiusMd),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.diamond_outlined,
//                   size: m.smallIcon,
//                   color: ThemeColors.gold1,
//                 ),
//                 SizedBox(width: m.cardPad * 0.4),
//                 Flexible(
//                   child: Text(
//                     plan == null ? 'Join membership' : 'Join ${plan.name}',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: m.sectionTitleSize,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // member -> cancel / resume + upgrade
//   Widget _manageRow(
//       BuildContext context,
//       MembershipMetrics m,
//       MembershipSubscription sub,
//       bool busy,
//       ) {
//     final c = context.c;
//     final active = sub.isActive;
//
//     Widget spinner(Color color) => SizedBox(
//       width: m.smallIcon,
//       height: m.smallIcon,
//       child: CircularProgressIndicator(
//         strokeWidth: 2,
//         valueColor: AlwaysStoppedAnimation<Color>(color),
//       ),
//     );
//
//     final primary = active
//         ? OutlinedButton.icon(
//       onPressed: busy ? null : onCancel,
//       style: OutlinedButton.styleFrom(
//         foregroundColor: c.statusWarning,
//         side: BorderSide(color: c.statusWarning),
//         minimumSize: Size.zero,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(m.radiusMd),
//         ),
//       ),
//       icon: busy
//           ? spinner(c.statusWarning)
//           : Icon(Icons.pause_circle_outline_rounded, size: m.smallIcon),
//       label: Text(
//         'Cancel',
//         style: TextStyle(
//           fontSize: m.labelSize,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     )
//         : ElevatedButton.icon(
//       onPressed: busy ? null : onResume,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: c.brand,
//         foregroundColor: ThemeColors.white,
//         disabledBackgroundColor: c.brand.withValues(alpha: 0.45),
//         elevation: 0,
//         minimumSize: Size.zero,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(m.radiusMd),
//         ),
//       ),
//       icon: busy
//           ? spinner(ThemeColors.white)
//           : Icon(Icons.play_circle_outline_rounded, size: m.smallIcon),
//       label: Text(
//         'Resume',
//         style: TextStyle(
//           fontSize: m.labelSize,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     );
//
//     return Row(
//       children: [
//         Expanded(child: SizedBox(height: m.buttonHeight, child: primary)),
//         SizedBox(width: m.cardPad * 0.6),
//         Expanded(
//           child: SizedBox(
//             height: m.buttonHeight,
//             child: BlocBuilder<MembershipPlansCubit, MembershipPlansState>(
//               builder: (context, plansState) {
//                 final plan = plansState is MembershipPlansLoaded
//                     ? plansState.selectedPlan
//                     : null;
//                 final canUpgrade =
//                     plan != null && plan.uuid != state.membership.plan?.uuid;
//
//                 return TextButton.icon(
//                   onPressed: busy || !canUpgrade
//                       ? null
//                       : () => context.push(
//                     AppRoutes.membershipCheckout,
//                     extra: plan,
//                   ),
//                   style: TextButton.styleFrom(
//                     foregroundColor: c.brand,
//                     backgroundColor: c.brandSoft.withValues(alpha: 0.4),
//                     disabledForegroundColor: c.textMuted,
//                     minimumSize: Size.zero,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(m.radiusMd),
//                     ),
//                   ),
//                   icon: Icon(Icons.upgrade_rounded, size: m.smallIcon),
//                   label: Text(
//                     'Change plan',
//                     style: TextStyle(
//                       fontSize: m.labelSize,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
// class _EntitlementGrid extends StatelessWidget {
//   const _EntitlementGrid({required this.items, required this.metrics});
//
//   final List<MembershipEntitlement> items;
//   final MembershipMetrics metrics;
//
//   @override
//   Widget build(BuildContext context) {
//     final m = metrics;
//
//     if (m.benefitColumns <= 1) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           for (var i = 0; i < items.length; i++) ...[
//             MembershipBenefitTile(entitlement: items[i], metrics: m),
//             if (i != items.length - 1) SizedBox(height: m.tileGap),
//           ],
//         ],
//       );
//     }
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final columns = m.benefitColumns;
//         final itemWidth =
//             (constraints.maxWidth - m.tileGap * (columns - 1)) / columns;
//
//         return Wrap(
//           spacing: m.tileGap,
//           runSpacing: m.tileGap,
//           children: [
//             for (final item in items)
//               SizedBox(
//                 width: itemWidth,
//                 child: MembershipBenefitTile(entitlement: item, metrics: m),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
