# Spec Delta

## Purpose

Defines how verified users create and manage multiple pet journals through an emotional onboarding flow while preserving ownership and lifecycle rules.

## ADDED Requirements

### Requirement: First-time users complete pet onboarding
The system SHALL route a verified user with no active pet profile through welcome, pet information, photo, and confirmation steps before Home.

#### Scenario: First authenticated launch
- **WHEN** a verified user has no active pet profile
- **THEN** the system starts the onboarding welcome step

#### Scenario: Interrupted onboarding
- **WHEN** the user leaves before confirming pet creation
- **THEN** the system preserves recoverable onboarding input and does not create a partial pet profile

### Requirement: Pet profile captures required and optional identity
The system SHALL require a pet name and pet type, and SHALL allow an optional profile image, birthday, and first-met or adoption date.

#### Scenario: Valid profile information
- **WHEN** the user provides a name and supported pet type with any valid optional fields
- **THEN** the system allows progression to confirmation

#### Scenario: Other pet type
- **WHEN** the user selects Other
- **THEN** the system requires a custom type label and uses a neutral placeholder when no photo exists

#### Scenario: Invalid dates
- **WHEN** an entered birthday or first-met date is in the future
- **THEN** the system prevents confirmation and explains the invalid field

### Requirement: Profile creation is confirmed atomically
The system MUST create the pet profile, owner membership, and first-memory milestone as one recoverable operation.

#### Scenario: Successful confirmation
- **WHEN** the user confirms a valid onboarding summary
- **THEN** the system creates the pet, assigns the current user as owner, creates the editable first-memory milestone, and opens the journal

#### Scenario: Creation fails
- **WHEN** any required part of profile creation fails
- **THEN** the system does not leave an ownerless or partially initialized pet and offers a safe retry

### Requirement: Users can own multiple pets
The system SHALL allow a user to create and switch between multiple active pet profiles without mixing their timelines.

#### Scenario: Add another pet
- **WHEN** an authenticated owner completes onboarding for another pet
- **THEN** Home shows the additional pet card and each card opens its own timeline

### Requirement: Owner can edit allowed profile fields
The system SHALL allow the owner to change the pet name and profile image while retaining stable pet identity and type.

#### Scenario: Update name or image
- **WHEN** the owner saves a valid name or profile-image change
- **THEN** the updated profile appears consistently on Home and Timeline

#### Scenario: Attempt to change pet type
- **WHEN** the owner views profile editing in Phase 1
- **THEN** pet type is displayed as read-only

### Requirement: Pet deletion is recoverable for seven days
The system SHALL soft-delete a pet profile and its journal visibility for seven days before permanent deletion is eligible.

#### Scenario: Owner deletes a pet
- **WHEN** the owner confirms pet deletion
- **THEN** the pet disappears from active Home and appears in Recently Deleted with its remaining recovery period

#### Scenario: Owner restores a pet
- **WHEN** the owner restores the pet before the recovery period ends
- **THEN** the pet and its non-expired journal relationships return to their prior active state
