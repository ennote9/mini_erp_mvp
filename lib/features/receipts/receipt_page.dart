import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../items/data/items_repository.dart';
import '../purchase_orders/data/purchase_orders_repository.dart';
import '../warehouses/data/warehouses_repository.dart';
import '../../shared/app_breadcrumb.dart';
import '../../shared/app_page_header.dart';
import 'data/receipt.dart';
import 'data/receipt_line.dart';
import 'data/receipts_repository.dart';

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

/// Receipt page. Object only (no create route). Docs: 08_Screens_v1, 13_Document_Page_Layout_v1.
class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key, required this.id});

  final String id;

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final ReceiptsRepository _repo = receiptsRepository;

  Receipt? _receipt;
  List<ReceiptLine> _lines = [];
  final _dateController = TextEditingController();
  final _dateFocusNode = FocusNode();
  final _commentController = TextEditingController();

  bool _loading = true;
  String? _validationError;

  void _load() {
    _receipt = _repo.getById(widget.id);
    if (_receipt != null) {
      _lines = _repo.getLines(_receipt!.id);
      final stored = _parseStorage(_receipt!.date);
      _dateController.text = _formatDisplay(stored ?? DateTime.now());
      _commentController.text = _receipt!.comment ?? '';
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
  void didUpdateWidget(covariant ReceiptPage oldWidget) {
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

  bool get _isDraft => _receipt != null && _receipt!.isDraft;

  String get _title => _receipt == null ? 'Receipt' : 'Receipt ${_receipt!.number}';

  List<String> get _breadcrumbSegments =>
      _receipt == null
          ? ['Purchasing', 'Receipts', widget.id]
          : ['Purchasing', 'Receipts', _receipt!.number];

  String _statusLabel() {
    if (_receipt == null) return 'Draft';
    switch (_receipt!.status) {
      case 'draft':
        return 'Draft';
      case 'posted':
        return 'Posted';
      case 'cancelled':
        return 'Cancelled';
      default:
        return _receipt!.status;
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
      purchaseOrderId: _receipt!.purchaseOrderId,
      warehouseId: _receipt!.warehouseId,
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
    if (parsed == null || _receipt == null || !_receipt!.isDraft) return;
    final dateStr = _formatStorage(parsed);
    final comment = _commentController.text.trim();
    final commentOrNull = comment.isEmpty ? null : comment;
    _repo.update(_receipt!.copyWith(date: dateStr, comment: commentOrNull));
    _receipt = _repo.getById(_receipt!.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt saved')),
      );
      setState(() {});
    }
  }

  void _cancel() {
    context.go('/${AppRoutes.pathReceipts}');
  }

  void _post() {
    setState(() => _validationError = null);
    final err = _repo.validatePost(_receipt!.id);
    if (err != null) {
      setState(() => _validationError = err);
      return;
    }
    _repo.post(_receipt!.id);
    _receipt = _repo.getById(_receipt!.id);
    _lines = _repo.getLines(_receipt!.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt posted')),
      );
      setState(() {});
    }
  }

  void _cancelDocument() {
    if (_receipt == null) return;
    _repo.cancelDocument(_receipt!.id);
    _receipt = _repo.getById(_receipt!.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt cancelled')),
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
    if (_receipt == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: 'Receipt',
            breadcrumb: AppBreadcrumb(
              segments: ['Purchasing', 'Receipts', widget.id],
            ),
            backFallbackRoute: '/${AppRoutes.pathReceipts}',
          ),
          const Divider(height: 1),
          const Expanded(
            child: Center(child: Text('Receipt not found')),
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
            backFallbackRoute: '/${AppRoutes.pathReceipts}',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              _statusLabel(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          TabBar(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.7),
            indicatorColor: Theme.of(context).colorScheme.primary,
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: _ReceiptSummaryBlock(
                    receipt: _receipt!,
                    dateController: _dateController,
                    dateFieldKey: _dateFieldKey,
                    dateFocusNode: _dateFocusNode,
                    commentController: _commentController,
                    isDraft: _isDraft,
                    onCalendarTap: _pickDate,
                  ),
                ),
                _ReceiptLinesTab(lines: _lines),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptSummaryBlock extends StatelessWidget {
  const _ReceiptSummaryBlock({
    required this.receipt,
    required this.dateController,
    required this.dateFieldKey,
    required this.dateFocusNode,
    required this.commentController,
    required this.isDraft,
    required this.onCalendarTap,
  });

  final Receipt receipt;
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
    final po = purchaseOrdersRepository.getById(receipt.purchaseOrderId);
    final warehouse = warehousesRepository.getById(receipt.warehouseId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow('Number', receipt.number),
          const SizedBox(height: 10),
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
            _SummaryRow('Date', _isValidDate(receipt.date) ? _displayDate(receipt.date) : '—'),
          const SizedBox(height: 10),
          _SummaryRow('Related Purchase Order', po?.number ?? receipt.purchaseOrderId),
          const SizedBox(height: 10),
          _SummaryRow('Warehouse', warehouse?.name ?? receipt.warehouseId),
          const SizedBox(height: 10),
          _SummaryRow('Status', _statusText(receipt.status)),
          const SizedBox(height: 10),
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
            _SummaryRow('Comment', receipt.comment ?? '—'),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _ReceiptLinesTab extends StatelessWidget {
  const _ReceiptLinesTab({required this.lines});

  final List<ReceiptLine> lines;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Text(
          'No lines.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
