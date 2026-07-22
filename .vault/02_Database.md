# Database & Models

SpendMate is an offline-first application relying on a local SQLite database using the `sqflite` package.

## Core Database Component
- `lib/database/database_helper.dart`: The singleton managing the database connection, table creation, migrations, and direct SQL queries.

## Key Models (`lib/models/`)
- `expense.dart`: Represents an individual transaction/expense.
- `budget.dart`: Represents a budget limit for a category.
- `financial_account.dart` & `cash_wallet.dart`: Represents user's banks or cash accounts.
- `expense_group.dart`, `group_member.dart`, `group_split.dart`, `settlement.dart`: Models for the group expense splitting feature (like Splitwise).
- `transaction.dart`: A unified model for financial movements (income/expense/transfer).
- `recurring_expense.dart`: Handles subscriptions and recurring payments.
- `spending_insight.dart` & `savings_suggestion.dart`: AI/Algorithm generated insights based on user spending behavior.

## Repositories (`lib/repositories/`)
Repositories act as the bridge between Models and the Database.
- `expense_repository.dart`
- `budget_repository.dart`
- `group_repository.dart`
- `transaction_repository.dart`
- *Each repository typically implements standard CRUD operations.*
