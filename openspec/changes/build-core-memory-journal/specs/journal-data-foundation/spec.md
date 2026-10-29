# Spec Delta

## Purpose

Defines the durable data, authorization, versioning, and recovery contracts that secure Phase 1 journals and allow later collaboration and sharing features to extend them safely.

## ADDED Requirements

### Requirement: Journal records use stable identities
The system SHALL assign globally stable identifiers to users, pets, memories, versions, media, memberships, and pet-memory relationships.

#### Scenario: Retry a create operation
- **WHEN** a client retries the same logical create request after an uncertain response
- **THEN** the system resolves to one durable record rather than creating duplicates

### Requirement: Pet access is membership-based
The system SHALL represent pet access through a membership record with a role and status, including an owner membership for every active pet.

#### Scenario: Create pet
- **WHEN** a pet is created successfully
- **THEN** exactly one active owner membership links the current user to that pet

#### Scenario: Non-member access
- **WHEN** an authenticated user requests a pet without an authorized membership
- **THEN** the system denies the request without revealing private pet or memory data

### Requirement: Memories can relate to multiple pets
The system SHALL store pet-memory relationships independently from the memory record while Phase 1 authoring initially targets at least one owner-accessible pet.

#### Scenario: Create memory for one pet
- **WHEN** an author publishes a memory for a selected pet
- **THEN** the system persists the memory and one authorized pet-memory relationship

#### Scenario: Invalid pet relationship
- **WHEN** a user attempts to attach a memory to a pet they cannot manage
- **THEN** the system rejects the relationship and leaves authorized relationships unchanged

### Requirement: Authorship and management authority are distinct
The system SHALL retain the creating user and evaluate current management permission separately so later membership or ownership changes do not rewrite authorship.

#### Scenario: Owner manages another author's memory
- **WHEN** a future authorized owner manages a memory created by another member
- **THEN** the system can authorize the action while preserving original attribution

### Requirement: Published and working versions are distinct
The system SHALL keep a stable published version reference separate from a mutable draft or edit-draft version.

#### Scenario: Save edit draft
- **WHEN** an author saves changes to a published memory without publishing them
- **THEN** readers continue receiving the prior published version

#### Scenario: Promote edit draft
- **WHEN** Publish Changes succeeds
- **THEN** the working version becomes the published version atomically and version history remains internally traceable

### Requirement: Private data is authorized on every data path
The system MUST enforce ownership or membership authorization for database records and media objects regardless of client-supplied identifiers.

#### Scenario: Manipulated record identifier
- **WHEN** a client requests another user's pet, memory, version, or media identifier
- **THEN** the data service denies access even if the identifier is syntactically valid

#### Scenario: Public client credential
- **WHEN** the mobile app accesses the data service with its public application credential and user session
- **THEN** authorization is derived from the verified session and server-side data rules, not mutable client metadata

### Requirement: Media storage follows journal authorization
The system SHALL keep original pet media non-public and grant access only to authorized requests or explicitly created future share contexts.

#### Scenario: Request private media without authorization
- **WHEN** an unauthorized or signed-out caller requests a private media object
- **THEN** the system denies access and does not expose a permanent public URL

### Requirement: Client persistence is replaceable behind stable contracts
The application SHALL expose account, pet, memory, media, and preferences behavior through stable domain contracts independent of a specific remote or local persistence implementation.

#### Scenario: Use test or local data source
- **WHEN** the application is configured with a test or offline data source
- **THEN** feature behavior uses the same domain outcomes and errors expected from the production data source

### Requirement: Pending local work syncs idempotently
The system SHALL identify locally pending drafts and uploads so retries after restart or network loss do not duplicate records or media.

#### Scenario: Restart during upload
- **WHEN** the app restarts after some media uploaded but before publication completes
- **THEN** it reconstructs pending state, reuses completed uploads where valid, and retries only incomplete operations

#### Scenario: Remote conflict
- **WHEN** remote data changed after a local working copy was created
- **THEN** the system preserves both recoverable states and requires an explicit resolution instead of silently overwriting published content

### Requirement: Soft deletion records lifecycle timestamps
The system SHALL distinguish creation, update, memory date, deletion, and deletion-expiry timestamps for recoverable entities.

#### Scenario: Restore before expiry
- **WHEN** an authorized user restores an entity before its deletion-expiry timestamp
- **THEN** the system clears active deletion state without changing its original creation or memory date

#### Scenario: Expired deletion
- **WHEN** the recovery period has elapsed
- **THEN** the entity becomes eligible for permanent purge according to the configured retention process
