import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_color_tokens.dart';
import '../../shared/app_breadcrumb.dart';
import '../../shared/app_page_header.dart';
import 'data/customer.dart';
import 'data/customers_repository.dart';

/// Customer page: create (/customers/new) or edit (/customers/:id). Form, Save, Cancel, status row (Active switch). Docs: 08_Screens_v1, 12_Object_Page_Pattern_v1, 14_Master_Data_Page_Layout_v1, 15_Form_Layout_Pattern_v1, 16_Create_Edit_Pattern_v1, 05_Validation_Rules.
class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key, this.id});

  final String? id;

  bool get isCreateMode => id == null || id == 'new';

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final CustomersRepository _repo = customersRepository;
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentController = TextEditingController();

  Customer? _customer;
  bool _isActive = true;
  bool _loading = true;
  String? _codeError;
  String? _nameError;
  String? _codeUniqueError;

  void _loadStateFromWidget() {
    if (widget.isCreateMode) {
      _customer = null;
      _isActive = true;
      _codeController.clear();
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _commentController.clear();
      _codeError = null;
      _nameError = null;
      _codeUniqueError = null;
      _loading = false;
    } else {
      _customer = _repo.getById(widget.id!);
      if (_customer != null) {
        _codeController.text = _customer!.code;
        _nameController.text = _customer!.name;
        _phoneController.text = _customer!.phone ?? '';
        _emailController.text = _customer!.email ?? '';
        _commentController.text = _customer!.comment ?? '';
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
  void didUpdateWidget(covariant CustomerPage oldWidget) {
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
    _phoneController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool get _hasCustomer => _customer != null;

  String get _title => widget.isCreateMode
      ? 'New Customer'
      : 'Customer ${_customer?.code ?? widget.id}';

  List<String> get _breadcrumbSegments => widget.isCreateMode
      ? ['Master Data', 'Customers', 'New Customer']
      : ['Master Data', 'Customers', _customer?.code ?? widget.id!];

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
    final excludeId = widget.isCreateMode ? null : _customer?.id;
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
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final comment = _commentController.text.trim();
    final phoneOrNull = phone.isEmpty ? null : phone;
    final emailOrNull = email.isEmpty ? null : email;
    final commentOrNull = comment.isEmpty ? null : comment;

    if (widget.isCreateMode) {
      _repo.add(
        Customer(
          id: '',
          code: code,
          name: name,
          isActive: _isActive,
          phone: phoneOrNull,
          email: emailOrNull,
          comment: commentOrNull,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Customer saved')));
        context.go('/${AppRoutes.pathCustomers}');
      }
    } else if (_customer != null) {
      // Save only editable fields; do not overwrite isActive (status row only).
      _repo.update(
        _customer!.copyWith(
          code: code,
          name: name,
          phone: phoneOrNull,
          email: emailOrNull,
          comment: commentOrNull,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer saved')),
        );
        context.go('/${AppRoutes.pathCustomers}');
      }
    }
  }

  void _cancel() {
    context.go('/${AppRoutes.pathCustomers}');
  }

  void _deactivate() {
    if (_customer == null) return;
    _repo.update(_customer!.copyWith(isActive: false));
    setState(() => _customer = _repo.getById(_customer!.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deactivated')),
      );
    }
  }

  void _activate() {
    if (_customer == null) return;
    _repo.update(_customer!.copyWith(isActive: true));
    setState(() => _customer = _repo.getById(_customer!.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer activated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!widget.isCreateMode && _customer == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: 'Customer',
            breadcrumb: AppBreadcrumb(
              segments: ['Master Data', 'Customers', widget.id!],
            ),
            backFallbackRoute: '/${AppRoutes.pathCustomers}',
          ),
          const Divider(height: 1),
          const Expanded(child: Center(child: Text('Customer not found'))),
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
          backFallbackRoute: '/${AppRoutes.pathCustomers}',
          actions: [
            FilledButton(onPressed: _save, child: const Text('Save')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: _cancel, child: const Text('Cancel')),
          ],
        ),
        const Divider(height: 1),
        if (_hasCustomer)
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
                    value: _customer!.isActive,
                    activeTrackColor: AppColorTokens.switchActiveDark,
                    onChanged: (bool value) {
                      if (value && !_customer!.isActive) {
                        _activate();
                      } else if (!value && _customer!.isActive) {
                        _deactivate();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        if (_hasCustomer) const Divider(height: 1),
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
                            child: _ContactAndAdditionalBlock(
                              phoneController: _phoneController,
                              emailController: _emailController,
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
                          _ContactAndAdditionalBlock(
                            phoneController: _phoneController,
                            emailController: _emailController,
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

class _ContactAndAdditionalBlock extends StatelessWidget {
  const _ContactAndAdditionalBlock({
    required this.phoneController,
    required this.emailController,
    required this.commentController,
  });

  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController commentController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Contact',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 24),
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
