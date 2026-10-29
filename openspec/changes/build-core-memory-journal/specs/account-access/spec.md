# Spec Delta

## Purpose

Defines secure account entry and recovery behavior so every journal belongs to a verified, recoverable user identity across supported devices.

## ADDED Requirements

### Requirement: Email registration requires verification
The system SHALL allow registration with email and password and MUST block journal access until the email address is verified.

#### Scenario: New email registration
- **WHEN** a user submits a valid unused email and acceptable password
- **THEN** the system creates a pending account, sends a verification message, and shows a verification-pending screen

#### Scenario: Unverified sign-in
- **WHEN** an unverified email/password user signs in
- **THEN** the system keeps the user outside the journal and offers verification resend and sign-out actions

### Requirement: Verified users can sign in
The system SHALL authenticate verified email/password users and restore their last valid session on later launches.

#### Scenario: Valid credentials
- **WHEN** a verified user submits valid credentials
- **THEN** the system opens onboarding when no pet exists or Home when at least one pet exists

#### Scenario: Invalid credentials
- **WHEN** a user submits invalid credentials
- **THEN** the system remains signed out and shows a localized, non-sensitive error

#### Scenario: Restored session
- **WHEN** the app launches with a valid stored session
- **THEN** the system restores the user without requiring credentials again

### Requirement: Google sign-in is supported
The system SHALL support Google authentication and treat a successfully verified Google identity as email verified.

#### Scenario: First Google sign-in
- **WHEN** a user completes Google authentication for an unused verified email
- **THEN** the system creates one Pawlum account and routes by pet-profile presence

#### Scenario: Matching verified identity
- **WHEN** Google returns an email already belonging to the same verified user identity
- **THEN** the system links or resolves to the existing Pawlum account without creating duplicate journal data

### Requirement: Password recovery is available
The system SHALL let email/password users request password recovery without disclosing whether an address is registered.

#### Scenario: Recovery request
- **WHEN** a user submits an email on the forgot-password screen
- **THEN** the system shows the same confirmation response regardless of account existence

### Requirement: Authentication failures preserve user work
The system MUST keep recoverable local drafts intact when a session expires or a network/authentication request fails.

#### Scenario: Session expires while drafting
- **WHEN** a remote save is rejected because the session expired
- **THEN** the system retains the local draft, requests sign-in, and retries only after authentication succeeds

### Requirement: Guest access is unavailable
The system MUST require an authenticated verified account before creating or reading private Pawlum journal data.

#### Scenario: Signed-out deep entry
- **WHEN** a signed-out user attempts to open a private in-app journal route
- **THEN** the system redirects to account access without exposing journal content
