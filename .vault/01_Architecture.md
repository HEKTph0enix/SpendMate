# Architecture Overview

SpendMate follows a layered architecture utilizing the **Repository Pattern** and **Provider State Management**.

## Directory Structure (`lib/`)

- `models/`: Plain Dart Data classes (e.g., `Expense`, `Budget`, `GroupSplit`).
- `database/`: Local data persistence logic, primarily `DatabaseHelper` wrapping `sqflite`.
- `repositories/`: Abstracts the data layer (database) from the business logic. Provides clean APIs to fetch and mutate data.
- `providers/`: State management layer. Listens to repositories, applies business logic, and notifies the UI of changes.
- `services/`: Specialized business logic and external/complex operations that don't fit neatly into a single repository (e.g., `AnalyticsService`, `SmsTransactionParser`, `BankSyncService`).
- `screens/`: Flutter UI screens organized by feature (e.g., `dashboard_screen.dart`, `expenses/`, `groups/`).
- `widgets/`: Reusable UI components (e.g., `expense_card.dart`, `neobrutal/` custom UI).
- `utils/`: Helper functions, formatters, algorithms, and extensions (e.g., `currency_formatter.dart`, `settlement_algorithm.dart`).
- `core/`: Core configurations like theming (`app_colors.dart`) and constants.

## Data Flow
UI (Screens/Widgets) -> triggers action -> Provider -> calls -> Repository -> reads/writes -> Database (`sqflite`).
Database -> returns data -> Repository -> returns data -> Provider -> `notifyListeners()` -> UI rebuilds.
