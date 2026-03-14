import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../items/data/items_repository.dart';
import '../sales_orders/data/sales_orders_repository.dart';
import '../warehouses/data/warehouses_repository.dart';
import '../../shared/app_breadcrumb.dart';
import '../../shared/app_page_header.dart';
import 'data/shipment.dart';
import 'data/shipment_line.dart';
import 'data/shipments_repository.dart';

/// Storage format yyyy-MM-dd.
String _formatStorage(DateTime d) {
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

DateTime? _parseStorage(String s) {
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

bool _matchesDateShape(String s) {
  if (s.isEmpty) return true;
  if (s.length > 10) return false;
  if (RegExp(r'^\d{0,8}$').hasMatch(s)) return true;
  return RegExp(r'^\d{0,2}(\.\d{0,2}(\.\d{0,4})?)?$').hasMatch(s);
}

String _format8DigitsToDate(String eightDigits) {
  if (eightDigits.length != 8) return eightDigits;
  return '${eightDigits.substring(0, 2)}.${eightDigits.substring(2, 4)}.${eightDigits.substring(4)}';
}

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

/// Shipment page. Object only (no create route). Lines strictly read-only in MVP.
/// Docs: 08_Screens_v1, 13_Document_Page_Layout_v1.
class ShipmentPage extends StatefulWidget {
  const ShipmentPage({super.key, required this.id});

  final String id;

  @override
  State<ShipmentPage> createState() => _ShipmentPageState();
}

class _ShipmentPageState extends State<ShipmentPage> {
  final ShipmentsRepository _repo = shipmentsRepository;

  Shipment? _shipment;
  List<ShipmentLine> _lines = [];
  final _dateController = TextEditingController();
  final _dateFocusNode = FocusNode();
  final _commentController = TextEditingController();

  bool _loading = true;
  String? _validationError;

  void _load() {
    _shipment = _repo.getById(widget.id);
    if (_shipment != null) {
      _lines = _repo.getLines(_shipment!.id);
      final stored = _parseStorage(_shipment!.date);
      _dateController.text = _formatDisplay(stored ?? DateTime.now());
      _commentController.text = _shipment!.comment ?? '';
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
  void didUpdateWidget(covariant ShipmentPage oldWidget) {
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

  bool get _isDraft => _shipment != null && _shipment!.isDraft;

  String get _title => _shipment == null ? 'Shipment' : 'Shipment ${_shipment!.number}';

  List<String> get _breadcrumbSegments =>
      _shipment == null
          ? ['Sales', 'Shipments', widget.id]
          : ['Sales', 'Shipments', _shipment!.number];

  String _statusLabel() {
    if (_shipment == null) return 'Draft';
    switch (_shipment!.status) {
      case 'draft':
        return 'Draft';
      case 'posted':
        return 'Posted';
      case 'cancelled':
        return 'Cancelled';
      default:
        return _shipment!.status;
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
    return _repo.validateDraft(
      date: _formatStorage(parsed),
      salesOrderId: _shipment!.salesOrderId,
      warehouseId: _shipment!.warehouseId,
      lines: _lines,
    );
  }

  void _save() {
    setState(() => _validationError = null);
    final err = _validate();
    if (err != null) {
      setState(() => _validationError = err);
      return;
    }
    final parsed = _parseDisplay(_getNormalizedDateInput());
    if (parsed == null || _shipment == null || !_shipment!.isDraft) return;
    final dateStr = _formatStorage(parsed);
    final comment = _commentController.text.trim();
    final commentOrNull = comment.isEmpty ? null : comment;
    _repo.update(_shipment!.copyWith(date: dateStr, comment: commentOrNull));
    _shipment = _repo.getById(_shipment!.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shipment saved')),
      );
      setState(() {});
    }
  }

  void _cancel() {
    context.go('/${AppRoutes.pathShipments}');
  }

  void _post() {
    setState(() => _validationError = null);
    final err = _repo.validatePost(_shipment!.id);
    if (err != null) {
      setState(() => _validationError = err);
      return;
    }
    _repo.post(_shipment!.id);
    _shipment = _repo.getById(_shipment!.id);
    _lines = _repo.getLines(_shipment!.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shipment posted')),
      );
      setState(() {});
    }
  }

  void _cancelDocument() {
    if (_shipment == null) return;
    _repo.cancelDocument(_shipment!.id);
    _shipment = _repo.getById(_shipment!.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shipment cancelled')),
      );
      setState(() {});
    }
  }

  final GlobalKey _dateFieldKey = GlobalKey();

  Future<void> _pickDate() async {
    final current = _parseDisplay(_dateController.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dateController.text = _formatDisplay(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_shipment == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: 'Shipment',
            breadcrumb: AppBreadcrumb(
              segments: ['Sales', 'Shipments', widget.id],
            ),
            backFallbackRoute: '/${AppRoutes.pathShipments}',
          ),
          const Divider(height: 1),
          const Expanded(
            child: Center(child: Text('Shipment not found')),
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
            backFallbackRoute: '/${AppRoutes.pathShipments}',
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
                  onPressed: _post,
                  child: const Text('Post'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _cancelDocument,
                  child: const Text('Cancel document'),
                ),
              ],
            ],
          ),
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
                  child: _ShipmentSummaryBlock(
                    shipment: _shipment!,
                    dateController: _dateController,
                    dateFieldKey: _dateFieldKey,
                    dateFocusNode: _dateFocusNode,
                    commentController: _commentController,
                    isDraft: _isDraft,
                    onCalendarTap: _pickDate,
                  ),
                ),
                _ShipmentLinesTab(lines: _lines),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentSummaryBlock extends StatelessWidget {
  const _ShipmentSummaryBlock({
    required this.shipment,
    required this.dateController,
    required this.dateFieldKey,
    required this.dateFocusNode,
    required this.commentController,
    required this.isDraft,
    required this.onCalendarTap,
  });

  final Shipment shipment;
  final TextEditingController dateController;
  final GlobalKey dateFieldKey;
  final FocusNode dateFocusNode;
  final TextEditingController commentController;
  final bool isDraft;
  final VoidCallback onCalendarTap;

  static bool _isValidDate(String s) {
    final t = s.trim();
    if (t.length != 10) return false;
    final d = DateTime.tryParse(t);
    return d != null && d.year >= 1900 && d.year <= 2100;
  }

  static String _displayDate(String s) {
    if (s.trim().isEmpty) return '—';
    final d = DateTime.tryParse(s.trim());
    if (d == null || d.year < 1900 || d.year > 2100) return '—';
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final so = salesOrdersRepository.getById(shipment.salesOrderId);
    final warehouse = warehousesRepository.getById(shipment.warehouseId);

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
          _SummaryRow('Number', shipment.number),
          const SizedBox(height: 8),
          if (isDraft)
            Container(
              key: dateFieldKey,
              child: TextFormField(
                controller: dateController,
                focusNode: dateFocusNode,
                maxLength: 10,
                keyboardType: TextInputType.datetime,
                inputFormatters: [_DateShapeInputFormatter()],
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
            _SummaryRow('Date', _isValidDate(shipment.date) ? _displayDate(shipment.date) : '—'),
          const SizedBox(height: 8),
          _SummaryRow('Related Sales Order', so?.number ?? shipment.salesOrderId),
          const SizedBox(height: 8),
          _SummaryRow('Warehouse', warehouse?.name ?? shipment.warehouseId),
          const SizedBox(height: 8),
          _SummaryRow('Status', _statusText(shipment.status)),
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
            _SummaryRow('Comment', shipment.comment ?? '—'),
        ],
      ),
    );
  }

  static String _statusText(String s) {
    switch (s) {
      case 'draft':
        return 'Draft';
      case 'posted':
        return 'Posted';
      case 'cancelled':
        return 'Cancelled';
      default:
        return s;
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
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

/// Lines tab: read-only. No add line, no delete line, no editable item or qty (MVP).
class _ShipmentLinesTab extends StatelessWidget {
  const _ShipmentLinesTab({required this.lines});

  final List<ShipmentLine> lines;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5);
          }),
          columns: const [
            DataColumn(label: Text('Item')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('UOM')),
          ],
          rows: lines.map((line) {
            final item = itemsRepository.getById(line.itemId);
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
    );
  }
}
