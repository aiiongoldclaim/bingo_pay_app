import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';

/// A tap-to-open field (category/sub-category/GST slab pickers) that
/// participates in the step's [Form] validation like a TextFormField would.
class TapSelectField extends FormField<String> {
  TapSelectField({
    super.key,
    required String label,
    required String hint,
    String? value,
    bool required = false,
    bool enabled = true,
    required Future<String?> Function() onTap,
    required ValueChanged<String?> onChanged,
  }) : super(
         initialValue: value,
         validator: required ? (v) => (v == null || v.isEmpty) ? '$label is required' : null : null,
         builder: (state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text.rich(
                 TextSpan(
                   text: label,
                   style: const TextStyle(fontSize: 14, color: Colors.black87),
                   children: required
                       ? const [TextSpan(text: ' *', style: TextStyle(color: AppColors.error))]
                       : null,
                 ),
               ),
               const SizedBox(height: AppDimensions.sm),
               InkWell(
                 borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                 onTap: enabled
                     ? () async {
                         final result = await onTap();
                         if (result != null) {
                           state.didChange(result);
                           onChanged(result);
                         }
                       }
                     : null,
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 16),
                   decoration: BoxDecoration(
                     color: enabled ? Colors.white : const Color(0xFFF1F0EC),
                     borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                     border: state.hasError ? Border.all(color: AppColors.error) : null,
                   ),
                   child: Row(
                     children: [
                       Expanded(
                         child: Text(
                           state.value ?? hint,
                           style: TextStyle(
                             fontSize: 15,
                             color: state.value != null ? Colors.black87 : Colors.grey[500],
                           ),
                         ),
                       ),
                       Icon(Icons.chevron_right, color: Colors.grey[400]),
                     ],
                   ),
                 ),
               ),
               if (state.hasError) ...[
                 const SizedBox(height: 4),
                 Text(state.errorText!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
               ],
             ],
           );
         },
       );
}
