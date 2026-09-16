import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebano_app/core/theme/app_colors.dart';
import 'package:rebano_app/features/auth/domain/entities/app_user.dart';
import 'package:rebano_app/features/auth/domain/entities/user_role.dart';
import 'package:rebano_app/features/ota_updates/domain/entities/app_version.dart';
import 'package:rebano_app/features/prayer_network/domain/entities/prayer_request.dart';
import 'package:rebano_app/features/treasury/domain/entities/financial_transaction.dart';
import 'package:rebano_app/features/tenant/domain/entities/church_tenant.dart';
import 'package:rebano_app/features/tenant/data/repositories/supabase_tenant_repository.dart';
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

    test('Hex color parser converts properly between String and Color', () {
      const hex = '#1E5BB8';
      final color = AppColors.fromHex(hex);
      expect(color.toARGB32(), equals(const Color(0xFF1E5BB8).toARGB32()));

      final backToHex = AppColors.toHex(color);
      expect(backToHex, equals('#1E5BB8'));

      // Test without hash
      final colorWithoutHash = AppColors.fromHex('8B1E3F');
      expect(colorWithoutHash.toARGB32(), equals(const Color(0xFF8B1E3F).toARGB32()));

      // Test fallback on invalid hex
      final fallback = AppColors.fromHex('invalid', fallback: Colors.green);
      expect(fallback, equals(Colors.green));
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

    test('Restricted operations include required churchId payload', () {
      final prayer = PrayerRequest(
        id: 'p-1',
        churchId: 'tenant-1',
        authorName: 'Hna. Rosa',
        title: 'Oración por salud',
        description: 'Petición familiar',
        category: PrayerCategory.health,
        createdAt: DateTime.now(),
      );
      expect(prayer.churchId, equals('tenant-1'));

      final tx = FinancialTransaction(
        id: 'tx-1',
        churchId: 'tenant-1',
        type: TransactionType.income,
        category: 'Diezmos',
        amount: 5000.0,
        date: DateTime.now(),
        description: 'Ofrenda',
        registeredBy: 'Tesorero',
      );
      expect(tx.churchId, equals('tenant-1'));
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

    test('Church access code generates initials + DDMMYY date format', () {
      final code = SupabaseTenantRepository.generateChurchCode(
        'Iglesia Bautista fundamental independiente El Alfarero',
        DateTime(2026, 9, 15),
      );
      expect(code, equals('IBFIEA-150926'));
    });

    test('ChurchTenant supports both full official name and short name', () {
      final church = ChurchTenant(
        id: 't-test',
        name: 'Iglesia Bautista Fundamental Independiente El Alfarero',
        shortName: 'El Alfarero',
        code: 'IBFIEA-150926',
        pastorName: 'Pastor David Morales',
        email: 'pastor@elalfarero.org',
        primaryColor: const Color(0xFF1E5BB8),
        createdAt: DateTime(2025, 1, 1),
      );
      expect(church.name, equals('Iglesia Bautista Fundamental Independiente El Alfarero'));
      expect(church.shortName, equals('El Alfarero'));
      expect(church.displayName, equals('El Alfarero'));

      // When short name is empty, fallback to full name
      final churchFallback = church.copyWith(shortName: '');
      expect(churchFallback.displayName, equals('Iglesia Bautista Fundamental Independiente El Alfarero'));
    });
  });
}
