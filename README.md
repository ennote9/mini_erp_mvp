# Mini ERP MVP

## Project Name

**Mini ERP MVP** — a desktop-first mini ERP (Enterprise Resource Planning) application.

## What This Project Is

A small business inventory and document-flow application built with Flutter. It is designed as a **desktop-first** mini ERP with a narrow, well-defined scope. The product follows documented flows for master data, purchasing, sales, and inventory visibility.

## Current Scope (v0.1 MVP)

The v0.1 scope is fixed and documented under `docs/`. In summary:

- **Master data:** Items, Suppliers, Customers, Warehouses
- **Documents:** Purchase Orders, Receipts, Sales Orders, Shipments
- **Inventory visibility:** Stock Balances, Stock Movements
- **UI:** Dashboard, app shell, sidebar navigation, list and object pages

Receipts are created only from Confirmed Purchase Orders; Shipments only from Confirmed Sales Orders. There is no pricing, finance, permissions, or WMS layer in MVP.

## Implemented So Far

- **App shell** — Stable layout with left sidebar and main workspace
- **Sidebar navigation** — Grouped navigation (Dashboard, Master Data, Purchasing, Sales, Inventory), expand/collapse, active route highlighting
- **Routing** — go_router with all list and object/create routes; Dashboard as initial route
- **Dashboard** — Placeholder overview page (summary blocks, quick navigation)
- **Placeholder list and object pages** — For all modules (Items, Suppliers, Customers, Warehouses, Purchase Orders, Receipts, Sales Orders, Shipments, Stock Balances, Stock Movements)
- **Document placeholder pages** — Purchase Order, Receipt, Sales Order, Shipment with Overview/Lines tabs
- **Items module (real)** — In-memory Items repository; list page with grid, search, Active/Inactive/All filter, row click; item page for create and edit with Save, Cancel, Activate/Deactivate toggle; validation (code/name/UOM required, code unique); list refreshes when repository changes

## Project Structure

```
lib/
  main.dart, app.dart
  core/          # theme, router
  layout/        # app shell, sidebar
  shared/        # shared UI placeholders
  features/      # dashboard, items, suppliers, customers, ...
docs/            # product and UI documentation (source of truth)
.cursor/rules/   # Cursor rules (scope, UI, architecture)
AGENTS.md        # Agent instructions and product rules
```

## Documentation Source of Truth

- **docs/** — Product scope, domain model, statuses, flows, validation, screens, navigation, UI patterns
- **AGENTS.md** — Required reading for agents; non-negotiable product and UI rules
- **.cursor/rules/** — Scope, UI, and architecture rules for the codebase

Code and UI must align with the documentation; conflicts are resolved in favor of the docs.

## How To Run

- **Prerequisites:** Flutter SDK (see [flutter.dev](https://flutter.dev))
- **Install:** `flutter pub get`
- **Run (Windows):** `flutter run -d windows`
- **Run (Chrome):** `flutter run -d chrome`

Other platforms (macOS, Linux) are supported by Flutter where configured.

## Current Limitations

- **In-memory data only** — No backend, no database; data is lost on restart
- **No backend or API** — All logic is local
- **No advanced ERP logic yet** — Document lifecycle (Confirm, Post, Create Receipt/Shipment) and other modules are placeholder-only
- **Items is the only fully implemented module** — Other master data and document modules are placeholder UI only

## Next Planned Step

Further implementation follows the docs (e.g. `docs/01_product_core`, `docs/04_growth_and_roadmap`). The next steps are defined there; do not expand scope beyond the agreed v0.1 without updating the documentation.
