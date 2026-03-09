import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_breadcrumb.dart';
import '../../shared/app_page_header.dart';
import 'data/item.dart';
import 'data/items_repository.dart';

/// Item page: create (/items/new) or edit (/items/:id). Form, Save, Cancel, Deactivate. Docs: 08_Screens_v1, 12_Object_Page_Pattern_v1, 14_Master_Data_Page_Layout_v1, 15_Form_Layout_Pattern_v1, 16_Create_Edit_Pattern_v1, 05_Validation_Rules.
class ItemPage extends StatefulWidget {
  const ItemPage({super.key, this.id});

  final String? id;

  bool get isCreateMode => id == null || id == 'new';

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final ItemsRepository _repo = itemsRepository;
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _uomController = TextEditingController();
  final _descriptionController = TextEditingController();

  Item? _item;
  bool _isActive = true;
  bool _loading = true;
  String? _codeError;
  String? _nameError;
  String? _uomError;
  String? _codeUniqueError;

  void _loadStateFromWidget() {
    if (widget.isCreateMode) {
      _item = null;
      _isActive = true;
      _codeController.clear();
      _nameController.clear();
      _uomController.clear();
      _descriptionController.clear();
      _codeError = null;
      _nameError = null;
      _uomError = null;
      _codeUniqueError = null;
      _loading = false;
    } else {
      _item = _repo.getById(widget.id!);
      if (_item != null) {
        _codeController.text = _item!.code;
        _nameController.text = _item!.name;
        _uomController.text = _item!.uom;
        _descriptionController.text = _item!.description ?? '';
        _isActive = _item!.isActive;
      }
      _codeError = null;
      _nameError = null;
      _uomError = null;
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
  void didUpdateWidget(covariant ItemPage oldWidget) {
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
    _uomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _hasItem => _item != null;

  String get _title => widget.isCreateMode ? 'New Item' : 'Item ${_item?.code ?? widget.id}';

  List<String> get _breadcrumbSegments => widget.isCreateMode
      ? ['Master Data', 'Items', 'New Item']
      : ['Master Data', 'Items', _item?.code ?? widget.id!];

  void _validate() {
    setState(() {
      _codeError = null;
      _nameError = null;
      _uomError = null;
      _codeUniqueError = null;
    });
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final uom = _uomController.text.trim();

    if (code.isEmpty) {
      setState(() => _codeError = 'Code is required');
      return;
    }
    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      return;
    }
    if (uom.isEmpty) {
      setState(() => _uomError = 'UOM is required');
      return;
    }
    final excludeId = widget.isCreateMode ? null : _item?.id;
    if (_repo.isCodeTaken(code, excludeId)) {
      setState(() => _codeUniqueError = 'Code already exists');
      return;
    }
  }

  void _save() {
    _validate();
    if (_codeError != null || _nameError != null || _uomError != null || _codeUniqueError != null) return;

    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final uom = _uomController.text.trim();
    final desc = _descriptionController.text.trim();
    final descOrNull = desc.isEmpty ? null : desc;

    if (widget.isCreateMode) {
      final created = _repo.add(Item(
        id: '',
        code: code,
        name: name,
        uom: uom,
        isActive: _isActive,
        description: descOrNull,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item saved')));
        final id = created.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.go('/${AppRoutes.pathItems}/$id');
        });
      }
    } else if (_item != null) {
      _repo.update(_item!.copyWith(
        code: code,
        name: name,
        uom: uom,
        isActive: _isActive,
        description: descOrNull,
      ));
      setState(() => _item = _repo.getById(_item!.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item saved')));
      }
    }
  }

  void _cancel() {
    context.go('/${AppRoutes.pathItems}');
  }

  void _deactivate() {
    if (_item == null) return;
    _repo.update(_item!.copyWith(isActive: false));
    setState(() => _item = _repo.getById(_item!.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deactivated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!widget.isCreateMode && _item == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: 'Item',
            breadcrumb: AppBreadcrumb(segments: ['Master Data', 'Items', widget.id!]),
          ),
          const Divider(height: 1),
          const Expanded(
            child: Center(child: Text('Item not found')),
          ),
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
            if (_hasItem && _item!.isActive) ...[
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _deactivate,
                child: const Text('Deactivate'),
              ),
            ],
          ],
        ),
        const Divider(height: 1),
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
                            Expanded(child: _MainDetailsBlock(
                              codeController: _codeController,
                              nameController: _nameController,
                              uomController: _uomController,
                              isActive: _isActive,
                              isActiveEditable: widget.isCreateMode,
                              onActiveChanged: (v) => setState(() => _isActive = v ?? true),
                              codeError: _codeError ?? _codeUniqueError,
                              nameError: _nameError,
                              uomError: _uomError,
                            )),
                            const SizedBox(width: 24),
                            Expanded(child: _SecondaryBlock(descriptionController: _descriptionController)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _MainDetailsBlock(
                              codeController: _codeController,
                              nameController: _nameController,
                              uomController: _uomController,
                              isActive: _isActive,
                              isActiveEditable: widget.isCreateMode,
                              onActiveChanged: (v) => setState(() => _isActive = v ?? true),
                              codeError: _codeError ?? _codeUniqueError,
                              nameError: _nameError,
                              uomError: _uomError,
                            ),
                            const SizedBox(height: 24),
                            _SecondaryBlock(descriptionController: _descriptionController),
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
    required this.uomController,
    required this.isActive,
    required this.isActiveEditable,
    required this.onActiveChanged,
    this.codeError,
    this.nameError,
    this.uomError,
  });

  final TextEditingController codeController;
  final TextEditingController nameController;
  final TextEditingController uomController;
  final bool isActive;
  final bool isActiveEditable;
  final ValueChanged<bool?> onActiveChanged;
  final String? codeError;
  final String? nameError;
  final String? uomError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Basic Information', style: Theme.of(context).textTheme.titleSmall),
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
        const SizedBox(height: 12),
        TextFormField(
          controller: uomController,
          decoration: InputDecoration(
            labelText: 'UOM *',
            errorText: uomError,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        isActiveEditable
            ? Row(
                children: [
                  Checkbox(value: isActive, onChanged: onActiveChanged),
                  const Text('Active'),
                ],
              )
            : Text('Active: ${isActive ? 'Yes' : 'No'}', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _SecondaryBlock extends StatelessWidget {
  const _SecondaryBlock({required this.descriptionController});

  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Additional', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
