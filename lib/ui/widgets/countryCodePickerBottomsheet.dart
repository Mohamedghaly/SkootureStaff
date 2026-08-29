import 'dart:async';
import 'dart:math';

import 'package:eschool_saas_staff/cubits/countryCodesCubit.dart';
import 'package:eschool_saas_staff/data/models/countryCode.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/searchContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

/// How long typing has to settle before a search request goes out. Long enough
/// that a normally-typed code is one request, short enough to feel instant.
const Duration _searchDebounceDuration = Duration(milliseconds: 400);

/// Height of the states that have no list to show, so the sheet keeps a steady
/// size while it loads instead of snapping open.
const double _placeholderStateHeight = 180.0;

/// Full height of one row (tile + its margins). Fixed so the list can be laid
/// out by extent, which also makes scrolling to a given row exact.
const double _tileExtent = 56.0;

/// Searchable list of dialling codes, returned to the caller with
/// `Get.back(result: <CountryCode>)`.
///
/// Searching is done by the API (it matches on the code), debounced so a
/// request only goes out once typing settles. The already-loaded list stays on
/// screen while the next one is fetched, so the sheet never flashes empty.
class CountryCodePickerBottomsheet extends StatefulWidget {
  final CountryCode? selectedCountryCode;

  const CountryCodePickerBottomsheet({super.key, this.selectedCountryCode});

  /// Bottom sheets are pushed onto the root navigator and therefore can't read
  /// the providers of the screen that opened them — the sheet brings its own
  /// cubit. The unfiltered list is cached in the repository, so re-opening the
  /// picker doesn't cost another network call.
  static Widget getInstance({CountryCode? selectedCountryCode}) {
    return BlocProvider(
      create: (_) => CountryCodesCubit()..getCountryCodes(),
      child: CountryCodePickerBottomsheet(
        selectedCountryCode: selectedCountryCode,
      ),
    );
  }

  @override
  State<CountryCodePickerBottomsheet> createState() =>
      _CountryCodePickerBottomsheetState();
}

class _CountryCodePickerBottomsheetState
    extends State<CountryCodePickerBottomsheet> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _searchDebounce;

  /// Last query actually sent, so edits that don't change it (trailing spaces,
  /// re-typing the same text) don't trigger another request.
  String _lastSearchQuery = "";

  /// The jump to the selected row is a one-off on the first list: search
  /// results should stay at the top where the best match is.
  bool _handledInitialScroll = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Brings the current selection into view once the first list lands, so the
  /// picker opens on what is already chosen rather than the top of the list.
  void _scrollToSelectedCountryCode(List<CountryCode> countryCodes) {
    if (_handledInitialScroll) return;
    _handledInitialScroll = true;

    final selectedCountryCode = widget.selectedCountryCode;
    if (selectedCountryCode == null) return;

    final index = countryCodes.indexOf(selectedCountryCode);
    if (index <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(
        min(index * _tileExtent, _scrollController.position.maxScrollExtent),
      );
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query == _lastSearchQuery) return;
    _lastSearchQuery = query;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted) return;
      context.read<CountryCodesCubit>().getCountryCodes(search: query);
    });
  }

  void _onCountryCodeSelected(CountryCode countryCode) {
    Get.back(result: countryCode);
  }

  Widget _buildSearchProgressIndicator({required bool isInProgress}) {
    // The height is reserved either way so nothing shifts while loading.
    return SizedBox(
      height: 2,
      child: isInProgress
          ? LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }

  Widget _buildPlaceholderState({required Widget child}) {
    return SizedBox(
      height: _placeholderStateHeight,
      child: Center(child: child),
    );
  }

  Widget _buildEmptyState() {
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return _buildPlaceholderState(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: secondaryColor.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          CustomTextContainer(
            textKey: noCountryCodesFoundKey,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.0,
              color: secondaryColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryCodesList(List<CountryCode> countryCodes) {
    if (countryCodes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      // Hugs short result sets and scrolls within the space the sheet gives it
      // once the list outgrows that.
      shrinkWrap: true,
      controller: _scrollController,
      itemExtent: _tileExtent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: countryCodes.length,
      itemBuilder: (_, index) {
        final countryCode = countryCodes[index];
        return _CountryCodeTile(
          countryCode: countryCode,
          isSelected: countryCode == widget.selectedCountryCode,
          onTap: () => _onCountryCodeSelected(countryCode),
        );
      },
    );
  }

  Widget _buildBody(CountryCodesState state) {
    if (state is CountryCodesFetchFailure) {
      return _buildPlaceholderState(
        child: ErrorContainer(
          errorMessage: state.errorMessage,
          showErrorImage: false,
          onTapRetry: () => context
              .read<CountryCodesCubit>()
              .getCountryCodes(search: _lastSearchQuery),
        ),
      );
    }

    if (state is CountryCodesFetchSuccess) {
      return _buildCountryCodesList(state.countryCodes);
    }

    // Keep the previous results visible while the next ones are fetched; only
    // the very first load has nothing to show yet.
    final previousCountryCodes = state is CountryCodesFetchInProgress
        ? state.previousCountryCodes
        : <CountryCode>[];

    return previousCountryCodes.isEmpty
        ? _buildPlaceholderState(child: const CircularProgressIndicator())
        : _buildCountryCodesList(previousCountryCodes);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CountryCodesCubit, CountryCodesState>(
      listener: (context, state) {
        if (state is CountryCodesFetchSuccess) {
          _scrollToSelectedCountryCode(state.countryCodes);
        }
      },
      builder: (context, state) {
        return CustomBottomsheet(
          titleLabelKey: Utils.getTranslatedLabel(selectCountryCodeKey),
          // The list scrolls on its own under a search field that stays put.
          scrollableChild: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              SearchContainer(
                textEditingController: _searchController,
                hintTextKey: searchCountryCodeKey,
              ),
              const SizedBox(height: 14),
              _buildSearchProgressIndicator(
                isInProgress: state is CountryCodesFetchInProgress,
              ),
              Flexible(child: _buildBody(state)),
            ],
          ),
        );
      },
    );
  }
}

/// One row of the picker: flag, dialling code, and a tick on the selected one.
class _CountryCodeTile extends StatelessWidget {
  final CountryCode countryCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _CountryCodeTile({
    required this.countryCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final flag = countryCode.flag;

    return GestureDetector(
      onTap: onTap,
      // Keeps the gaps between rows tappable instead of dead.
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        margin: EdgeInsets.symmetric(
            horizontal: appContentHorizontalPadding, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (flag.isNotEmpty) ...[
              Text(flag, style: const TextStyle(fontSize: 22.0)),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                countryCode.dialCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.secondary.withValues(alpha: 0.85),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 20, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
