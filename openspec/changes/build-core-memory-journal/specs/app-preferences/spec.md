# Spec Delta

## Purpose

Defines Phase 1 account and application preferences so Pawlum presents a consistent Thai or English experience and retains user choices across sessions.

## ADDED Requirements

### Requirement: App supports Thai and English
The system SHALL provide Thai and English UI text for Phase 1 screens, validation, errors, empty states, and emotional copy.

#### Scenario: First launch language
- **WHEN** a user has no saved language preference
- **THEN** the system selects Thai or English from the supported device locale and falls back to Thai when unsupported

#### Scenario: Change language
- **WHEN** the user selects the other supported language
- **THEN** visible application text updates without requiring account recreation or data changes

### Requirement: Language preference persists
The system SHALL persist language choice locally for startup and remotely for the authenticated user's cross-device preference.

#### Scenario: Relaunch app
- **WHEN** the app relaunches after the user changed language
- **THEN** the saved language is applied before normal content is presented

#### Scenario: Sign in on another device
- **WHEN** an authenticated user has a remote language preference
- **THEN** the app applies that preference after account state loads

### Requirement: User can view basic account information
The system SHALL show the authenticated email, display name when available, authentication methods, and verification state without exposing secret credentials.

#### Scenario: Open account settings
- **WHEN** an authenticated user opens Settings
- **THEN** the system displays current non-secret account information and available account actions

### Requirement: Password actions match account methods
The system SHALL show change-password behavior only when the account has an email/password authentication method and SHALL expose password recovery when reauthentication is needed.

#### Scenario: Google-only account
- **WHEN** a Google-only user opens account settings
- **THEN** the system does not offer an inapplicable current-password change form

### Requirement: Sign-out preserves only safe local state
The system SHALL end the active session, remove cached private read data, and preserve explicitly recoverable unsynced drafts in a protected account-scoped form.

#### Scenario: Sign out with no pending work
- **WHEN** the user signs out and no local work is pending
- **THEN** private cached journal content is removed and account access is shown

#### Scenario: Sign out with pending draft
- **WHEN** the user attempts to sign out with unsynced work
- **THEN** the system warns about pending state and requires an explicit choice before completing sign-out

### Requirement: Deferred settings are not presented as functional
The system MUST not present notification, shared-link, recap-privacy, account deletion, or support controls as working Phase 1 actions before their capabilities exist.

#### Scenario: Open Phase 1 settings
- **WHEN** the user views Settings
- **THEN** only implemented controls are interactive and deferred items are omitted or clearly labeled unavailable
