import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Focus Store - Unlock premium features using earned coins
class FocusStoreScreen extends StatefulWidget {
  const FocusStoreScreen({super.key});

  @override
  State<FocusStoreScreen> createState() => _FocusStoreScreenState();
}

class _FocusStoreScreenState extends State<FocusStoreScreen> {
  late Future<Set<String>> _unlockedItemsFuture;

  @override
  void initState() {
    super.initState();
    _unlockedItemsFuture = _loadUnlockedItems();
  }

  Future<Set<String>> _loadUnlockedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getStringList('unlocked_store_items') ?? [];
    return unlocked.toSet();
  }

  Future<void> _saveUnlockedItems(Set<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlocked_store_items', items.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: FutureBuilder<Set<String>>(
        future: _unlockedItemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final unlockedItems = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // Modern SliverAppBar with coin balance
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.amber.shade600,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                            : [Colors.amber.shade400, Colors.orange.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Consumer<SettingsProvider>(
                        builder: (context, settings, _) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('🪙', style: TextStyle(fontSize: 28)),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${settings.totalCoins}',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'coins available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  title: const Text('Focus Store'),
                  centerTitle: true,
                ),
              ),

              // Earning hint
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Earn 1 coin for every minute of focused work!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Store Items
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildCategoryHeader(context, '🎵 Sounds & Ambience'),
                    _buildStoreItem(context, id: 'thunderstorm_sound', icon: '⛈️', title: 'Thunderstorm Ambience', description: 'Powerful storms to boost focus', cost: 500, unlockedItems: unlockedItems, isDark: isDark),
                    _buildStoreItem(context, id: 'cafe_sound', icon: '☕', title: 'Premium Café Sounds', description: 'High-quality café ambience', cost: 300, unlockedItems: unlockedItems, isDark: isDark),
                    _buildStoreItem(context, id: 'nature_sounds', icon: '🌳', title: 'Nature Sound Pack', description: 'Forest, birds, and streams', cost: 400, unlockedItems: unlockedItems, isDark: isDark),
                    const SizedBox(height: 8),
                    _buildCategoryHeader(context, '🎨 Visual Themes'),
                    _buildStoreItem(context, id: 'dark_share_card', icon: '🌑', title: 'Dark Share Card Theme', description: 'Sleek dark gradient for sharing', cost: 250, unlockedItems: unlockedItems, isDark: isDark),
                    _buildStoreItem(context, id: 'neon_theme', icon: '🌈', title: 'Neon Timer Theme', description: 'Vibrant neon colors', cost: 600, unlockedItems: unlockedItems, isDark: isDark),
                    const SizedBox(height: 8),
                    _buildCategoryHeader(context, '⚡ Power-ups'),
                    _buildStoreItem(context, id: 'extended_breaks', icon: '⏰', title: 'Extended Break Mode', description: 'Add +5 minutes to any break', cost: 350, unlockedItems: unlockedItems, isDark: isDark),
                    _buildStoreItem(context, id: 'custom_timer', icon: '⚙️', title: 'Custom Timer Presets', description: 'Save unlimited custom timers', cost: 450, unlockedItems: unlockedItems, isDark: isDark),
                    _buildStoreItem(context, id: 'streak_freeze', icon: '❄️', title: 'Streak Freeze (3-pack)', description: 'Protect your streak for 3 days', cost: 800, unlockedItems: unlockedItems, isDark: isDark),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStoreItem(
    BuildContext context, {
    required String id,
    required String icon,
    required String title,
    required String description,
    required int cost,
    required Set<String> unlockedItems,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final isUnlocked = unlockedItems.contains(id);

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final canAfford = settings.totalCoins >= cost;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isUnlocked
                ? (isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50)
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: isUnlocked
                ? Border.all(color: Colors.green.withOpacity(0.4), width: 1.5)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? Colors.green.withOpacity(0.2)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isUnlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'OWNED',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (!isUnlocked) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🪙', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$cost',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: canAfford ? Colors.amber.shade700 : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            FilledButton.tonal(
                              onPressed: canAfford ? () => _handlePurchase(context, id, cost, settings) : null,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                canAfford ? 'Unlock' : 'Need more',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    String itemId,
    int cost,
    SettingsProvider settings,
  ) async {
    // Deduct coins
    final success = await settings.spendCoins(cost);
    if (!success) return;

    // Unlock item
    final unlockedItems = await _loadUnlockedItems();
    unlockedItems.add(itemId);
    await _saveUnlockedItems(unlockedItems);

    // Refresh UI
    setState(() {
      _unlockedItemsFuture = _loadUnlockedItems();
    });

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Item unlocked! 🎉'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
