import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../items/data/items_repository.dart';
import '../receipts/data/receipts_repository.dart';
import '../../shared/app_breadcrumb.dart';
import '../../shared/app_page_header.dart';
import '../suppliers/data/suppliers_repository.dart';
import '../warehouses/data/warehouses_repository.dart';
import 'data/purchase_order.dart';
import 'data/purchase_order_line.dart';
import 'data/purchase_orders_repository.dart';

/// Storage format yyyy-MM-dd.
String _formatPoDate(DateTime d) {
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

DateTime? _parsePoDate(String s) {
  final t = s.trim();
  if (t.length != 10) return null;
  final d = DateTime.tryParse(t);
  if (d == null) return null;
  if (d.year < 1900 || d.year > 2100) return null;
  return d;
}

/// Display format dd.MM.yyyy.
String _formatDisplay(DateTime d) {
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

/// Parse dd.MM.yyyy input.
DateTime? _parseDisplay(String s) {
  final t = s.trim();
  final parts = t.split('.');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  if (year < 1900 || year > 2100 || month < 1 || month > 12 || day < 1) return null;
  final d = DateTime(year, month, day);
  if (d.day != day || d.month != month || d.year != year) return null;
  return d;
}

bool _isValidPoDate(String s) => _parsePoDate(s) != null;

/// Allow either 0–8 raw digits or dotted dd.MM.yyyy shape. No blocking after 2 digits.
bool _matchesDateShape(String s) {
  if (s.isEmpty) return true;
  if (s.length > 10) return false;
  if (RegExp(r'^\d{0,8}$').hasMatch(s)) return true;
  return RegExp(r'^\d{0,2}(\.\d{0,2}(\.\d{0,4})?)?$').hasMatch(s);
}

/// Normalize 8 digits to dd.MM.yyyy (e.g. 12032026 -> 12.03.2026).
String _format8DigitsToDate(String eightDigits) {
  if (eightDigits.length != 8) return eightDigits;
  return '${eightDigits.substring(0, 2)}.${eightDigits.substring(2, 4)}.${eightDigits.substring(4)}';
}

/// Accept edits that are either raw digits (0–8) or dotted date shape. No text/cursor change.
class _DateShapeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_matchesDateShape(newValue.text)) return newValue;
    return oldValue;
  }
}

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
  final _dateFocusNode = FocusNode();
  String? _supplierId;
  String? _warehouseId;
  final _commentController = TextEditingController();

  bool _loading = true;
  String? _validationError;

  void _load() {
    if (widget.isCreateMode) {
      _order = null;
      _lines = [];
      _dateController.text = _formatDisplay(DateTime.now());
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
      final stored = _parsePoDate(_order!.date);
      _dateController.text = _formatDisplay(stored ?? DateTime.now());
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
    _dateFocusNode.addListener(_onDateFocusChange);
  }

  void _onDateFocusChange() {
    if (_dateFocusNode.hasFocus) return;
    final t = _dateController.text.trim();
    if (t.length == 8 && RegExp(r'^\d{8}$').hasMatch(t) && mounted) {
      setState(() => _dateController.text = _format8DigitsToDate(t));
    }
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
    _dateFocusNode.removeListener(_onDateFocusChange);
    _dateFocusNode.dispose();
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

  String _getNormalizedDateInput() {
    final t = _dateController.text.trim();
    if (t.length == 8 && RegExp(r'^\d{8}$').hasMatch(t)) {
      return _format8DigitsToDate(t);
    }
    return t;
  }

  String? _validate() {
    final dateInput = _getNormalizedDateInput();
    if (dateInput.isEmpty) return 'Date is required';
    final parsed = _parseDisplay(dateInput);
    if (parsed == null) return 'Date must be a valid date';
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
      date: _formatPoDate(parsed),
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
    final parsed = _parseDisplay(_getNormalizedDateInput());
    if (parsed == null) return;
    final dateStr = _formatPoDate(parsed);
    final comment = _commentController.text.trim();
    final commentOrNull = comment.isEmpty ? null : comment;

    if (widget.isCreateMode || _order == null) {
      final created = _repo.add(PurchaseOrder(
        id: '',
        number: '',
        date: dateStr,
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
        date: dateStr,
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
    final dateParsed = _parseDisplay(_getNormalizedDateInput());
    if (dateParsed == null) return;
    final dateStr = _formatPoDate(dateParsed);
    _repo.update(_order!.copyWith(
      date: dateStr,
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

  void _createReceipt() {
    if (_order == null || !_order!.isConfirmed) return;
    if (!receiptsRepository.canCreateReceiptForPurchaseOrder(_order!.id)) return;
    final receipt = receiptsRepository.createFromPurchaseOrder(_order!);
    if (mounted) {
      context.go('/${AppRoutes.pathReceipts}/${receipt.id}');
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

  final GlobalKey _dateFieldKey = GlobalKey();

  void _showCompactCalendar() {
    final box = _dateFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !mounted) return;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    final now = DateTime.now();
    final current = _parseDisplay(_dateController.text.trim()) ?? now;
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    void dismiss() {
      entry.remove();
    }
    entry = OverlayEntry(
      builder: (context) => _CompactCalendarOverlay(
        anchorTop: offset.dy + size.height + 2,
        anchorLeft: offset.dx,
        initialDate: current,
        onSelect: (d) {
          if (mounted) setState(() => _dateController.text = _formatDisplay(d));
          dismiss();
        },
        onDismiss: dismiss,
      ),
    );
    overlay.insert(entry);
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
            backFallbackRoute: '/${AppRoutes.pathPurchaseOrders}',
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
            backFallbackRoute: '/${AppRoutes.pathPurchaseOrders}',
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
              if (widget.isCreateMode) ...[
                FilledButton(onPressed: _save, child: const Text('Save')),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _cancel,
                  child: const Text('Cancel'),
                ),
              ] else if (_order != null && _order!.isDraft) ...[
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
                if (receiptsRepository.canCreateReceiptForPurchaseOrder(_order!.id))
                  FilledButton(
                    onPressed: _createReceipt,
                    child: const Text('Create Receipt'),
                  ),
                if (receiptsRepository.canCreateReceiptForPurchaseOrder(_order!.id))
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
                  child: _SummaryBlock(
                    order: _order,
                    dateController: _dateController,
                    dateFieldKey: _dateFieldKey,
                    dateFocusNode: _dateFocusNode,
                    supplierId: _supplierId,
                    warehouseId: _warehouseId,
                    commentController: _commentController,
                    isDraft: _isDraft,
                    onCalendarTap: _showCompactCalendar,
                    onSupplierChanged: (v) => setState(() => _supplierId = v),
                    onWarehouseChanged: (v) => setState(() => _warehouseId = v),
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
    required this.dateFieldKey,
    required this.dateFocusNode,
    required this.supplierId,
    required this.warehouseId,
    required this.commentController,
    required this.isDraft,
    required this.onCalendarTap,
    required this.onSupplierChanged,
    required this.onWarehouseChanged,
  });

  final PurchaseOrder? order;
  final TextEditingController dateController;
  final GlobalKey dateFieldKey;
  final FocusNode dateFocusNode;
  final String? supplierId;
  final String? warehouseId;
  final TextEditingController commentController;
  final bool isDraft;
  final VoidCallback onCalendarTap;
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
            Container(
              key: dateFieldKey,
              child: TextFormField(
                controller: dateController,
                focusNode: dateFocusNode,
                maxLength: 10,
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  _DateShapeInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Date *',
                  hintText: 'dd.MM.yyyy',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  counterText: '',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, size: 20),
                    onPressed: onCalendarTap,
                    tooltip: 'Pick date',
                  ),
                ),
              ),
            )
          else
            _Row(
              'Date',
              order != null && _isValidPoDate(order!.date)
                  ? _formatDisplay(_parsePoDate(order!.date)!)
                  : '—',
            ),
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

/// Compact popup calendar anchored near the date field.
class _CompactCalendarOverlay extends StatefulWidget {
  const _CompactCalendarOverlay({
    required this.anchorTop,
    required this.anchorLeft,
    required this.initialDate,
    required this.onSelect,
    required this.onDismiss,
  });

  final double anchorTop;
  final double anchorLeft;
  final DateTime initialDate;
  final void Function(DateTime) onSelect;
  final VoidCallback onDismiss;

  @override
  State<_CompactCalendarOverlay> createState() => _CompactCalendarOverlayState();
}

class _CompactCalendarOverlayState extends State<_CompactCalendarOverlay> {
  late DateTime _month;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _cellSize = 36.0;
  static const _popupWidth = 7 * _cellSize + 24.0; // 276
  static const _popupHeight = 12 + 48 + 36 + 8 + 20 + 6 + 6 * _cellSize + 8 + 36 + 12; // year row + Today

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final first = DateTime(_month.year, _month.month);
    final daysInMonth = DateTime(_month.month == 12 ? _month.year + 1 : _month.year,
        _month.month == 12 ? 1 : _month.month + 1, 0).day;
    final startWeekday = first.weekday - 1; // Mon = 0

    final monthLabel = '${_monthNames[_month.month - 1]} ${_month.year}';

    final dayCells = <Widget>[];
    for (var i = 0; i < 42; i++) {
      if (i < startWeekday || i >= startWeekday + daysInMonth) {
        dayCells.add(const SizedBox(width: _cellSize, height: _cellSize));
      } else {
        final day = i - startWeekday + 1;
        final date = DateTime(_month.year, _month.month, day);
        final isSelected = widget.initialDate.year == date.year &&
            widget.initialDate.month == date.month &&
            widget.initialDate.day == date.day;
        dayCells.add(
          SizedBox(
            width: _cellSize,
            height: _cellSize,
            child: Material(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(_cellSize / 2),
              child: InkWell(
                onTap: () => widget.onSelect(date),
                borderRadius: BorderRadius.circular(_cellSize / 2),
                child: Center(
                  child: Text(
                    '$day',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onDismiss,
          child: const ModalBarrier(dismissible: false),
        ),
        Positioned(
          left: widget.anchorLeft,
          top: widget.anchorTop,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: _popupWidth,
              height: _popupHeight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 22),
                          onPressed: () {
                            setState(() {
                              _month = DateTime(_month.year, _month.month - 1);
                            });
                          },
                          tooltip: 'Previous month',
                        ),
                        Expanded(
                          child: Text(
                            monthLabel,
                            style: theme.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 22),
                          onPressed: () {
                            setState(() {
                              _month = DateTime(_month.year, _month.month + 1);
                            });
                          },
                          tooltip: 'Next month',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_double_arrow_left, size: 20),
                          onPressed: () {
                            setState(() {
                              _month = DateTime(_month.year - 1, _month.month);
                            });
                          },
                          tooltip: 'Previous year',
                        ),
                        Expanded(
                          child: Text(
                            '${_month.year}',
                            style: theme.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.keyboard_double_arrow_right, size: 20),
                          onPressed: () {
                            setState(() {
                              _month = DateTime(_month.year + 1, _month.month);
                            });
                          },
                          tooltip: 'Next year',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _weekdays
                          .map((w) => SizedBox(
                                width: _cellSize,
                                child: Text(
                                  w,
                                  style: theme.textTheme.labelSmall,
                                  textAlign: TextAlign.center,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(6, (r) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(7, (c) {
                            return dayCells[r * 7 + c];
                          }),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: TextButton.icon(
                        onPressed: () {
                          final today = DateTime.now();
                          widget.onSelect(today);
                        },
                        icon: const Icon(Icons.today, size: 18),
                        label: const Text('Today'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
    final lines = widget.lines;
    final isDraft = widget.isDraft;

    if (lines.isEmpty && !isDraft) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No lines.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDraft) ...[
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
            if (lines.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'No lines yet. Click Add line to add one.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
              ),
          ],
          if (lines.isNotEmpty)
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
                  if (isDraft)
                    const DataColumn(label: Text('')),
                ],
                rows: lines.asMap().entries.map((entry) {
                  final i = entry.key;
                  final line = entry.value;
                  final item = line.itemId.isNotEmpty
                      ? itemsRepository.getById(line.itemId)
                      : null;
                  if (isDraft) {
                    final otherLineItemIds = <String>{};
                    for (var j = 0; j < lines.length; j++) {
                      if (j != i && lines[j].itemId.isNotEmpty) {
                        otherLineItemIds.add(lines[j].itemId);
                      }
                    }
                    final activeItems = itemsRepository
                        .getAll()
                        .where((it) => it.isActive)
                        .toList();
                    final selectableItems = activeItems
                        .where((it) =>
                            !otherLineItemIds.contains(it.id) || it.id == line.itemId)
                        .toList();
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
                                return [
                                  const Text(
                                    '— Select —',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  ...selectableItems.map(
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
                                ...selectableItems.map(
                                  (it) => DropdownMenuItem<String>(
                                    value: it.id,
                                    child: Text(
                                      '${it.code} - ${it.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
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