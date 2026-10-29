# Spec Delta

## Purpose

Defines how users move among pet journals and revisit memories through responsive, chronological scrapbook timelines without leaking private working versions.

## ADDED Requirements

### Requirement: Home presents active pet journals
The system SHALL show one card per active pet profile and provide direct entry to its timeline and memory-creation flow.

#### Scenario: Multiple active pets
- **WHEN** an owner opens Home with multiple active pets
- **THEN** each pet appears as a distinct card with its current name, profile image or placeholder, and journal summary

#### Scenario: Select a pet
- **WHEN** the user selects a pet card
- **THEN** the system opens that pet's timeline without mixing memories from unselected pets

### Requirement: Timeline orders by memory date
The system SHALL order active memories by `memory_date`, newest first by default, and group them by year and month.

#### Scenario: View chronological journal
- **WHEN** a timeline contains memories across multiple dates
- **THEN** the memories appear newest first under the correct year and month groups

#### Scenario: Change memory date
- **WHEN** an authorized author publishes a different memory date
- **THEN** the memory moves to its new chronological position

### Requirement: Portrait and landscape timelines are supported
The system SHALL provide a vertically scrolling portrait timeline and a horizontally scrolling landscape timeline with equivalent memory access.

#### Scenario: Rotate to landscape
- **WHEN** the device enters supported landscape orientation on Timeline
- **THEN** the system presents the horizontal timeline while retaining the selected pet and scroll context when practical

#### Scenario: Return to portrait
- **WHEN** the device returns to portrait orientation
- **THEN** the system restores the vertical timeline for the same pet

### Requirement: Timeline distinguishes working states
The system SHALL visually distinguish drafts and pending edit drafts from published memories without relying on color alone.

#### Scenario: Owner views a draft
- **WHEN** an owner or draft author views a timeline containing their draft
- **THEN** the draft is visibly labeled and can be resumed

#### Scenario: Published memory has edit draft
- **WHEN** a published memory also has an edit draft
- **THEN** the timeline shows the published version with an accessible pending-edit indicator

### Requirement: Working versions remain private
The system MUST restrict drafts to the owner and their author, and MUST never substitute an edit draft for the current published version in normal timeline reading.

#### Scenario: Unauthorized draft lookup
- **WHEN** a user without draft access requests timeline data
- **THEN** the draft is absent from the response and no private metadata is exposed

### Requirement: Memory detail reflects the selected version
The system SHALL open published memory details from timeline cards and SHALL open the authoring flow when the user chooses to resume a draft.

#### Scenario: Open published memory
- **WHEN** the user selects a published timeline card
- **THEN** the detail view shows its media, story, date, mood, location, and presentation

#### Scenario: Resume draft
- **WHEN** an authorized user selects a draft card
- **THEN** the system restores the draft into the correct authoring step with saved values

### Requirement: Deleted content is excluded
The system MUST exclude soft-deleted pets and memories from active Home, Timeline, and memory-detail entry points.

#### Scenario: Soft-deleted memory route
- **WHEN** an active-journal route targets a soft-deleted memory
- **THEN** the system does not render the memory and offers a safe return path

### Requirement: Timeline remains usable during loading and failure
The system SHALL provide skeleton/loading, empty, retryable error, and media-error states without discarding already loaded journal content.

#### Scenario: Initial empty timeline
- **WHEN** a pet has no active memories after initialization
- **THEN** the system shows an emotional empty state with an Add Memory action

#### Scenario: Additional page fails
- **WHEN** lazy loading more timeline content fails
- **THEN** existing memories remain visible and the failed page can be retried
