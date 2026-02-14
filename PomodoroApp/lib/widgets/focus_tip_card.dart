import 'package:flutter/material.dart';
import '../services/focus_tips_service.dart';

class FocusTipCard extends StatefulWidget {
  final String? category; // 'study', 'work', 'health', 'productivity', or null for random

  const FocusTipCard({
    super.key,
    this.category,
  });

  @override
  State<FocusTipCard> createState() => _FocusTipCardState();
}

class _FocusTipCardState extends State<FocusTipCard> {
  late FocusTip _currentTip;

  @override
  void initState() {
    super.initState();
    _refreshTip();
  }

  void _refreshTip() {
    setState(() {
      switch (widget.category) {
        case 'study':
          _currentTip = FocusTipsService.getRandomStudyTip();
          break;
        case 'work':
          _currentTip = FocusTipsService.getRandomWorkTip();
          break;
        case 'health':
          _currentTip = FocusTipsService.getRandomHealthTip();
          break;
        case 'productivity':
          _currentTip = FocusTipsService.getRandomProductivityTip();
          break;
        default:
          _currentTip = FocusTipsService.getRandomTip();
      }
    });
  }

  Color _getCategoryColor() {
    switch (_currentTip.category) {
      case 'study':
        return Colors.blue;
      case 'work':
        return Colors.orange;
      case 'health':
        return Colors.green;
      case 'productivity':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel() {
    switch (_currentTip.category) {
      case 'study':
        return '📚 Study Tip';
      case 'work':
        return '💼 Work Tip';
      case 'health':
        return '💪 Health Tip';
      case 'productivity':
        return '🚀 Productivity Tip';
      default:
        return '💡 Tip';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              categoryColor.withOpacity(0.1),
              categoryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryLabel(),
                      style: TextStyle(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: categoryColor, size: 20),
                    onPressed: _refreshTip,
                    tooltip: 'New tip',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentTip.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentTip.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentTip.content,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
