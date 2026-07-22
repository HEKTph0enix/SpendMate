# UI / UX Design

SpendMate features a highly customized UI with specific design languages implemented via custom widgets.

## Design Language
The project utilizes modern, non-standard design aesthetics to stand out:
- **Neumorphism** (Soft UI): Widgets that look extruded from the background. Found in `lib/widgets/neumorphic/` (e.g., `neumorphic_card.dart`, `neumorphic_container.dart`, `neumorphic_text_field.dart`).
- **Neobrutalism**: A stark, high-contrast, bold design style (sometimes with hard shadows and borders). Found in `lib/widgets/neobrutal/`.

## Core Widgets (`lib/widgets/`)
- `dashboard_screen.dart`: The primary entry point showing `balance_card.dart`, recent `transaction_tile.dart`, and `summary_card.dart`.
- `expense_card.dart`: Used across lists to display individual transaction details.
- `stat_chart_card.dart`: Wraps `fl_chart` graphs for visual analytics.
- `group_card.dart`: UI for group splits on the groups screen.
- `budget_progress_card.dart`: Shows how much of a category budget has been utilized.

## Theming
Controlled via `lib/core/theme/app_colors.dart` and `theme_provider.dart`. Ensure any new UI development utilizes the centralized theme colors rather than hardcoded hex values.
