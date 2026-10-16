# Be Productive — Project Handoff for a New Chat

Updated: 16 October 2026 (Asia/Kolkata)

## 1. Continue this exact project
- GitHub repository: https://github.com/yyokash16-ui/Be-productive
- Default branch: `main`
- Live GitHub Pages PWA: https://yyokash16-ui.github.io/Be-productive/
- Supabase project URL: https://lihumdmdmsssheyieisq.supabase.co
- Supabase project ref: `lihumdmdmsssheyieisq`
- The GitHub and Supabase connectors are already connected in ChatGPT. Use them when available; make changes directly in the repository rather than making the user manually edit code.
- The app is a vanilla HTML/CSS/JavaScript PWA, mostly in `index.html`. There is no React/Vite build step.

## 2. How the user prefers to work
- Explain things in friendly Tanglish (Tamil + English), plainly and directly.
- Do the actual changes; avoid asking the user to edit code manually.
- Make one requested feature at a time, keep setup minimal and free where possible.
- Preserve existing study/task records. Never drop/recreate Supabase tables or run destructive migrations without explicit consent.
- Before modifying a file, fetch the current version from `main`; then commit carefully. Validate script syntax and check the GitHub Actions deployment.
- After changing app UI/CSS/JS, bump the cache version in `sw.js` so installed PWAs can refresh. Tell the user to close/reopen the phone app or use Ctrl+Shift+R on desktop.

## 3. Current app structure and working features

### Home
- Branding: “Be Productive”, subtitle “STUDY SYSTEM FOR SOW”, Sow CA logo.
- Three main cards: Task Manager, Study Manager, Review Time.
- Persistent Night Mode toggle in the top right. It saves the preference in localStorage per browser/device.

### Task Manager
- Morning wake-up card: today's target vs actual wake-up, meet-target checkbox, success/missed appearance, and tomorrow's target planner.
- Today's tasks are grouped into Professional Tasks and Personal Tasks.
- Task list is date-filtered to the current local day; older records are not deleted and remain in task history.
- Daily task report uses a date picker, with CSV and Word-compatible `.doc` downloads.
- Detailed exports include task names, category, Completed/Incomplete/Removed status, plus summary counts.
- Word-compatible task export has A4 portrait page directives and margins.

### Study Manager
- Study Time Today total, session count, daily study target, and study session data saved to Supabase table `study_sessions`.
- Subject, date, duration in minutes, study method, chapter/topic, optional reflection/notes are part of each session.
- Take a Test is a separate view with subject, target duration, timer controls, target-met/result recording, saved to `study_test_records`.
- **The latest requested Study Manager changes are already present in `index.html` on `main`:**
  - “Log a study session” is a tap-to-open/tap-again-to-close form. It starts collapsed, and its toggle uses `toggleStudyLog`, `aria-expanded`, and `sessionForm`.
  - Date-wise “Download study report” area is present with `studyExportDate`, a session-count/total-duration summary, Download CSV, and Download Word buttons.
  - The selected date's report lists session count and total study time; each session includes subject, study date, duration, study method, chapter/topic, notes/reflection, and logged time.
  - Word-compatible Study Manager export includes A4 portrait page settings and margins.
  - Relevant functions include `studySessionsForDay`, `renderStudyExportSummary`, `studySessionReport`, `exportStudySessionsCsv`, and `exportStudySessionsWord`.
  - Existing study sessions use `state.sessions`, loaded from `study_sessions`; no schema migration is required for these features.

### Review Time
- Displays a task-efficiency ring, 7-day **vertical pillar** graph (no horizontal slider/bar rows, no grid lines), and Today / Weekly / Monthly circular efficiency indicators.
- Tap a day in the pillar graph to expand that day's completed/incomplete task lists; tap the same date again to hide it.
- CSV and Word-compatible daily review exports include task-by-task information.
- Task history comes from `study_task_history`. Daily/weekly/monthly percentages are computed from recorded task status and created-task history.
- Keep this view simple and visual; the user specifically asked not to show a visible formula explanation on the dashboard.

## 4. Supabase tables and important files
Existing app tables/features referenced in code:
- `study_sessions` — study sessions.
- `study_tasks` — tasks.
- `study_settings` — daily study target.
- `wake_up_plans` — planned and actual wake-up information.
- `study_task_history` — task audit/history, including task creation/completion/reopening/edit/deletion events.
- `study_test_records` — test attempt results.

Important repository files:
- `index.html` — UI, styles, JS logic, reports, exports.
- `config.js` — Supabase project URL and browser-safe publishable key; do not print or paste key values into chat or handoff.
- `sw.js` — PWA service-worker cache; increment the cache version after code changes so installed copies update.
- `manifest.webmanifest`, `icons/sow-ca-logo.svg` — PWA metadata and branding.
- `supabase_setup.sql`, `wake_up_setup.sql`, `task_history_setup.sql` — database setup/add-on SQL.
- `.github/workflows/pages.yml` — GitHub Pages deployment workflow.
- `README.md` — project documentation.

Do not expose Supabase credentials, auth tokens, passwords, private user data, or task exports in public docs. The browser-safe publishable key belongs in `config.js`; never put a Supabase service-role/secret key in client code.

## 5. Deployment / continuity notes
- Latest Actions observed when this handoff was written:
  - “Add collapsible Study Log and detailed date-wise session downloads” completed successfully.
  - “Refresh PWA cache for collapsible Study Log and detailed session exports” completed successfully.
  - “pages build and deployment” completed successfully.
- Live app URL: https://yyokash16-ui.github.io/Be-productive/
- If a requested change has already landed, do not add it a second time. Fetch current `main` and inspect the actual source before deciding what remains.
- Avoid claiming the live site is updated until the latest GitHub Pages deployment has succeeded.

## 6. How to resume
Start by reading this file and fetching the latest `index.html`, `sw.js`, and relevant GitHub Actions run. Confirm whether the user's current request already exists in `main`. Then continue with their next requested change without resetting data, redoing existing features, or asking them to re-enter project details.
