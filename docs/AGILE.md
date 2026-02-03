# Agile backlog (PowerCoffee)

## Epic 1: Solution foundation
**Goal:** Solution-based ALM setup for PowerCoffee.

### Feature 1.1: CLI bootstrap
**User story:** As a maker, I want to initialize a solution via CLI so that I can manage ALM in source control.
- Task: Authenticate and select environment
- Task: Initialize solution project
- Task: Pack and import solution

### Feature 1.2: ALM packaging
**User story:** As a release manager, I want to export and unpack the solution so that changes are tracked in git.
- Task: Export solution zip
- Task: Unpack to src/Solution
- Task: Create deployment settings file

## Epic 2: Dataverse data model
**Goal:** Core tables for coffee tasting.

### Feature 2.1: Tasting notes table
**User story:** As a taster, I want to record coffee notes so that I can review them later.
- Task: Create `pc_tastingnote` table
- Task: Add columns (origin, process, rating, etc.)
- Task: Create main form and views

### Feature 2.2: Roastery reference
**User story:** As an admin, I want to track roasteries so that I can standardize data.
- Task: Create `pc_roastery` table
- Task: Add lookup to tasting notes

## Epic 3: Canvas app (Taster)
**Goal:** Fast note capture UI.

### Feature 3.1: Home & list
**User story:** As a taster, I want to see recent notes so that I can quickly revisit them.
- Task: Home screen with list + filters

### Feature 3.2: Create note
**User story:** As a taster, I want to add a new note so that I can capture a tasting.
- Task: New note screen
- Task: Save/validation

## Epic 4: Model-driven app (Admin)
**Goal:** Admin management UI.

### Feature 4.1: App shell
**User story:** As an admin, I want a model-driven app so that I can manage notes and metadata.
- Task: Create model-driven app in solution
- Task: Add tables, views, and charts

## Epic 5: Quality & governance
**Goal:** Best-practice checks.

### Feature 5.1: Solution checker
**User story:** As a release manager, I want solution checker results so that I can enforce quality.
- Task: Run `pac solution check`
- Task: Record findings
