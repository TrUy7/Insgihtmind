# InsightMind App Feature Expansion TODO

## Completed Tasks
- [x] Analyze current codebase and create plan
- [x] Get user approval for plan
- [x] Add fl_chart dependency to pubspec.yaml
- [x] Create DailyJournal entity (id, date, content, mood)
- [x] Create TestResult entity (id, date, testType, answers, score, risk)
- [x] Create journalProvider (StateNotifier for List<DailyJournal>)
- [x] Create testProvider (StateNotifier for List<TestResult>)
- [x] Create analysisProvider (computed provider for AI analysis)
- [x] Add DASS-21 questions to question.dart
- [x] Create DailyJournalPage (list journals, add new form)
- [x] Create TestPage (select test type, answer questions, show result)
- [x] Create ReportsPage (charts of scores over time)
- [x] Create RecommendationsPage (tips based on analysis)
- [x] Update app.dart: Add BottomNavigationBar with 5 tabs (Home, Screening, History, Daily, Reports)
- [x] Update HomePage: Simplify, remove navigation buttons
- [x] Run flutter pub get
- [x] Test navigation and new features
- [x] Ensure charts display correctly
