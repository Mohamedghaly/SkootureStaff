import 'package:eschool_saas_staff/data/models/onlineClass/onlineClass.dart';
import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassEnums.dart';
import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassPeriod.dart';
import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassSubjectOption.dart';
import 'package:eschool_saas_staff/data/repositories/onlineClassRepository.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassDateField.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassScheduleNote.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassSubjectDropdown.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassSummaryBottomSheet.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/periodSelectionList.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/periodSelectionShimmer.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/repeatTypeSelector.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Create / Edit Online Class screen
class CreateOnlineClassScreen extends StatefulWidget {
  const CreateOnlineClassScreen._({this.classToEdit});

  final OnlineClass? classToEdit;

  static Widget getRouteInstance() {
    final args = Get.arguments;
    return CreateOnlineClassScreen._(
      classToEdit: args is OnlineClass ? args : null,
    );
  }

  @override
  State<CreateOnlineClassScreen> createState() =>
      _CreateOnlineClassScreenState();
}

class _CreateOnlineClassScreenState extends State<CreateOnlineClassScreen> {
  final OnlineClassRepository _repository = OnlineClassRepository();

  final _noteController = TextEditingController();
  final _linkController = TextEditingController();

  // Subject options (create mode).
  List<OnlineClassSubjectOption> _subjectOptions = [];
  bool _loadingSubjects = false;
  String? _subjectsError;

  // Periods for the selected subject.
  List<OnlineClassPeriod> _periods = [];
  bool _loadingPeriods = false;

