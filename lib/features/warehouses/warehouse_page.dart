import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_color_tokens.dart';
import '../../shared/app_breadcrumb.dart';
import '../../shared/app_page_header.dart';
import 'data/warehouse.dart';
import 'data/warehouses_repository.dart';

/// Warehouse page: create (/warehouses/new) or edit (/warehouses/:id). Form, Save, Cancel, status row (Active switch). Docs: 08_Screens_v1, 12_Object_Page_Pattern_v1, 14_Master_Data_Page_Layout_v1, 15_Form_Layout_Pattern_v1, 16_Create_Edit_Pattern_v1, 05_Validation_Rules.
class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key, this.id});

  final String? id;

  bool get isCreateMode => id == null || id == 'new';

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  final WarehousesRepository _repo = warehousesRepository;
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();

  Warehouse? _warehouse;
  bool _isActive = true;
  bool _loading = true;
  String? _codeError;
  String? _nameError;
  String? _codeUniqueError;

  void _loadStateFromWidget() {
    if (widget.isCreateMode) {
      _warehouse = null;
      _isActive = true;
      _codeController.clear();
      _nameController.clear();
      _commentController.clear();
      _codeError = null;
      _nameError = null;
      _codeUniqueError = null;
      _loading = false;
    } else {
      _warehouse = _repo.getById(widget.id!);
      if (_warehouse != null) {
        _codeController.text = _warehouse!.code;
        _nameController.text = _warehouse!.name;
        _commentController.text = _warehouse!.comment ?? '';
      }
      _codeError = null;
      _nameError = null;
      _codeUniqueError = null;
      _loading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStateFromWidget();
  }

  @override
  void didUpdateWidget(covariant WarehousePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _loadStateFromWidget();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool get _hasWarehouse => _warehouse != null;

  String get _title => widget.isCreateMode
      ? 'New Warehouse'
      : 'Warehouse ${_warehouse?.code ?? widget.id}';

  List<String> get _breadcrumbSegments => widget.isCreateMode
      ? ['Master Data', 'Warehouses', 'New Warehouse']
      : ['Master Data', 'Warehouses', _warehouse?.code ?? widget.id!];

  void _validate() {
    setState(() {
      _codeError = null;
      _nameError = null;
      _codeUniqueError = null;
    });
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();

    if (code.isEmpty) {
      setState(() => _codeError = 'Code is required');
      return;
    }
    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      return;
    }
    final excludeId = widget.isCreateMode ? null : _warehouse?.id;
    if (_repo.isCodeTaken(code, excludeId)) {
      setState(() => _codeUniqueError = 'Code already exists');
      return;
    }
  }

  void _save() {
    _validate();
    if (_codeError != null || _nameError != null || _codeUniqueError != null) {
      return;
    }

    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();
    final commentOrNull = comment.isEmpty ? null : comment;

    if (widget.isCreateMode) {
      _repo.add(
        Warehouse(
          id: '',
          code: code,
          name: name,
          isActive: _isActive,
          comment: commentOrNull,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Warehouse saved')));
        context.go('/${AppRoutes.pathWarehouses}');
      }
    } else if (_warehouse != null) {
      // Save only editable fields; do not overwrite isActive (status row only).
      _repo.update(
        _warehouse!.copyWith(
          code: code,
          name: name,
          comment: commentOrNull,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Warehouse saved')),
        );
        context.go('/${AppRoutes.pathWarehouses}');
      }
    }
  }

  void _cancel() {
    context.go('/${AppRoutes.pathWarehouses}');
  }

  void _deactivate() {
    if (_warehouse == null) return;
    _repo.update(_warehouse!.copyWith(isActive: false));
    setState(() => _warehouse = _repo.getById(_warehouse!.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warehouse deactivated')),
      );
    }
  }

  void _activate() {
    if (_warehouse == null) return;
    _repo.update(_warehouse!.copyWith(isActive: true));
    setState(() => _warehouse = _repo.getById(_warehouse!.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warehouse activated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!widget.isCreateMode && _warehouse == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: 'Warehouse',
            breadcrumb: AppBreadcrumb(
              segments: ['Master Data', 'Warehouses', widget.id!],
            ),
          ),
          const Divider(height: 1),
          const Expanded(child: Center(child: Text('Warehouse not found'))),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppPageHeader(
          title: _title,
          breadcrumb: AppBreadcrumb(segments: _breadcrumbSegments),
          actions: [
            FilledButton(onPressed: _save, child: const Text('Save')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: _cancel, child: const Text('Cancel')),
          ],
        ),
        const Divider(height: 1),
        if (_hasWarehouse)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Active',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(width: 12),
                Transform.scale(
                  scale: 0.5,
                  alignment: Alignment.centerLeft,
                  child: CupertinoSwitch(
                    value: _warehouse!.isActive,
                    activeTrackColor: AppColorTokens.switchActiveDark,
                    onChanged: (bool value) {
                      if (value && !_warehouse!.isActive) {
                        _activate();
                      } else if (!value && _warehouse!.isActive) {
                        _deactivate();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        if (_hasWarehouse) const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth >= 600;
                return useTwoColumns
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _MainDetailsBlock(
                              codeController: _codeController,
                              nameController: _nameController,
                              isActive: _isActive,
                              isActiveEditable: widget.isCreateMode,
                              onActiveChanged: (v) =>
                                  setState(() => _isActive = v ?? true),
                              codeError: _codeError ?? _codeUniqueError,
                              nameError: _nameError,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _AdditionalBlock(
                              commentController: _commentController,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MainDetailsBlock(
                            codeController: _codeController,
                            nameController: _nameController,
                            isActive: _isActive,
                            isActiveEditable: widget.isCreateMode,
                            onActiveChanged: (v) =>
                                setState(() => _isActive = v ?? true),
                            codeError: _codeError ?? _codeUniqueError,
                            nameError: _nameError,
                          ),
                          const SizedBox(height: 24),
                          _AdditionalBlock(
                            commentController: _commentController,
                          ),
                        ],
                      );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MainDetailsBlock extends StatelessWidget {
  const _MainDetailsBlock({
    required this.codeController,
    required this.nameController,
    required this.isActive,
    required this.isActiveEditable,
    required this.onActiveChanged,
    this.codeError,
    this.nameError,
  });

  final TextEditingController codeController;
  final TextEditingController nameController;
  final bool isActive;
  final bool isActiveEditable;
  final ValueChanged<bool?> onActiveChanged;
  final String? codeError;
  final String? nameError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: codeController,
          decoration: InputDecoration(
            labelText: 'Code *',
            errorText: codeError,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Name *',
            errorText: nameError,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        if (isActiveEditable) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(value: isActive, onChanged: onActiveChanged),
              const Text('Active'),
            ],
          ),
        ],
      ],
    );
  }
}

class _AdditionalBlock extends StatelessWidget {
  const _AdditionalBlock({required this.commentController});

  final TextEditingController commentController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Additional',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: commentController,
          decoration: const InputDecoration(
            labelText: 'Comment',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
