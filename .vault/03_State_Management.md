# State Management

The application uses the `provider` package (`ChangeNotifierProvider`) for global state management and dependency injection.

## Key Providers (`lib/providers/`)
- `expense_provider.dart`: Manages the state of the user's expenses, caching them in memory for fast UI access.
- `group_provider.dart`: Manages state for group splits and settlements.
- `financial_dashboard_provider.dart`: Aggregates data for the main dashboard (total balance, recent expenses, budget progress).
- `budget_provider.dart`: Tracks budget limits and alerts when exceeding them.
- `analytics_provider.dart` & `statistics_provider.dart`: Feeds data to the charting and statistics UI.
- `theme_provider.dart`: Manages app theme settings (e.g., light/dark mode, custom color accents).
- `settings_provider.dart`: User preferences and app configurations.

## Usage Pattern
Providers are typically injected at the root of the app in `lib/app.dart` or `lib/main.dart` using a `MultiProvider`.
Screens use `Consumer<T>` or `context.watch<T>()` to rebuild when data changes. Updates are triggered by `context.read<T>().methodName()`.