  OnlineClassSubjectOption? _selectedSubject;
  OnlineClassRepeatType _repeatType = OnlineClassRepeatType.noRepeat;
  final Set<int> _selectedPeriodIds = {};
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.classToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _prefillForEdit();
    } else {
      _startDate = DateTime.now();
      _loadSubjects();
    }
  }

  void _prefillForEdit() {
    final existing = widget.classToEdit!;
    // In edit mode the subject + period are fixed: build single-item lists from
    // the row so the same widgets can render them, pre-selected.
    _selectedSubject = OnlineClassSubjectOption(
      id: existing.subjectTeacherId,
      subjectId: existing.subjectId,
      subject: existing.subject,
      subjectType: existing.subjectType,
      classSection: existing.classSection,
    );
    _subjectOptions = [_selectedSubject!];
    _periods = [
      OnlineClassPeriod(
        id: existing.id,
        day: existing.day,
        startTime: existing.startTime,
        endTime: existing.endTime,
      ),
    ];
    _selectedPeriodIds.add(existing.id);
    _repeatType = existing.repeat;
    _startDate = existing.startDate ?? DateTime.now();
    _endDate = existing.endDate;
    _noteController.text = existing.note;
    _linkController.text = existing.meetingLink;
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _loadingSubjects = true;
      _subjectsError = null;
    });
    try {
      final options = await _repository.getSubjectOptions();
      if (!mounted) return;
      setState(() {
        _subjectOptions = options;
        _loadingSubjects = false;
        // Auto-select the first Subject & Class so the form is ready to use.
        if (!_isEditMode && _selectedSubject == null && options.isNotEmpty) {
          _selectedSubject = options.first;
        }
      });
      // Load the periods for the auto-selected subject.
      if (!_isEditMode && _selectedSubject != null) {
        _loadPeriods(_selectedSubject!.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _subjectsError = e.toString();
        _loadingSubjects = false;
      });
    }
  }

  Future<void> _loadPeriods(int subjectTeacherId) async {
    setState(() {
      _loadingPeriods = true;
      _periods = [];
      _selectedPeriodIds.clear();
    });
    try {
      final periods =
          await _repository.getPeriods(subjectTeacherId: subjectTeacherId);
      if (!mounted) return;
      setState(() {
        _periods = periods;
        _loadingPeriods = false;
        // Every Class Period auto-includes all loaded periods.
        if (_isEveryClass) _selectAllPeriods();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingPeriods = false);
      Utils.showSnackBar(message: e.toString(), context: context);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // --- handlers --------------------------------------------------------------

  void _onSubjectSelected(OnlineClassSubjectOption subject) {
    setState(() => _selectedSubject = subject);
    _loadPeriods(subject.id);
  }

  /// True when "Every Class Period" is selected — every period is auto-included
  /// and the selection is locked (mirrors the web `applyRepeatToPeriods`).
  bool get _isEveryClass => _repeatType == OnlineClassRepeatType.everyClass;

  void _onRepeatChanged(OnlineClassRepeatType type) {
    setState(() {
      _repeatType = type;
      if (type.requiresEndDate && _endDate == null) {
        _endDate = (_startDate ?? DateTime.now()).add(const Duration(days: 60));
      }
      // Every Class Period auto-includes (and locks) all periods.
      if (type == OnlineClassRepeatType.everyClass) {
        _selectAllPeriods();
      }
    });
  }

  /// Keeps [_endDate] on/after [_startDate] whenever the start date moves, so a
  /// recurring class can never be submitted with an inverted range. The
  /// end-date picker's [firstDate] only guards a *new* pick, not a value that
  /// was already chosen before the start date was pushed forward.
  void _onStartDateChanged(DateTime date) {
    setState(() {
      _startDate = date;
      if (_repeatType.requiresEndDate &&
          _endDate != null &&
          _endDate!.isBefore(date)) {
        _endDate = date.add(const Duration(days: 60));
      }
    });
  }

  void _selectAllPeriods() {
    _selectedPeriodIds
      ..clear()
      ..addAll(_periods.map((p) => p.id));
  }

  void _togglePeriod(OnlineClassPeriod period) {
    setState(() {
      if (_selectedPeriodIds.contains(period.id)) {
        _selectedPeriodIds.remove(period.id);
      } else {
        _selectedPeriodIds.add(period.id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        _selectedPeriodIds.clear();
      } else {
        _selectedPeriodIds
          ..clear()
          ..addAll(_periods.map((p) => p.id));
      }
    });
  }

  bool get _allSelected =>
      _periods.isNotEmpty && _selectedPeriodIds.length == _periods.length;

  bool _validate() {
    if (_selectedSubject == null) {
      Utils.showSnackBar(message: pleaseSelectSubjectKey, context: context);
      return false;
    }
    // "Every Class Period" applies to all slots — no explicit selection needed.
    if (_repeatType.requiresPeriodSelection && _selectedPeriodIds.isEmpty) {
      Utils.showSnackBar(message: pleaseSelectPeriodKey, context: context);
      return false;
    }
    // Dates apply to the recurring types only — "No Repeat" is scheduled on
    // the period's slot by the backend, without dates.
    if (_repeatType != OnlineClassRepeatType.noRepeat) {
      if (_startDate == null) {
        Utils.showSnackBar(message: pleaseSelectDateKey, context: context);
        return false;
      }
      if (_endDate == null) {
        Utils.showSnackBar(message: pleaseSelectEndDateKey, context: context);
        return false;
      }
    }
    if (_linkController.text.trim().isEmpty) {
      Utils.showSnackBar(message: pleaseEnterMeetingLinkKey, context: context);
      return false;
    }
    return true;
  }

  /// In-memory model used to render the summary confirmation sheet.
  OnlineClass _buildDraft() {
    final period = _periods.firstWhere(
      (p) => _selectedPeriodIds.contains(p.id),
      orElse: () => _periods.isNotEmpty
          ? _periods.first
          : const OnlineClassPeriod(id: 0, day: '', startTime: '', endTime: ''),
    );
    return OnlineClass(
      id: widget.classToEdit?.id ?? 0,
      subjectTeacherId: _selectedSubject!.id,
      subjectId: _selectedSubject!.subjectId,
      classSection: _selectedSubject!.classSection,
      subject: _selectedSubject!.subject,
      subjectType: _selectedSubject!.subjectType,
      day: period.day,
      startTime: period.startTime,
      endTime: period.endTime,
      repeat: _repeatType,
      meetingLink: _linkController.text.trim(),
      note: _noteController.text.trim(),
      // "No Repeat" carries no dates — the backend schedules it period-wise.
      startDate:
          _repeatType == OnlineClassRepeatType.noRepeat ? null : _startDate,
      endDate: _repeatType.requiresEndDate ? _endDate : null,
    );
  }

  String _fmtDate(DateTime date) => DateFormat('dd-MM-yyyy').format(date);

  Future<void> _onSubmit() async {
    if (_isSubmitting || !_validate()) return;

    // Both flows confirm through the summary sheet; only the confirm button
    // label differs ("Create Class" / "Update Class").
    final confirmed = await showOnlineClassSummaryBottomSheet(
      context: context,
      draft: _buildDraft(),
      confirmLabelKey: _isEditMode ? updateClassKey : createClassKey,
    );
    if (confirmed != true) return;

    // "No Repeat" sends no dates — the backend schedules it on the period's
    // own timetable slot.
    final isNoRepeat = _repeatType == OnlineClassRepeatType.noRepeat;

    if (_isEditMode) {
      await _submit(
          () => _repository.updateOnlineClass(
                id: widget.classToEdit!.id,
                repeat: _repeatType.apiValue,
                startDate: isNoRepeat ? null : _fmtDate(_startDate!),
                endDate: isNoRepeat ? null : _fmtDate(_endDate!),
                meetingLink: _linkController.text.trim(),
                note: _noteController.text.trim(),
              ),
          successKey: onlineClassUpdatedKey);
      return;
    }

    await _submit(
        () => _repository.createOnlineClass(
              subjectTeacherId: _selectedSubject!.id,
              repeat: _repeatType.apiValue,
              startDate: isNoRepeat ? null : _fmtDate(_startDate!),
              endDate: isNoRepeat ? null : _fmtDate(_endDate!),
              meetingLink: _linkController.text.trim(),
              periodIds: _selectedPeriodIds.toList(),
              note: _noteController.text.trim(),
            ),
        successKey: onlineClassCreatedKey);
  }

  Future<void> _submit(
    Future<void> Function() action, {
    required String successKey,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      await action();
      if (!mounted) return;
      Utils.showSnackBar(message: successKey, context: context);
      Get.back(result: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Utils.showSnackBar(message: e.toString(), context: context);
    }
  }

  // --- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          CustomAppbar(
            titleKey: _isEditMode ? editClassKey : createOnlineClassKey,
          ),
          Expanded(child: _buildForm(context)),
        ],
      ),
      bottomNavigationBar: _buildSubmitButton(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    if (!_isEditMode && _loadingSubjects) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_subjectsError != null) ...[
            _helperText(_subjectsError!),
            const SizedBox(height: 12),
          ],

          // Subject
          OnlineClassSubjectDropdown(
            subjects: _subjectOptions,
            selectedSubject: _selectedSubject,
            onSelected: _isEditMode ? (_) {} : _onSubjectSelected,
          ),
          const SizedBox(height: 24),

          // Repeat
          _sectionLabel(selectRepeatKey),
          const SizedBox(height: 8),
          RepeatTypeSelector(
            selected: _repeatType,
            onChanged: _onRepeatChanged,
          ),
          const SizedBox(height: 8),
          _helperText(Utils.getTranslatedLabel(_repeatType.helperKey)),
          const SizedBox(height: 24),

          // Which period + select all
          Row(
            children: [
              Expanded(child: _sectionLabel(whichPeriodKey)),
              if (!_isEditMode && !_isEveryClass && _periods.isNotEmpty)
                _buildSelectAll(context),
            ],
          ),
          const SizedBox(height: 12),
          _buildPeriods(),
          const SizedBox(height: 8),
          _helperText(
            Utils.getTranslatedLabel(
              _isEveryClass ? allPeriodsIncludedKey : selectPeriodHelperKey,
            ),
          ),
          const SizedBox(height: 16),

          // Dates apply to the recurring types only — a "No Repeat" class is
          // scheduled on the selected period's slot by the backend, so there
          // is no date pick for it.
          if (_repeatType != OnlineClassRepeatType.noRepeat) ...[
            // Start date
            OnlineClassDateField(
              selectedDate: _startDate,
              hintKey: startDateKey,
              onDateSelected: _onStartDateChanged,
            ),

            // Weekly note under the start date
            if (_repeatType == OnlineClassRepeatType.weekly &&
                _startDate != null) ...[
              const SizedBox(height: 8),
              Text(
                OnlineClassScheduleNote.weeklyFieldNote(_startDate!),
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],

            // End date
            const SizedBox(height: 16),
            OnlineClassDateField(
              selectedDate: _endDate,
              hintKey: endDateKey,
              firstDate: _startDate,
              onDateSelected: (d) => setState(() => _endDate = d),
            ),
            const SizedBox(height: 16),
          ],

          // Description (note)
          CustomTextFieldContainer(
            hintTextKey: descriptionKey,
            textEditingController: _noteController,
            maxLines: 4,
            height: 100,
            bottomPadding: 16,
          ),

          // Meeting link
          CustomTextFieldContainer(
            hintTextKey: meetingLinkKey,
            textEditingController: _linkController,
            bottomPadding: 0,
            keyboardType: TextInputType.url,
            prefixWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.link,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriods() {
    if (_loadingPeriods) {
      return const PeriodSelectionShimmer();
    }
    if (_selectedSubject == null) {
      return _helperText(Utils.getTranslatedLabel(selectSubjectKey));
    }
    if (_periods.isEmpty) {
      return _helperText(Utils.getTranslatedLabel(noOnlineClassesFoundKey));
    }
    // Locked in edit mode (single fixed period) and for "Every Class Period"
    // (all periods auto-included), matching the web behaviour.
    final locked = _isEditMode || _isEveryClass;
    return PeriodSelectionList(
      periods: _periods,
      selectedIds: _selectedPeriodIds,
      onToggle: locked ? (_) {} : _togglePeriod,
    );
  }

  Widget _sectionLabel(String key) {
    return CustomTextContainer(
      textKey: key,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _helperText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        height: 16 / 12,
        color: Color(0xFF6D6E6F),
      ),
    );
  }

  Widget _buildSelectAll(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: _toggleSelectAll,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: _allSelected ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _allSelected
                    ? primary
                    : Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: _allSelected
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          CustomTextContainer(
            textKey: selectAllKey,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1C1D).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: double.maxFinite,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      Utils.getTranslatedLabel(
                        _isEditMode ? updateClassKey : createClassKey,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
