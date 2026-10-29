# Spec Delta

## Purpose

Defines the complete Phase 1 memory-crafting lifecycle from media selection through draft recovery, publication, later revision, and recoverable deletion.

## ADDED Requirements

### Requirement: Memory creation follows a four-step craft flow
The system SHALL guide an authorized user through media, decoration, story details, and publish review while retaining entered values between steps.

#### Scenario: Navigate between steps
- **WHEN** the user moves forward or backward in the creation flow
- **THEN** previously entered valid media, decoration, metadata, and privacy values remain available

### Requirement: Memory media limits are enforced
The system SHALL accept images and video with a maximum of three images and one video per memory, and MUST require at least one valid media item before publication.

#### Scenario: Valid mixed media
- **WHEN** the user selects up to three supported images and one supported video
- **THEN** the system accepts the selection and generates upload/preview states

#### Scenario: Selection exceeds a limit
- **WHEN** the user attempts to add media beyond either limit
- **THEN** the system rejects the excess item and explains the applicable limit

#### Scenario: Publish without media
- **WHEN** a memory has no valid media
- **THEN** the system disables publication while still allowing draft saving

### Requirement: Media can be arranged and framed
The system SHALL let the author reorder media, choose a cover, crop images, and adjust zoom or position within a selected layout.

#### Scenario: Change cover and order
- **WHEN** the author selects a different cover or reorders media
- **THEN** previews and saved presentation metadata reflect the new arrangement

#### Scenario: Change template
- **WHEN** the author changes template
- **THEN** the system preserves compatible crop and position data and clearly resets only incompatible adjustments

### Requirement: Memory metadata supports journal storytelling
The system SHALL support a memory date, optional title, caption, mood, location, occasion, decoration choices, and privacy value.

#### Scenario: Default memory date
- **WHEN** a new memory begins
- **THEN** its memory date defaults to the current local date and remains editable

#### Scenario: Past memory date
- **WHEN** the author chooses a valid past date
- **THEN** the system saves that date as the timeline-ordering date

### Requirement: A default presentation is always available
The system MUST provide a valid default theme, template, and layout so a memory can be published without manual decoration choices.

#### Scenario: Skip manual decoration
- **WHEN** the author continues without changing decoration
- **THEN** the publish preview uses the default presentation and remains valid

### Requirement: Drafts can be saved and recovered
The system SHALL provide an explicit Save Draft action and MUST retain recoverable draft content across app restarts and transient network failure.

#### Scenario: Save draft online
- **WHEN** the author saves a valid or incomplete draft while online
- **THEN** the system persists its current content and marks it as a draft

#### Scenario: Save draft offline
- **WHEN** remote persistence is unavailable
- **THEN** the system keeps a local recoverable draft, displays pending-sync state, and retries without duplicating the memory

#### Scenario: Leave with unsaved changes
- **WHEN** the author attempts to exit with unsaved changes
- **THEN** the system offers Save Draft, Discard, and Cancel choices

### Requirement: Publishing creates a stable visible version
The system SHALL publish a memory only after required validation and SHALL preserve one stable published version for timeline readers.

#### Scenario: Successful publication
- **WHEN** an authorized author confirms a valid publish review
- **THEN** the system stores the published version, uploads required media, and exposes the memory on authorized timelines

#### Scenario: Upload or publish failure
- **WHEN** a required upload or publish operation fails
- **THEN** the system keeps the draft recoverable, identifies failed items, and offers retry without duplicate publication

### Requirement: Published memories use edit drafts
The system SHALL keep published content visible while an authorized author edits a separate working version until Publish Changes succeeds.

#### Scenario: Begin editing a published memory
- **WHEN** an authorized author edits a published memory
- **THEN** the system creates or resumes an edit draft without changing the current published version

#### Scenario: Publish edited version
- **WHEN** the author confirms valid changes
- **THEN** the system atomically replaces the visible published version and clears edit-draft state

### Requirement: Memory deletion is recoverable
The system SHALL soft-delete a memory for seven days and provide immediate undo plus restoration from Recently Deleted.

#### Scenario: Delete memory
- **WHEN** an authorized user confirms deletion
- **THEN** the memory leaves active timelines, enters Recently Deleted, and shows an Undo action

#### Scenario: Restore memory
- **WHEN** an authorized user restores the memory before expiration
- **THEN** its last valid lifecycle state and timeline relationships are restored

### Requirement: First-memory deletion has additional warning
The system MUST distinguish the onboarding milestone and warn before its deletion without making it undeletable.

#### Scenario: Delete first-memory milestone
- **WHEN** the owner requests deletion of the first-memory milestone
- **THEN** the system shows milestone-specific consequences before allowing confirmation
