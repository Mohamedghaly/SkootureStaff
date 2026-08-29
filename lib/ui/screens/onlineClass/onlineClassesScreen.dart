import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/data/models/onlineClass/onlineClass.dart';
import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassEnums.dart';
import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassSubjectOption.dart';
import 'package:eschool_saas_staff/data/repositories/onlineClassRepository.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassCard.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassDetailsBottomSheet.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassFilterTabBar.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassSubjectFilterBar.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reads the teacher's online classes from `teacher/teacher_timetable`
/// (rows with a meeting link). Status, counts and the subject filter are
/// derived client-side.
class OnlineClassesScreen extends StatefulWidget {
  const OnlineClassesScreen._();

  static Widget getRouteInstance() => const OnlineClassesScreen._();

  @override
  State<OnlineClassesScreen> createState() => _OnlineClassesScreenState();
}

class _OnlineClassesScreenState extends State<OnlineClassesScreen> {
  final OnlineClassRepository _repository = OnlineClassRepository();

  OnlineClassStatus? _selectedStatus;
  OnlineClassFilterSubject? _selectedSubject;

  List<OnlineClass> _allClasses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final classes = await _repository.getOnlineClasses();
      if (!mounted) return;
      setState(() {
        _allClasses = classes;
        // Drop a selected subject that no longer exists in the data.
        if (_selectedSubject != null &&
            !_allClasses.any((c) => c.subjectId == _selectedSubject!.id)) {
          _selectedSubject = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Distinct subjects across the loaded classes — drives the filter dropdown.
  List<OnlineClassFilterSubject> get _subjectOptions {
    final map = <int, String>{};
    for (final c in _allClasses) {
      if (c.subjectId != 0 && c.subject.isNotEmpty) {
        map[c.subjectId] = c.subject;
      }
    }
    return map.entries
        .map((e) => OnlineClassFilterSubject(id: e.key, name: e.value))
        .toList();
  }

  /// Classes after the subject filter (used for the tab counts).
  List<OnlineClass> get _subjectFiltered => _selectedSubject == null
      ? _allClasses
      : _allClasses.where((c) => c.subjectId == _selectedSubject!.id).toList();

  /// Classes after both the subject and status filters (shown in the list).
  List<OnlineClass> get _visibleClasses => _selectedStatus == null
      ? _subjectFiltered
      : _subjectFiltered.where((c) => c.status == _selectedStatus).toList();

  int _countOf(OnlineClassStatus status) =>
      _subjectFiltered.where((c) => c.status == status).length;

  void _onStatusSelected(OnlineClassStatus? status) {
    setState(() => _selectedStatus = status);
  }

  void _onSubjectSelected(OnlineClassFilterSubject? subject) {
    setState(() => _selectedSubject = subject);
  }

  Future<void> _openCreate() async {
    final result = await Get.toNamed(Routes.createOnlineClassScreen);
    if (result == true) _load();
  }

  Future<void> _openEdit(OnlineClass onlineClass) async {
    final result = await Get.toNamed(
      Routes.createOnlineClassScreen,
      arguments: onlineClass,
    );
    if (result == true) _load();
  }

  Future<void> _confirmDelete(OnlineClass onlineClass) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(Utils.getTranslatedLabel(deleteOnlineClassKey)),
        content: Text(Utils.getTranslatedLabel(deleteOnlineClassConfirmKey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(Utils.getTranslatedLabel(cancelKey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              Utils.getTranslatedLabel(deleteKey),
              style: const TextStyle(color: Color(0xFFBA1A1A)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) _deleteOnlineClass(onlineClass);
  }

  Future<void> _deleteOnlineClass(OnlineClass onlineClass) async {
    try {
      await _repository.deleteOnlineClass(id: onlineClass.id);
      if (!mounted) return;
      Utils.showSnackBar(message: onlineClassDeletedKey, context: context);
      _load();
    } catch (e) {
      if (!mounted) return;
      Utils.showSnackBar(message: e.toString(), context: context);
    }
  }

  Future<void> _onCardTap(OnlineClass onlineClass) async {
    final action = await showOnlineClassDetailsBottomSheet(
      context: context,
      onlineClass: onlineClass,
    );
    if (action == null) return;
    switch (action) {
      case OnlineClassDetailsAction.edit:
        _openEdit(onlineClass);
        break;
      case OnlineClassDetailsAction.delete:
        _deleteOnlineClass(onlineClass);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppbar(titleKey: onlineClassesKey),
          OnlineClassFilterTabBar(
            selectedStatus: _selectedStatus,
            onSelected: _onStatusSelected,
            liveCount: _countOf(OnlineClassStatus.live),
            upcomingCount: _countOf(OnlineClassStatus.upcoming),
            pastCount: _countOf(OnlineClassStatus.past),
          ),
          OnlineClassSubjectFilterBar(
            subjects: _subjectOptions,
            selectedSubject: _selectedSubject,
            onSelected: _onSubjectSelected,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return ErrorContainer(
        errorMessage: _errorMessage!,
        onTapRetry: _load,
      );
    }
    final classes = _visibleClasses;
    if (classes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: noDataContainer(titleKey: noOnlineClassesFoundKey),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        itemCount: classes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final onlineClass = classes[index];
          return OnlineClassCard(
            onlineClass: onlineClass,
            onTap: () => _onCardTap(onlineClass),
            onEdit: () => _openEdit(onlineClass),
            onDelete: () => _confirmDelete(onlineClass),
          );
        },
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}
