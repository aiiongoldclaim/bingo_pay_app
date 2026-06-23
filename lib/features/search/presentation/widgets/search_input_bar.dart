import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_search_bar.dart';

class SearchInputBar extends StatefulWidget {
  const SearchInputBar({
    super.key,
    this.initialValue = '',
    this.hint = 'Search products, brands...',
    required this.onChanged,
    required this.onSubmit,
    required this.onBack,
    this.onClear,
  });

  final String initialValue;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmit;
  final VoidCallback onBack;
  final VoidCallback? onClear;

  @override
  State<SearchInputBar> createState() => _SearchInputBarState();
}

class _SearchInputBarState extends State<SearchInputBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: ThemeColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeColors.line),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeColors.ink,
              ),
            ),
          ),

          SizedBox(width: 3.w),

          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (_, value, __) {
                return AppSearchBar(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  hintText: widget.hint,
                  onChanged: (value) {
                    debugPrint('Typing: $value');
                    widget.onChanged(value);
                  },
                  onSubmitted: widget.onSubmit,

                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: ThemeColors.inkDim,
                          ),
                          onPressed: () {
                            _controller.clear();
                            widget.onChanged('');
                            widget.onClear?.call();
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
