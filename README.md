# Be Productive — CA Inter Study Tracker

Mobile-first study tracking PWA with Supabase cloud sync. Built for CA Inter: subject-wise sessions, chapter/topic notes, revision and practice tracking, assignments, daily target and a seven-day study chart.

## Included files
- `index.html` — responsive app UI and JavaScript
- `config.js` — Supabase Project URL and browser-safe publishable key
- `supabase_setup.sql` — original study tracker database setup
- `wake_up_setup.sql` — safe add-on migration for planned wake-up targets (preserves existing study data)
- `manifest.webmanifest`, `sw.js`, `icons/sow-ca-logo.svg` — Sow CA branding, PWA install icon and offline shell
- `.github/workflows/pages.yml` — automatic GitHub Pages deployment

## Database and account setup
1. The original Supabase tables should already exist if you successfully ran `supabase_setup.sql`: `study_sessions`, `study_tasks`, and `study_settings`. To enable the morning target feature, run `wake_up_setup.sql` once in Supabase SQL Editor; this adds `wake_up_plans` and does not delete existing study records.
2. Supabase URL and publishable key are set in `config.js`. Never put a `service_role` or secret key in browser-side code.
3. In Supabase Authentication, keep Email enabled. For the simplest personal setup, create one account from the app and use the same account on both your laptop and phone. If signup requires email confirmation, open the confirmation link first.
4. The SQL uses RLS so rows are scoped to the signed-in account. Anyone with the same shared login can view/edit the tracker.

## Publish using GitHub Pages
1. Open this repository → **Settings → Pages**.
2. Under build and deployment, select **GitHub Actions** as the source if it is not already selected.
3. The workflow deploys the app on pushes to `main`. In **Actions**, wait for **Deploy Be Productive PWA to GitHub Pages** to finish successfully.
4. Your Pages URL will appear in Settings → Pages. Open that HTTPS URL, create/sign in to your account, then install it from your browser menu.
5. On Android/Chrome, use **Install app** or **Add to Home Screen**. On iPhone/Safari, use **Share → Add to Home Screen**.

## Verification checklist
- Log a test study session from the phone.
- Confirm the entry appears on the laptop using the same account.
- Confirm the sync badge changes to **Live sync on**.
- The app requires internet for authentication and cloud writes. Its interface shell may be cached offline; offline writes are not queued. The wake-up card shows a setup reminder until `wake_up_setup.sql` has been run.

## Privacy and cost
The repository is public and contains browser app code, not passwords. Supabase publishable keys are designed for client use, with RLS policies enforcing row access. Do not commit passwords, personal exports, or service-role/secret keys. Free hosting/database tiers are subject to provider quotas and can change.


## Task history and reports
The `task_history_setup.sql` file keeps an idempotent backup of the history schema, Row Level Security policy, audit trigger, realtime registration and safe seeding logic.
Task activity is logged in the private `study_task_history` table. It records new tasks, completions, reopenings, edits and deletions, and the Task Manager can show a date-based summary and export that day as CSV. History is scoped to the signed-in user and is retained independently of task deletion.
