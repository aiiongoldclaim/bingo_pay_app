import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/update_service.dart';

class UpdateChecker extends StatefulWidget {
  final Widget child;

  const UpdateChecker({
    required this.child,
    super.key,
  });

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  late final UpdateService _updateService;
  late final StreamSubscription _updateSubscription;

  @override
  void initState() {
    super.initState();
    debugPrint('🎯 UpdateChecker: initState called');
    _updateService = GetIt.I<UpdateService>();
    debugPrint('🎯 UpdateChecker: UpdateService injected');

    _updateSubscription = _updateService.updateStream.listen((update) {
      debugPrint('🎯 UpdateChecker: Stream event received - update=$update');
      if (update != null && mounted) {
        debugPrint('🎯 UpdateChecker: Showing bottom sheet');
        // Show snackbar first to confirm update was detected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Update Detected! Showing update prompt...'),
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            _showUpdateBottomSheet(update);
          }
        });
      }
    });

    // Set to true to test update UI without Play Store
    const testMode = true;  // ✅ TEST MODE ENABLED
    debugPrint('🎯 UpdateChecker: Calling checkForUpdates with testMode=true');
    _updateService.checkForUpdates(forceShowUpdate: testMode);
  }

  @override
  void dispose() {
    _updateSubscription.cancel();
    super.dispose();
  }

  void _showUpdateBottomSheet(UpdateAvailable update) {
    debugPrint('🎯 _showUpdateBottomSheet: Showing bottom sheet for update');

    // First show a test dialog to confirm update was detected
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ Update Feature Working!'),
        content: const Text('The update detection is working correctly.\nTap OK to see the actual update prompt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) {
      // After dialog is dismissed, show the actual bottom sheet
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isDismissible: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            debugPrint('🎯 _showUpdateBottomSheet: Building bottom sheet UI');
            return UpdateBottomSheet(
              update: update,
              onUpdate: _handleUpdate,
              onDismiss: () => _updateService.dismissUpdate(),
            );
          },
        );
      }
    });
  }

  Future<void> _handleUpdate() async {
    await _updateService.checkForUpdates();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class UpdateBottomSheet extends StatefulWidget {
  final UpdateAvailable update;
  final VoidCallback onUpdate;
  final VoidCallback onDismiss;

  const UpdateBottomSheet({
    required this.update,
    required this.onUpdate,
    required this.onDismiss,
    super.key,
  });

  @override
  State<UpdateBottomSheet> createState() => _UpdateBottomSheetState();
}

class _UpdateBottomSheetState extends State<UpdateBottomSheet> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Update Available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A new version of the app is available. Please update to the latest version for the best experience.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isUpdating
                      ? null
                      : () {
                    widget.onDismiss();
                    Navigator.pop(context);
                  },
                  child: const Text('Later'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _handleUpdate,
                  child: _isUpdating
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Update Now'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _handleUpdate() async {
    setState(() => _isUpdating = true);

    try {
      final updateService = GetIt.I<UpdateService>();
      await updateService.startFlexibleUpdate();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start update')),
        );
      }
    }
  }
}
