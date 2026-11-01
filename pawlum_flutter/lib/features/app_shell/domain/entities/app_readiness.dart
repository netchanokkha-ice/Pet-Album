class AppReadiness {
  const AppReadiness({
    required this.isAuthenticated,
    required this.petCount,
    required this.pendingDraftCount,
  });

  final bool isAuthenticated;
  final int petCount;
  final int pendingDraftCount;
}
