# Ventry - TODO

## Completed
- [x] Bottom nav restructure: Home | Projects | [FAB] | Items | Account
- [x] Home dashboard with greeting, org stats, quick actions, active projects, recent activity
- [x] Onboarding checklist for new orgs (create project, add item, invite team)
- [x] 2x2 stat grid: Total Items, In Storage, Deployed, Active Projects
- [x] Stat cards navigate to respective screens with pre-applied filters
- [x] Quick actions row: Scan QR, Add Item, New Project, Bulk Move (monochrome accent)
- [x] Active project cards with item count pill + check-in progress bar
- [x] Missing items alert banner with navigation to filtered items list
- [x] Org pill + stat grid wrapped in single GlassCard
- [x] Brand bar (Ventry icon + wordmark) in shell — visible on all tabs
- [x] Members moved out of nav bar into Account screen as a row
- [x] Members registered as standalone route
- [x] Projects filter chips (All / Active / Completed / Archived)
- [x] Font size bump across entire app (+2-4px per token)
- [x] Login slogan: "Equipment management made easy"
- [x] Screenshot test infrastructure + skills + docs
- [x] Design system overhaul: semantic color families (acc, em, am, re, sl)

## In Progress
- [ ] Polish home dashboard layout and visual hierarchy

## Backlog

### UI / UX
- [ ] Account avatar in shell brand bar (top-right, visible on all tabs)
- [ ] Move Account out of nav bar, replace with Settings tab
- [ ] Settings screen: Scanner Settings, About, Sign Out
- [ ] Notification bell with recent activity (needs unread/seen tracking)
- [ ] Report / Contact support button (in Account or Settings)
- [ ] Dark mode refinements / light mode support
- [ ] Pull-to-refresh animation customisation

### Features
- [ ] Bulk adding items (add multiple items at once)
- [ ] Bulk QR printing (select items, generate printable QR sheet)
- [ ] QR scanner improvements (scan history, batch scan mode)
- [ ] Active projects progress bar on projects list view
- [ ] Push notifications for activity (missing reports, project updates)
- [ ] Bulk item operations (move, export, delete)
- [ ] Item search across all statuses
- [ ] Export inventory report (CSV / PDF)
- [ ] Offline mode / local caching

### Technical
- [ ] Integration test coverage for all screens
- [ ] Error handling improvements (retry logic, offline detection)
- [ ] Performance: lazy-load activity log, paginate item lists
- [ ] Supabase realtime subscriptions for live updates
- [ ] CI/CD pipeline setup
