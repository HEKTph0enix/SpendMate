# Services & Utilities

This layer contains specialized business logic, data parsing, and algorithms independent of the Flutter UI.

## Services (`lib/services/`)
- `sms_transaction_parser.dart`: Analyzes incoming SMS messages (commonly from banks in India) to automatically extract transaction details (amount, vendor, account).
- `statement_import_service.dart`: Logic for parsing imported bank statements (CSV/PDF) to bulk-add expenses.
- `analytics_service.dart`: Calculates trends, category breakdowns, and spending velocity.
- `savings_suggestion_service.dart`: Generates recommendations for saving money based on spending habits.
- `bank_sync_service.dart` / `bank_data_provider.dart`: Interfaces for syncing bank data or fetching bank details.

## Utilities (`lib/utils/`)
- `settlement_algorithm.dart`: A core algorithm that calculates the optimal (minimum) number of transactions required to settle debts within a group (similar to Splitwise's debt simplification).
- `split_calculator.dart`: Calculates exact amounts owed based on split types (equal, percentage, exact amounts).
- `currency_formatter.dart` & `date_formatter.dart`: Standardizes formatting across the app (especially for Indian Rupee formats).
- `backup_manager.dart`: Logic for exporting/importing the SQLite database for backup.
- `csv_exporter.dart`: Exports expense data to CSV formats.
