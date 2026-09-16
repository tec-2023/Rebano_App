import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_logo.dart';
import '../tenant/presentation/providers/tenant_provider.dart';
import '../auth/domain/entities/user_role.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../auth/presentation/screens/welcome_screen.dart';
import '../prayer_network/presentation/screens/prayer_feed_screen.dart';
import '../cells_evangelism/presentation/screens/cell_overview_screen.dart';
import '../treasury/presentation/screens/treasury_dashboard_screen.dart';
import '../admin/presentation/screens/white_label_settings_screen.dart';
import '../admin/presentation/screens/member_management_screen.dart';
import '../support/presentation/services/support_service.dart';

class NavDestination {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;
  final List<UserRole> requiredRoles;

  const NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
    required this.requiredRoles,
  });
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // Catálogo completo de módulos con sus requerimientos de permisos RBAC
  final List<NavDestination> _allDestinations = [
    const NavDestination(
      label: 'Oración',
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      screen: PrayerFeedScreen(),
      requiredRoles: [UserRole.member], // Acceso para todos
    ),
    const NavDestination(
      label: 'Células',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      screen: CellOverviewScreen(),
      requiredRoles: [UserRole.admin, UserRole.cellLeader], // Admin o Líder
    ),
    const NavDestination(
      label: 'Tesorería',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      screen: TreasuryDashboardScreen(),
      requiredRoles: [UserRole.admin, UserRole.treasurer], // Admin o Tesorero
    ),
    const NavDestination(
      label: 'Admin',
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings_rounded,
      screen: WhiteLabelSettingsScreen(),
      requiredRoles: [UserRole.admin], // Solo Admin
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tenant = context.watch<TenantProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser;

    // Filtramos dinámicamente los módulos a los que el usuario tiene acceso según sus roles acumulativos
    final availableDestinations = _allDestinations.where((dest) {
      if (currentUser == null) return false;
      return currentUser.hasAnyRole(dest.requiredRoles);
    }).toList();

    // Aseguramos que el índice actual no quede fuera de rango al cambiar de rol
    if (_currentIndex >= availableDestinations.length) {
      _currentIndex = 0;
    }

    final currentScreen = availableDestinations.isNotEmpty
        ? availableDestinations[_currentIndex].screen
        : const PrayerFeedScreen();

    return Scaffold(
      drawer: _buildDrawer(context, tenant, auth),
      body: currentScreen,
      bottomNavigationBar: availableDestinations.length > 1
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
              selectedItemColor: tenant.primaryColor,
              items: availableDestinations.map((dest) {
                return BottomNavigationBarItem(
                  icon: Icon(dest.icon),
                  activeIcon: Icon(dest.activeIcon),
                  label: dest.label,
                );
              }).toList(),
            )
          : null,
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    TenantProvider tenant,
    AuthProvider auth,
  ) {
    final user = auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. Header de la Iglesia y Usuario con Logotipo Oficial
          DrawerHeader(
            decoration: BoxDecoration(
              color: tenant.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const AppLogo(
                      size: 48,
                      borderRadius: 12,
                      padding: EdgeInsets.all(4),
                      showShadow: false,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.churchName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Código: ${tenant.churchCode}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      child: Text(
                        (user?.name.isNotEmpty ?? false) ? user!.name[0] : 'U',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: tenant.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user?.name ?? 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Roles Activos del Usuario
          if (user != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TUS ROLES ACTIVOS:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: user.roles.map((r) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: r.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: r.color.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          r.label,
                          style: TextStyle(color: r.color, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          // 3. Sección DEMO: Selector Rápido de Rol
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFB45309)),
                      SizedBox(width: 4),
                      Text(
                        'MODO PRUEBA: CAMBIAR ROL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildRoleSwitchChip(context, auth, 'Admin', UserRole.admin),
                      _buildRoleSwitchChip(context, auth, 'Tesorero', UserRole.treasurer),
                      _buildRoleSwitchChip(context, auth, 'Líder Célula', UserRole.cellLeader),
                      _buildRoleSwitchChip(context, auth, 'Miembro', UserRole.member),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 4. Módulos de Administración (Solo si es Admin)
          if (user?.isAdmin ?? false) ...[
            ListTile(
              leading: const Icon(Icons.palette_outlined, color: Color(0xFF7C3AED)),
              title: const Text('Marca Blanca & Colores'),
              subtitle: const Text('Personalizar identidad visual'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WhiteLabelSettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined, color: Color(0xFF2563EB)),
              title: const Text('Gestión de Usuarios y Roles'),
              subtitle: const Text('Asignar permisos a miembros'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MemberManagementScreen()),
                );
              },
            ),
            const Divider(),
          ],

          // 5. Botón "Apoyar este Ministerio" (WhatsApp)
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_rounded, color: Colors.white, size: 18),
            ),
            title: const Text(
              'Apoyar este Ministerio',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534)),
            ),
            subtitle: const Text('Contáctanos por WhatsApp'),
            onTap: () {
              SupportService.openSupportWhatsApp(
                churchName: tenant.churchName,
                pastorName: tenant.currentTenant.pastorName,
              );
            },
          ),

          // 6. Copiar Código de Iglesia
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Compartir Código de Iglesia'),
            subtitle: Text(tenant.churchCode),
            onTap: () {
              Clipboard.setData(ClipboardData(text: tenant.churchCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Código copiado al portapapeles!'),
                  backgroundColor: Color(0xFF15803D),
                ),
              );
            },
          ),

          const Divider(),

          // 7. Cerrar Sesión
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Color(0xFFDC2626))),
            onTap: () {
              auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSwitchChip(BuildContext context, AuthProvider auth, String label, UserRole role) {
    final isCurrent = auth.hasRole(role) && (role == UserRole.admin ? auth.currentUser?.isAdmin ?? false : true);

    return InkWell(
      onTap: () {
        auth.switchDemoRole(role);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cambiado a perfil: $label (Permisos actualizados)'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrent ? role.color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: role.color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isCurrent ? Colors.white : role.color,
          ),
        ),
      ),
    );
  }
}
