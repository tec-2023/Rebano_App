import 'package:flutter_test/flutter_test.dart';
import 'package:rebano_app/features/auth/domain/entities/app_user.dart';
import 'package:rebano_app/features/auth/domain/entities/user_role.dart';
import 'package:rebano_app/features/ota_updates/domain/entities/app_version.dart';
import 'package:rebano_app/main.dart';

void main() {
  group('Rebaño App Tests', () {
    testWidgets('App starts with SplashScreen and navigates', (WidgetTester tester) async {
      await tester.pumpWidget(const RebanoApp());
      expect(find.text('Rebaño'), findsWidgets);

      // Advance through splash timer and animation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    test('RBAC cumulative roles check', () {
      final user = AppUser(
        id: 'u-test',
        churchId: 'tenant-1',
        name: 'Test Leader & Treasurer',
        email: 'test@rebano.org',
        roles: const [UserRole.cellLeader, UserRole.treasurer, UserRole.member],
        joinedAt: DateTime(2025, 1, 1),
      );

      expect(user.isLeader, isTrue);
      expect(user.isTreasurer, isTrue);
      expect(user.isAdmin, isFalse);
      expect(user.hasAnyRole([UserRole.admin, UserRole.cellLeader]), isTrue);
      expect(user.hasAnyRole([UserRole.admin]), isFalse);
    });

    test('OTA Version comparison check', () {
      const versionOlder = AppVersion(
        currentVersion: '1.0.0',
        latestVersion: '1.2.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'New features',
      );
      expect(versionOlder.hasUpdate, isTrue);

      const versionUpToDate = AppVersion(
        currentVersion: '1.2.0',
        latestVersion: '1.2.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'Up to date',
      );
      expect(versionUpToDate.hasUpdate, isFalse);
    });
  });
}
