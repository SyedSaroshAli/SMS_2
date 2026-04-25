import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/NoticesScreen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/aboutScreen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/admitcardScreen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/attendance_screen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/compositeMarksheetScreen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/notesScreen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/profile_screen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/singleMarksheetScreen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/student_fee_screen.dart';
import 'package:school_management_system/dashboard/sections/dashboard_cards_row/dashboard_cards_row.dart';
import 'package:school_management_system/dashboard/sections/noticesSection.dart';
import 'package:school_management_system/dashboard/sections/userIDSection.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:school_management_system/services/auth_service.dart';
import 'package:school_management_system/utils/app_footer.dart';
import '../../controllers/theme_controller.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  Future<Map<String, dynamic>> _loadUserData() async {
    final auth = AuthService();
    final name = await auth.getStudentName() ?? 'Student';
    final id = await auth.getStudentId() ?? '';
    final permissions = await auth.getPermissions();
    return {'name': name, 'id': id, 'permissions': permissions};
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final ThemeController themeController = Get.find<ThemeController>();

    // Get screen dimensions for responsive scaling
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;
    final bool isDesktop = size.width > 1024;

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadUserData(),
      builder: (context, snapshot) {
        final studentName = snapshot.data?['name'] ?? 'Student';
        final studentId = snapshot.data?['id'] ?? '';
        final List<String> permissions = snapshot.data?['permissions'] ?? [];
        final studentEmail = studentId.isNotEmpty
            ? 'Student ID: $studentId'
            : '';

        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
            title: const Text('Student Dashboard'),
            actions: [
              Obx(
                () => IconButton(
                  onPressed: () => themeController.toggleTheme(),
                  icon: Icon(
                    themeController.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  tooltip: themeController.isDarkMode
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                ),
              ),
              TextButton(
                onPressed: () async {
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SigninScreen(),
                      ),
                    );
                  }
                },
                child: Text(
                  "Sign out",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 8),
            ],
          ),
          // Responsive Drawer Width
          drawer: SizedBox(
            width: size.width * 0.8 > 350 ? 350 : size.width * 0.8,
            child: Drawer(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: isTablet ? 40 : 30,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          child: Text(
                            studentName.isNotEmpty
                                ? studentName[0].toUpperCase()
                                : "S",
                            style: TextStyle(
                              fontSize: isTablet ? 32 : 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          child: Text(
                            studentName,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 22 : 18,
                                ),
                          ),
                        ),
                        Text(
                          studentEmail,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DrawerItem(
                    icon: LucideIcons.user,
                    title: "Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  if (permissions.contains('HRMS.SelfViewAttendance') ||
                      permissions.contains('HRMS.ViewAttendance'))
                    _DrawerItem(
                      icon: LucideIcons.checkCircle,
                      title: "Attendance",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AttendanceScreen(),
                          ),
                        );
                      },
                    ),
                  if (permissions.any(
                    (p) => p.startsWith('Report') || p.startsWith('Student'),
                  ))
                    _DrawerItem(
                      icon: LucideIcons.bookOpen,
                      title: "Marksheet",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MarksheetScreen(),
                          ),
                        );
                      },
                    ),
                  if (permissions.any(
                    (p) => p.startsWith('Report') || p.startsWith('Student'),
                  ))
                    _DrawerItem(
                      icon: LucideIcons.table,
                      title: "Composite Marksheet",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompositeMarksheetScreen(),
                          ),
                        );
                      },
                    ),
                  if (permissions.any(
                    (p) =>
                        p.startsWith('Student.Fee') || p.startsWith('Finance'),
                  ))
                    _DrawerItem(
                      icon: LucideIcons.wallet,
                      title: "Fee Details",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentFeeScreen(),
                          ),
                        );
                      },
                    ),
                  _DrawerItem(
                    icon: LucideIcons.bell,
                    title: "Notices",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoticesScreen(),
                        ),
                      );
                    },
                  ),
                  if (permissions.contains('Report.AdmitCard'))
                    _DrawerItem(
                      icon: LucideIcons.contact,
                      title: "Admit Card",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdmitCardScreen(),
                          ),
                        );
                      },
                    ),
                  _DrawerItem(
                    icon: LucideIcons.book,
                    title: "Notes",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=>NotesScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: LucideIcons.home,
                    title: "About",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    // Ensures content doesn't get too wide on Desktop/Tablets
                    constraints: BoxConstraints(
                      maxWidth: isDesktop
                          ? 1200
                          : (isTablet ? 800 : double.infinity),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32.0 : 16.0,
                          vertical: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const UserIDSection(),
                            const SizedBox(height: 24),
                            const NoticesSection(),
                            const SizedBox(height: 24),
                            // DashboardCardsRow should handle its own internal responsiveness
                            // (e.g., using Wrap or GridView inside)
                            DashboardCardsRow(permissions: permissions),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: const AppFooter(),
        );
      },
    );
  }
}

/// Extracted reusable drawer item widget
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}
