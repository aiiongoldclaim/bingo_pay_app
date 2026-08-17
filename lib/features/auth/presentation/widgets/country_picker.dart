import 'package:flutter/material.dart';

import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class Country {
  final String name;
  final String code;
  final String dialCode;
  final int minLength;
  final int maxLength;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.minLength,
    required this.maxLength,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      code: json['code'] as String,
      dialCode: json['dialCode'] as String,
      minLength: json['minLength'] as int,
      maxLength: json['maxLength'] as int,
    );
  }
}

class CountryPickerBottomSheet extends StatefulWidget {
  final List<Country> countries;
  final Country? initialSelectedCountry;
  final ValueChanged<Country> onCountrySelected;

  const CountryPickerBottomSheet({
    super.key,
    required this.countries,
    required this.initialSelectedCountry,
    required this.onCountrySelected,
  });

  static String getFlagEmoji(String countryCode) {
    if (countryCode.length != 2) return '';
    final int firstChar = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondChar = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  @override
  State<CountryPickerBottomSheet> createState() =>
      _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  late List<Country> _filteredCountries;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCountries = widget.countries;
    _searchController.addListener(_filterCountries);
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = widget.countries.where((country) {
        return country.name.toLowerCase().contains(query) ||
            country.dialCode.contains(query) ||
            country.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final m = _PickerMetrics.get();

    // ── explicit colors, textTheme pe bharosa nahi ──
    final sheetBg = theme.scaffoldBackgroundColor;
    final titleColor = isDark ? ThemeColors.white : ThemeColors.ink;
    final bodyColor = isDark ? ThemeColors.white : ThemeColors.ink;
    final mutedColor = isDark ? ThemeColors.inkDim : ThemeColors.inkMid;
    final border = isDark
        ? ThemeColors.white.withValues(alpha: 0.12)
        : ThemeColors.line;
    final fieldFill = isDark
        ? ThemeColors.white.withValues(alpha: 0.04)
        : ThemeColors.surface;
    final accent = theme.colorScheme.primary;

    return Container(
      height: mq.size.height * (m.isTablet ? 0.80 : 0.75),
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          /// handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: mutedColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: m.hPad),
            child: Text(
              'Select Country',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: m.titleFont,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// search
          Padding(
            padding: EdgeInsets.symmetric(horizontal: m.hPad),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: m.bodyFont,
                color: bodyColor,
              ),
              cursorColor: accent,
              decoration: InputDecoration(
                hintText: 'Search country, code, or dial code',
                hintStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: m.bodyFont,
                  color: isDark ? ThemeColors.inkDim : ThemeColors.textGrey,
                ),
                filled: true,
                fillColor: fieldFill,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: m.iconSize,
                  color: isDark ? ThemeColors.gold1 : ThemeColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: m.iconSize,
                          color: isDark
                              ? ThemeColors.gold1
                              : ThemeColors.textSecondary,
                        ),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: m.isTablet ? 16 : 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accent, width: 1.6),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// list
          Expanded(
            child: _filteredCountries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No countries found matching your search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: m.bodyFont,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: m.hPad * 0.6,
                      vertical: 4,
                    ),
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final isSelected =
                          widget.initialSelectedCountry?.code == country.code;

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: m.isTablet ? 6 : 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: isSelected
                              ? accent.withValues(alpha: isDark ? 0.16 : 0.08)
                              : null,
                          leading: Text(
                            CountryPickerBottomSheet.getFlagEmoji(country.code),
                            style: TextStyle(fontSize: m.flagSize),
                          ),
                          title: Text(
                            country.name,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: m.bodyFont,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: bodyColor,
                            ),
                          ),
                          trailing: Text(
                            country.dialCode,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: m.bodyFont - 1,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.purple,
                            ),
                          ),
                          onTap: () {
                            widget.onCountrySelected(country);
                            Navigator.pop(context);
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

class _PickerMetrics {
  const _PickerMetrics({
    required this.isTablet,
    required this.titleFont,
    required this.bodyFont,
    required this.iconSize,
    required this.flagSize,
    required this.hPad,
  });

  final bool isTablet;
  final double titleFont;
  final double bodyFont;
  final double iconSize;
  final double flagSize;
  final double hPad;

  factory _PickerMetrics.get() {
    if (ResponsiveUtils.isTabletLandscape) {
      return const _PickerMetrics(
        isTablet: true,
        titleFont: 20,
        bodyFont: 15,
        iconSize: 21,
        flagSize: 26,
        hPad: 28,
      );
    }

    if (ResponsiveUtils.isTabletPortrait) {
      return const _PickerMetrics(
        isTablet: true,
        titleFont: 22,
        bodyFont: 16,
        iconSize: 23,
        flagSize: 28,
        hPad: 32,
      );
    }

    return const _PickerMetrics(
      isTablet: false,
      titleFont: 19,
      bodyFont: 15,
      iconSize: 21,
      flagSize: 26,
      hPad: 20,
    );
  }
}
