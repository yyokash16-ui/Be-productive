# PlantPulse Digital Twin — Pump P-101

Mobile-first industrial monitoring prototype. Open the app at the repository's GitHub Pages URL plus `/plantpulse/` after Pages hosting is enabled.

## Demo features
- Responsive phone and desktop layout
- Centrifugal pump P-101 example measurements
- Synthetic sample readings refresh every five seconds
- Scenarios: normal, high vibration, low suction pressure, high bearing temperature, low flow
- Rule-based illustrative alerts, diagnosis suggestions, equipment details, trends, event notes and CSV exports
- Supabase endpoint reachability test

## Important
All displayed values are generated demonstration data. This is not connected to a plant, PLC, SCADA, sensors or DWSIM. Thresholds and diagnosis are illustrative only and must be validated by qualified site engineers. Not for safety-critical decisions or equipment control.

## Hosting
Enable GitHub Pages in the repository settings (Settings → Pages). If Pages is already enabled for the repository root, visit `/plantpulse/` under the published site URL. If Pages is not enabled, enable deployment from the `main` branch and root folder. This application is a static page and requires no build service.

## Supabase / production work remaining
The settings screen can test whether the Supabase REST endpoint responds. This prototype does not yet persist telemetry to Supabase. Before doing so, create the tables, enable Row Level Security, define authenticated policies, and implement secure persistence. Never expose a service-role key in browser code.

For real industrial monitoring, use an authorized edge gateway to send validated sensor data through an authenticated backend API. Do not expose PLC/SCADA networks or unauthenticated control APIs to the internet. The mobile dashboard should remain read-only for process control.
