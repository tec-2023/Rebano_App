class AppVersion {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;
  final bool isMandatory;

  const AppVersion({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    this.isMandatory = true,
  });

  bool get hasUpdate {
    final currentParts = currentVersion.split('.').map(int.tryParse).toList();
    final latestParts = latestVersion.split('.').map(int.tryParse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      final cur = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
      final lat = latestParts[i] ?? 0;
      if (lat > cur) return true;
      if (lat < cur) return false;
    }
    return false;
  }
}
