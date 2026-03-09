import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../items/data/items_repository.dart';
import '../../shared/app_breadcrumb.dart';
import '../../shared/app_page_header.dart';
import '../suppliers/data/suppliers_repository.dart';
import '../warehouses/data/warehouses_repository.dart';
import 'data/purchase_order.dart';
import 'data/purchase_order_line.dart';
import 'data/purchase_orders_repository.dart';

/// Purchase Order document page. New or existing. Summary, Overview/Lines tabs, status-based actions.
/// Docs: 08_Screens_v1, 13_Document_Page_Layout_v1, 16_Create_Edit_Pattern_v1, 05_Validation_Rules.
class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key, this.id});

  final String? id;

  bool get isCreateMode => id == null || id == 'new';

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  final PurchaseOrdersRepository _repo = purchaseOrdersRepository;

  PurchaseOrder? _order;
  List<PurchaseOrderLine> _lines = [];
  final _dateController = TextEditingController();
  String? _supplierId;
  String? _warehouseId;
  final _commentController = TextEditingController();

  bool _loading = true;
  String? _validationError;

  void _load() {
    if (widget.isCreateMode) {
      _order = null;
      _lines = [];
      _dateController.clear();
      _supplierId = null;
      _warehouseId = null;
      _commentController.clear();
      _validationError = null;
      _loading = false;
      return;
    }
    _order = _repo.getById(widget.id!);
    if (_order != null) {
      _lines = _repo.getLines(_order!.id);
      _dateController.text = _order!.date;
      _supplierId = _order!.supplierId;
      _warehouseId = _order!.warehouseId;
      _commentController.text = _order!.comment ?? '';
    }
    _validationError = null;
    _loading = false;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PurchaseOrderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _load();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool get _isDraft => _order == null || _order!.isDraft;
  bool get _isConfirmed => _order != null && _order!.isConfirmed;

  String get _title => _order == null
      ? 'New Purchase Order'
      : 'Purchase Order ${_order!.number}';

  List<String> get _breadcrumbSegments => _order == null
      ? ['Purchasing', 'Purchase Orders', 'New Purchase Order']
      : ['Purchasing', 'Purchase Orders', _order!.number];

  String _statusLabel() {
    if (_order == null) return 'Draft';
    switch (_order!.status) {
      case 'draft':
        return 'Draft';
      case 'confirmed':
        return 'Confirmed';
      case 'closed':
        return 'Closed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return _order!.status;
    }
  }

  String? _validate() {
    final date = _dateController.text.trim();
    if (date.isEmpty) return 'Date is required';
    if (_supplierId == null || _supplierId!.isEmpty) return 'Supplier is required';
    if (_warehouseId == null || _warehouseId!.isEmpty) return 'Warehouse is required';
    if (_lines.isEmpty) return 'At least one line is required';
    final itemIds = <String>{};
    for (final line in _lines) {
      if (line.itemId.isEmpty) return 'Each line must have an Item';
      if (line.qty <= 0) return 'Quantity must be greater than zero';
      if (!itemIds.add(line.itemId)) return 'Duplicate items are not allowed';
    }
    final err = _repo.validateDraft(
      date: date,
      supplierId: _supplierId!,
      warehouseId: _warehouseId!,
      lines: _lines,
      excludeOrderId: _order?.id,
    );
    return err;
  }

  void _save() {
    setState(() => _validationError = null);
    final err = _validate();
    if (err != null) {
      setState(() => _validationError = err);
      return;
    }
    final date = _dateController.text.trim();
    final comment = _commentController.text.trim();
    final commentOrNull = comment.isEmpty ? null : comment;

    if (widget.isCreateMode || _order == null) {
      final created = _repo.add(PurchaseOrder(
        id: '',
        number: '',
        date: date,
        supplierId: _supplierId!,
        warehouseId: _warehouseId!,
        status: 'draft',
        comment: commentOrNull,
      ));
      for (final line in _lines) {
        _repo.addLine(PurchaseOrderLine(
          id: '',
          purchaseOrderId: created.id,
          itemId: line.itemId,
          qty: line.qty,
        ));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase order saved')),
        );
        context.go('/${AppRoutes.pathPurchaseOrders}/${created.id}');
      }
      return;
    }

    if (_order!.isDraft) {
      _repo.update(_order!.copyWith(
        date: date,
        supplierId: _supplierId,
        warehouseId: _warehouseId,
        comment: commentOrNull,
      ));
      _repo.removeLinesByOrder(_order!.id);
      for (final line in _lines) {
        _repo.addLine(PurchaseOrderLine(
          id: '',
          purchaseOrderId: _order!.id,
          itemId: line.itemId,
          qty: line.qty,
        ));
      }
      _order = _repo.getById(_order!.id);
      _lines = _repo.getLines(_order!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase order saved')),
        );
        setState(() {});
      }
    }
  }

  void _cancel() {
    context.go('/${AppRoutes.pathPurchaseOrders}');
  }

  void _confirm() {
    setState(() => _validationError = null);
    final err = _validate();
    if (err != null) {
      setState(() => _validationError = err);
      return;
    }
    if (_order == null || !_order!.isDraft) return;
    _repo.update(_order!.copyWith(
      date: _dateController.text.trim(),
      supplierId: _supplierId,
      warehouseId: _warehouseId,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    ));
    _repo.removeLinesByOrder(_order!.id);
    for (final line in _lines) {
      _repo.addLine(PurchaseOrderLine(
        id: '',
        purchaseOrderId: _order!.id,
        itemId: line.itemId,
        qty: line.qty,
      ));
    }
    _repo.confirm(_order!.id);
    _order = _repo.getById(_order!.id);
    _lines = _repo.getLines(_order!.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase order confirmed')),
      );
      setState(() {});
    }
  }

  void _cancelDocument() {
    if (_order == null) return;
    _repo.cancelDocument(_order!.id);
    _order = _repo.getById(_order!.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase order cancelled')),
      );
      setState(() {});
    }
  }

  void _addLine() {
    setState(() {
      _lines = [
        ..._lines,
        PurchaseOrderLine(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          purchaseOrderId: _order?.id ?? '',
          itemId: '',
          qty: 1,
        ),
      ];
    });
  }

  void _removeLine(int index) {
    setState(() {
      final line = _lines[index];
      _lines = _lines.where((l) => l != line).toList();
      if (line.id.startsWith('temp-')) return;
      _repo.removeLine(line.id);
    });
  }

  void _updateLine(int index, PurchaseOrderLine line) {
    setState(() {
      _lines = _lines.toList()..[index] = line;
      if (line.id.startsWith('temp-')) return;
      _repo.updateLine(line);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!widget.isCreateMode && _order == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: 'Purchase Order',
            breadcrumb: AppBreadcrumb(
              segments: ['Purchasing', 'Purchase Orders', widget.id!],
            ),
          ),
          const Divider(height: 1),
          const Expanded(
            child: Center(child: Text('Purchase order not found')),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppPageHeader(
            title: _title,
            breadcrumb: AppBreadcrumb(segments: _breadcrumbSegments),
            actions: [
              if (_validationError != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _validationError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (_isDraft) ...[
                FilledButton(onPressed: _save, child: const Text('Save')),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _cancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _confirm,
                  child: const Text('Confirm'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _cancelDocument,
                  child: const Text('Cancel document'),
                ),
              ] else if (_isConfirmed) ...[
                Tooltip(
                  message: 'Receipts module not yet implemented',
                  child: OutlinedButton(
                    onPressed: null,
                    child: const Text('Create Receipt'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _cancelDocument,
                  child: const Text('Cancel document'),
                ),
              ],
            ],
          ),
          if (_order != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          if (_order == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Draft',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: _SummaryBlock(
              order: _order,
              dateController: _dateController,
              supplierId: _supplierId,
              warehouseId: _warehouseId,
              commentController: _commentController,
              isDraft: _isDraft,
              onSupplierChanged: (v) => setState(() => _supplierId = v),
              onWarehouseChanged: (v) => setState(() => _warehouseId = v),
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.7),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Lines'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      _Row('Supplier', '—'),
                      const SizedBox(height: 8),
                      _Row('Warehouse', '—'),
                      const SizedBox(height: 8),
                      _Row('Date', '—'),
                      const SizedBox(height: 8),
                      _Row('Status', '—'),
                    ],
                  ),
                ),
                _LinesTab(
                  lines: _lines,
                  isDraft: _isDraft,
                  onAddLine: _addLine,
                  onRemoveLine: _removeLine,
                  onUpdateLine: _updateLine,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({
    required this.order,
    required this.dateController,
    required this.supplierId,
    required this.warehouseId,
    required this.commentController,
    required this.isDraft,
    required this.onSupplierChanged,
    required this.onWarehouseChanged,
  });

  final PurchaseOrder? order;
  final TextEditingController dateController;
  final String? supplierId;
  final String? warehouseId;
  final TextEditingController commentController;
  final bool isDraft;
  final void Function(String?) onSupplierChanged;
  final void Function(String?) onWarehouseChanged;

  @override
  Widget build(BuildContext context) {
    final supplier = supplierId != null
        ? suppliersRepository.getById(supplierId!)
        : null;
    final warehouse = warehouseId != null
        ? warehousesRepository.getById(warehouseId!)
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row('Number', order?.number ?? '—'),
          const SizedBox(height: 8),
          if (isDraft)
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Date *',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            )
          else
            _Row('Date', order?.date ?? ''),
          const SizedBox(height: 8),
          if (isDraft) ...[
            DropdownButtonFormField<String>(
              initialValue: supplierId,
              decoration: const InputDecoration(
                labelText: 'Supplier *',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: suppliersRepository
                  .getAll()
                  .where((s) => s.isActive)
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.code} - ${s.name}'),
                      ))
                  .toList(),
              onChanged: onSupplierChanged,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: warehouseId,
              decoration: const InputDecoration(
                labelText: 'Warehouse *',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: warehousesRepository
                  .getAll()
                  .where((w) => w.isActive)
                  .map((w) => DropdownMenuItem(
                        value: w.id,
                        child: Text('${w.code} - ${w.name}'),
                      ))
                  .toList(),
              onChanged: onWarehouseChanged,
            ),
          ] else ...[
            _Row('Supplier', supplier?.name ?? order?.supplierId ?? ''),
            const SizedBox(height: 8),
            _Row('Warehouse', warehouse?.name ?? order?.warehouseId ?? ''),
          ],
          const SizedBox(height: 8),
          _Row('Status', order != null ? _statusText(order!.status) : 'Draft'),
          const SizedBox(height: 8),
          if (isDraft)
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Comment',
                isDense: true,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            )
          else
            _Row('Comment', order?.comment ?? '—'),
        ],
      ),
    );
  }

  static String _statusText(String s) {
    switch (s) {
      case 'draft':
        return 'Draft';
      case 'confirmed':
        return 'Confirmed';
      case 'closed':
        return 'Closed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return s;
    }
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _LinesTab extends StatefulWidget {
  const _LinesTab({
    required this.lines,
    required this.isDraft,
    required this.onAddLine,
    required this.onRemoveLine,
    required this.onUpdateLine,
  });

  final List<PurchaseOrderLine> lines;
  final bool isDraft;
  final void Function() onAddLine;
  final void Function(int index) onRemoveLine;
  final void Function(int index, PurchaseOrderLine line) onUpdateLine;

  @override
  State<_LinesTab> createState() => _LinesTabState();
}

class _LinesTabState extends State<_LinesTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.isDraft)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  FilledButton.icon(
                    onPressed: widget.onAddLine,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add line'),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.resolveWith((states) {
                return Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5);
              }),
              columns: [
                const DataColumn(label: Text('Item')),
                const DataColumn(label: Text('Qty')),
                const DataColumn(label: Text('UOM')),
                if (widget.isDraft)
                  const DataColumn(label: Text('')),
              ],
              rows: widget.lines.asMap().entries.map((entry) {
                final i = entry.key;
                final line = entry.value;
                final item = line.itemId.isNotEmpty
                    ? itemsRepository.getById(line.itemId)
                    : null;
                if (widget.isDraft) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            initialValue: line.itemId.isEmpty ? null : line.itemId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            selectedItemBuilder: (context) {
                              final activeItems = itemsRepository
                                  .getAll()
                                  .where((it) => it.isActive)
                                  .toList();
                              return [
                                const Text(
                                  '— Select —',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                ...activeItems.map(
                                  (it) => Text(
                                    '${it.code} - ${it.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ];
                            },
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('— Select —', maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              ...itemsRepository
                                  .getAll()
                                  .where((it) => it.isActive)
                                  .map((it) => DropdownMenuItem<String>(
                                        value: it.id,
                                        child: Text(
                                          '${it.code} - ${it.name}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                            ],
                            onChanged: (v) => widget.onUpdateLine(
                              i,
                              line.copyWith(itemId: v ?? ''),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue: line.qty.toString(),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (s) {
                              final q = int.tryParse(s);
                              if (q != null && q != line.qty) {
                                widget.onUpdateLine(i, line.copyWith(qty: q));
                              }
                            },
                          ),
                        ),
                      ),
                      DataCell(Text(item?.uom ?? '')),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => widget.onRemoveLine(i),
                        ),
                      ),
                    ],
                  );
                }
                return DataRow(
                  cells: [
                    DataCell(Text(item?.code ?? line.itemId)),
                    DataCell(Text('${line.qty}')),
                    DataCell(Text(item?.uom ?? '')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
