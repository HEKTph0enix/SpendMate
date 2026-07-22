# Instructions for Gemini

Hello Gemini! Welcome to the **SpendMate** project. This is a Flutter-based, offline-first personal expense tracker and group expense splitter for Indian users. 

To help you navigate this codebase effectively and save token usage, please follow these guidelines:

## 1. Project Navigation & Documentation
Before diving into code changes, always refer to the `.vault` directory for project context:
- Start with `.vault/00_Index.md` for a high-level overview.
- Check `.vault/01_Architecture.md` to understand our Repository pattern and Provider state management.
- Refer to `.vault/02_Database.md`, `.vault/03_State_Management.md`, `.vault/04_Services_Utils.md`, and `.vault/05_UI_UX.md` for specific subsystem details.

## 2. Working on this Project
- **Architecture**: Stick to the established layered architecture. Ensure Models, Providers, Repositories, and Services are kept distinct and clean.
- **State Management**: Use the `provider` package. Avoid adding new state management libraries unless explicitly requested.
- **Database**: Use the existing `sqflite` implementation through `DatabaseHelper`.
- **UI/UX**: Match our existing Neumorphic and Neobrutal design language (found in `lib/widgets/neumorphic/` and `lib/widgets/neobrutal/`). 

## 3. Communication & Clarification
**CRITICAL RULE:** If you are ever unsure about a requirement, an architectural decision, or an implementation detail, you MUST pause and question back the user for clarification before proceeding with assumptions or writing code.
