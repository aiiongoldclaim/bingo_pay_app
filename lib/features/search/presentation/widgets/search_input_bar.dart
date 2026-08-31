import 'package:flutter/material.dart';

import '../../../../core/matrics/search_metrics.dart';
import '../../../../core/theme/app_theme_colors.dart';

class SearchInputBar extends StatefulWidget {
  const SearchInputBar({
    super.key,
    required this.metrics,
    required this.onChanged,
    required this.onSubmit,
    required this.onBack,
    this.onVoiceTap,
    this.hintText = 'Search for products, brands and more',
    this.cancelLabel = 'Cancel',
  });

  final SearchMetrics metrics;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmit;
  final VoidCallback onBack;
  final VoidCallback? onVoiceTap;
  final String hintText;
  final String cancelLabel;

  @override
  State<SearchInputBar> createState() => SearchInputBarState();
}

class SearchInputBarState extends State<SearchInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  void setQuery(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = widget.metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pagePadding * 0.4,
        m.pagePadding * 0.5,
        m.pagePadding,
        m.pagePadding * 0.5,
      ),
      child: Row(
        children: [
          InkResponse(
            onTap: widget.onBack,
            radius: m.backIconSize,
            child: Padding(
              padding: EdgeInsets.all(m.pagePadding * 0.4),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: m.backIconSize * 0.8,
                color: c.textPrimary,
              ),
            ),
          ),

          Expanded(
            child: Container(
              height: m.inputHeight,
              padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 0.75),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(m.pagePadding * 0.6),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: m.inputIconSize,
                    color: c.textMuted,
                  ),
                  SizedBox(width: m.pagePadding * 0.5),

                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmit,
                      cursorColor: c.brand,
                      style: TextStyle(
                        fontSize: m.inputFontSize,
                        color: c.textPrimary,

                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          fontSize: m.inputFontSize,
                          color: c.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: m.pagePadding * 0.6),

          InkWell(
            onTap: widget.onBack,
            child: Text(
              widget.cancelLabel,
              style: TextStyle(
                fontSize: m.cancelFontSize,
                fontWeight: FontWeight.w600,
                color: c.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
