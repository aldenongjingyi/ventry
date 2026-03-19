## ADDED Requirements

### Requirement: Display plan usage in Account screen
The system SHALL display the current org's plan tier and resource usage (members, items, projects) in the Account screen. Usage SHALL show current count vs limit (e.g., "28/30 items").

#### Scenario: Account screen shows usage for limited plan
- **WHEN** user views the Account screen and the org is on the Free plan
- **THEN** system displays usage bars for members (X/5), items (X/30), projects (X/2)
- **THEN** each bar shows a visual fill indicator colored by proximity to limit

#### Scenario: Account screen shows usage for unlimited plan
- **WHEN** user views the Account screen and the org is on the Pro plan
- **THEN** system displays counts without limits (e.g., "42 items") for unlimited resources
- **THEN** system does NOT show usage bars for unlimited resources

### Requirement: Show limit warnings when approaching capacity
The system SHALL display inline warnings when the org is within 80% of a resource limit.

#### Scenario: Warning at 80% item capacity
- **WHEN** the org has 25 of 30 items (83% usage) on the Free plan
- **THEN** system displays an amber warning near the item count: "Approaching item limit"

#### Scenario: Warning at 100% capacity
- **WHEN** the org has reached the item limit (30/30 on Free plan)
- **THEN** system displays a red warning: "Item limit reached. Upgrade to add more."
- **THEN** the "Add Item" button in Items list is disabled with a tooltip explaining the limit

### Requirement: Show plan tier badge in Account
The system SHALL display the current org's plan tier as a badge (Free, Starter, Pro, Enterprise) in the Account screen's organisation card.

#### Scenario: Plan badge display
- **WHEN** user views the Account screen
- **THEN** system displays the plan badge next to the organisation name
- **THEN** badge color reflects the plan tier (grey for Free, blue for Starter, gold for Pro, green for Enterprise)

### Requirement: Fetch plan usage from server
The system SHALL call the `get_org_usage` RPC on shell load and cache the result in `SupabaseService` for use across screens.

#### Scenario: Usage data loaded on shell init
- **WHEN** user enters the shell (app start or org switch)
- **THEN** system calls `get_org_usage` with the active org ID
- **THEN** system stores the result (members/items/projects counts and limits, feature flags) as observables

#### Scenario: Usage data refreshed after creating items or projects
- **WHEN** user creates an item or project
- **THEN** system re-fetches `get_org_usage` to update cached counts
