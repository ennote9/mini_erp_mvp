/// Route path and name constants. Dashboard is initial route.
/// Docs: 10_Screen_to_Screen_Navigation_Map_v1.md
class AppRoutes {
  AppRoutes._();

  static const String dashboard = 'dashboard';
  static const String items = 'items';
  static const String itemsNew = 'items-new';
  static const String itemId = 'item';
  static const String suppliers = 'suppliers';
  static const String suppliersNew = 'suppliers-new';
  static const String supplierId = 'supplier';
  static const String customers = 'customers';
  static const String customersNew = 'customers-new';
  static const String customerId = 'customer';
  static const String warehouses = 'warehouses';
  static const String warehousesNew = 'warehouses-new';
  static const String warehouseId = 'warehouse';
  static const String purchaseOrders = 'purchase-orders';
  static const String purchaseOrdersNew = 'purchase-orders-new';
  static const String purchaseOrderId = 'purchase-order';
  static const String receipts = 'receipts';
  static const String receiptId = 'receipt';
  static const String salesOrders = 'sales-orders';
  static const String salesOrdersNew = 'sales-orders-new';
  static const String salesOrderId = 'sales-order';
  static const String shipments = 'shipments';
  static const String shipmentId = 'shipment';
  static const String stockBalances = 'stock-balances';
  static const String stockMovements = 'stock-movements';

  // Paths (no leading slash for go_router child paths)
  static const String pathDashboard = 'dashboard';
  static const String pathItems = 'items';
  static const String pathNew = 'new';
  static const String pathSuppliers = 'suppliers';
  static const String pathCustomers = 'customers';
  static const String pathWarehouses = 'warehouses';
  static const String pathPurchaseOrders = 'purchase-orders';
  static const String pathReceipts = 'receipts';
  static const String pathSalesOrders = 'sales-orders';
  static const String pathShipments = 'shipments';
  static const String pathStockBalances = 'stock-balances';
  static const String pathStockMovements = 'stock-movements';
  static const String pathId = ':id';
}
