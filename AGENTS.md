# AGENTS.md

## Project Purpose
This repository contains a desktop-first mini ERP MVP built with Flutter.

The product scope is intentionally narrow:
- Master data: Items, Suppliers, Customers, Warehouses
- Purchase flow: Purchase Orders -> Receipts
- Sales flow: Sales Orders -> Shipments
- Inventory visibility: Stock Balances, Stock Movements
- Dashboard
- Enterprise-style desktop UI shell

Do not expand the product scope unless the documentation explicitly changes.

---

## Source of Truth
Always treat the `/docs` folder as the primary source of truth.

Read relevant documents before proposing architecture, writing code, changing UI, or modifying flows.

Documentation folders:
- `/docs/01_product_core`
- `/docs/02_screens_and_navigation`
- `/docs/03_ui_ux_patterns`
- `/docs/04_growth_and_roadmap`

If existing code conflicts with documentation:
1. Prefer the documentation
2. Do not silently follow the code
3. Explicitly report the conflict

---

## Required Reading Before Work

### Before any product or domain logic work
Read:
- `/docs/01_product_core/01_MVP_Overview.md`
- `/docs/01_product_core/02_Domain_Model.md`
- `/docs/01_product_core/03_Statuses_and_Rules.md`
- `/docs/01_product_core/04_Document_Flows.md`
- `/docs/01_product_core/05_Validation_Rules.md`
- `/docs/01_product_core/07_MVP_Scope_Freeze_v0.1.md`

### Before any navigation or routing work
Read:
- `/docs/02_screens_and_navigation/08_Screens_v1.md`
- `/docs/02_screens_and_navigation/09_Navigation_and_App_Shell_v1.md`
- `/docs/02_screens_and_navigation/10_Screen_to_Screen_Navigation_Map_v1.md`

### Before any UI, page, grid, or form work
Read:
- `/docs/03_ui_ux_patterns/11_List_Page_Pattern_v1.md`
- `/docs/03_ui_ux_patterns/12_Object_Page_Pattern_v1.md`
- `/docs/03_ui_ux_patterns/13_Document_Page_Layout_v1.md`
- `/docs/03_ui_ux_patterns/14_Master_Data_Page_Layout_v1.md`
- `/docs/03_ui_ux_patterns/15_Form_Layout_Pattern_v1.md`
- `/docs/03_ui_ux_patterns/16_Create_Edit_Pattern_v1.md`
- `/docs/03_ui_ux_patterns/17_Dashboard_v1.md`
- `/docs/03_ui_ux_patterns/18_Document_Numbering_and_Naming_Rules_v1.md`
- `/docs/03_ui_ux_patterns/19_Data_Grid_Column_Definitions_v1.md`
- `/docs/03_ui_ux_patterns/20_Grid_Interaction_Rules_v1.md`
- `/docs/03_ui_ux_patterns/21_Empty_Loading_Error_States_v1.md`
- `/docs/03_ui_ux_patterns/22_UI_Consistency_Rules_v1.md`

### Before proposing future features
Read:
- `/docs/04_growth_and_roadmap/23_Out_of_Scope_and_Future_Expansion_Map.md`

---

## Non-Negotiable Product Rules

### Core process rules
- Purchase Order and Sales Order are intent documents
- Receipt and Shipment are fact documents
- Only Posted Receipt and Posted Shipment affect inventory
- Stock Balance must not be edited manually
- Stock Movement must not be created or edited manually

### Creation rules
- Create and edit must use separate pages
- Do not use modal-based document creation or editing
- Do not use inline editing in grids

### Document source rules
- Receipt is created only from a Confirmed Purchase Order
- Shipment is created only from a Confirmed Sales Order
- Receipt has no direct `New` action from list page
- Shipment has no direct `New` action from list page

### Status rules
- Purchase Order: Draft -> Confirmed -> Closed / Cancelled
- Sales Order: Draft -> Confirmed -> Closed / Cancelled
- Receipt: Draft -> Posted / Cancelled
- Shipment: Draft -> Posted / Cancelled
- Confirmed Purchase Orders and Sales Orders are read-only
- Posted and Cancelled documents are read-only
- Posted documents are not reversible in MVP

### MVP restrictions
Do not add:
- Partial receipt
- Partial shipment
- Multiple receipts per purchase order
- Multiple shipments per sales order
- Pricing
- Amounts
- Discounts
- Taxes
- Payments
- Roles and permissions
- WMS-level logic
- Reservations
- Allocation
- Picking
- Packing
- Bins/locations
- Lots/batches/serials
- Advanced grid configurators
- Saved views
- Grouping
- Freeze columns
- Advanced filter builder
- Inline editing
- BI/reporting layer beyond agreed dashboard

---

## UI Direction
The UI must follow the approved direction from the documentation.

### Mandatory UI principles
- Desktop-first
- Dark-first, but light-ready architecture
- English UI
- Sidebar-based shell
- Collapsible/expandable left navigation
- Grouped navigation:
  - Dashboard
  - Master Data
  - Purchasing
  - Sales
  - Inventory

### Page patterns
- List pages follow one consistent pattern
- Object pages follow one consistent pattern
- Document pages and master data pages are not interchangeable
- Dashboard is overview-only, not an action center

### Grid principles
- Checkbox column on all list pages
- Row click opens object/detail page where applicable
- Search and filter are simple and screen-specific
- Single-column sort only in MVP
- Status badges are informational, not workflow controls

---

## Implementation Discipline
When implementing any change:
1. Read the relevant docs first
2. Summarize the intended behavior internally before coding
3. Keep the implementation inside MVP scope
4. Avoid inventing extra abstractions unless they are clearly justified
5. Prefer simple, explicit code over premature flexibility
6. Keep terminology exactly aligned with docs
7. Do not reintroduce old experimental UI patterns or removed features

---

## Conflict Handling
If you find ambiguity, missing detail, or conflict:
- Do not guess silently
- Do not invent a new pattern casually
- Use the closest approved pattern from docs
- Clearly state what is missing or conflicting

---

## Output Expectations
When making meaningful changes:
- explain what you changed
- explain which docs governed the change
- note any deviation from docs
- note anything that still needs a decision

For UI changes especially, always state which documentation files were used.

---

## Final Principle
This project must grow from the documentation outward.

Do not let old code structure, legacy UI ideas, or convenience shortcuts override the agreed MVP design.
