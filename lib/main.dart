import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/tenant/presentation/providers/tenant_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/prayer_network/presentation/providers/prayer_provider.dart';
import 'features/cells_evangelism/presentation/providers/cell_provider.dart';
import 'features/treasury/presentation/providers/treasury_provider.dart';
import 'features/ota_updates/presentation/screens/splash_screen.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuración de la barra del sistema Android para que se integre perfectamente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SupabaseConfig.initialize();
  runApp(const RebanoApp());
}

class RebanoApp extends StatelessWidget {
  const RebanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TenantProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => CellProvider()),
        ChangeNotifierProvider(create: (_) => TreasuryProvider()),
      ],
      child: Consumer<TenantProvider>(
        builder: (context, tenant, _) {
          return MaterialApp(
            title: 'Rebaño',
            debugShowCheckedModeBanner: false,
            // El tema reacciona en tiempo real a la personalización de Marca Blanca del Tenant
            theme: AppTheme.getTheme(
              primaryColor: tenant.primaryColor,
              isDarkMode: false,
            ),
            darkTheme: AppTheme.getTheme(
              primaryColor: tenant.primaryColor,
              isDarkMode: true,
            ),
            themeMode: ThemeMode.system,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
