import 'package:flutter/material.dart';

/// A responsive layout widget that adapts between mobile and desktop views.
///
/// Uses a breakpoint of 600px to determine which layout to show:
/// - Width < 600px: Mobile layout (single column)
/// - Width >= 600px: Desktop layout (multi-column with NavigationRail)
class ResponsiveLayout extends StatelessWidget {
  /// The widget to display on mobile devices (< 600px width)
  final Widget mobileBody;

  /// The widget to display on desktop devices (>= 600px width)
  final Widget? desktopBody;

  /// Breakpoint width for switching between mobile and desktop
  final double breakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.desktopBody,
    this.breakpoint = 600,
  });

  /// Check if the current screen width is considered mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Check if the current screen width is considered desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Check if the current screen width is considered tablet (600-900px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  /// Check if the current screen width is considered large desktop (>= 1200px)
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint && desktopBody != null) {
          return desktopBody!;
        }
        return mobileBody;
      },
    );
  }
}

/// A scaffold wrapper that provides desktop-aware navigation
class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final int selectedNavIndex;
  final Function(int)? onNavTap;
  final List<NavigationRailDestination>? navDestinations;
  final Widget? leading;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.selectedNavIndex = 0,
    this.onNavTap,
    this.navDestinations,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;

        if (isDesktop && navDestinations != null && navDestinations!.isNotEmpty) {
          return _buildDesktopScaffold(context);
        }
        return _buildMobileScaffold(context);
      },
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: leading,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopScaffold(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail for desktop
          NavigationRail(
            selectedIndex: selectedNavIndex,
            onDestinationSelected: onNavTap,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pomodoro',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            destinations: navDestinations!,
          ),
          // Vertical divider
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: theme.dividerColor.withOpacity(0.3),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // App bar equivalent for desktop
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
                // Body
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Desktop layout for the home screen with side-by-side panels
class DesktopHomeLayout extends StatelessWidget {
  final Widget timerSection;
  final Widget taskSection;
  final Widget? statsSection;
  final double timerSectionFlex;
  final double contentSectionFlex;

  const DesktopHomeLayout({
    super.key,
    required this.timerSection,
    required this.taskSection,
    this.statsSection,
    this.timerSectionFlex = 1,
    this.contentSectionFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Left side: Timer
        Expanded(
          flex: timerSectionFlex.toInt(),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor.withOpacity(0.2),
                ),
              ),
            ),
            child: timerSection,
          ),
        ),
        // Right side: Tasks + Stats
        Expanded(
          flex: contentSectionFlex.toInt(),
          child: Column(
            children: [
              // Tasks section
              Expanded(
                flex: statsSection != null ? 1 : 2,
                child: taskSection,
              ),
              // Stats section (optional)
              if (statsSection != null) ...[
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),
                Expanded(
                  flex: 1,
                  child: statsSection!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
