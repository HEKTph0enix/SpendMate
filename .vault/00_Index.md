# SpendMate Documentation Vault

Welcome to the SpendMate `.vault`. This folder contains concise, structured documentation of the SpendMate project to help AI assistants and developers navigate the codebase efficiently and reduce context token usage.

## Navigation

- [[01_Architecture.md]] - High-level project structure and design patterns (Repository Pattern, Layered Architecture).
- [[02_Database.md]] - Local offline storage implementation (SQLite, Data Models).
- [[03_State_Management.md]] - Global app state management (Provider).
- [[04_Services_Utils.md]] - Core business logic, services, and utilities (SMS Parsing, PDF Import, Settlements).
- [[05_UI_UX.md]] - User Interface and Design Language (Neumorphic / Neobrutal).

## Project Overview
**SpendMate** is an offline-first personal expense tracker and group expense splitter designed for Indian users. It focuses on privacy (local storage), intelligent insights, and a unique design language.

## Key Technologies
- **Framework**: Flutter (>=3.10.0)
- **Language**: Dart (>=3.0.0)
- **Database**: `sqflite`
- **State Management**: `provider`
- **Charting**: `fl_chart`
