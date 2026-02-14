import 'package:flutter/material.dart';

class HydrationTracker extends StatefulWidget {
  final int targetGlasses;

  const HydrationTracker({
    super.key,
    this.targetGlasses = 8,
  });

  @override
  State<HydrationTracker> createState() => _HydrationTrackerState();
}

class _HydrationTrackerState extends State<HydrationTracker> {
  int _glassesConsumed = 0;

  void _addGlass() {
    if (_glassesConsumed < widget.targetGlasses) {
      setState(() {
        _glassesConsumed++;
      });
    }
  }

  void _removeGlass() {
    if (_glassesConsumed > 0) {
      setState(() {
        _glassesConsumed--;
      });
    }
  }

  void _resetGlasses() {
    setState(() {
      _glassesConsumed = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _glassesConsumed / widget.targetGlasses;
    final isComplete = _glassesConsumed >= widget.targetGlasses;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '💧',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hydration',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.cyan, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Complete!',
                          style: TextStyle(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Glass icons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(widget.targetGlasses, (index) {
                final isFilled = index < _glassesConsumed;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isFilled && index == _glassesConsumed - 1) {
                        _glassesConsumed = index;
                      } else if (!isFilled) {
                        _glassesConsumed = index + 1;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isFilled ? Icons.water_drop : Icons.water_drop_outlined,
                      color: isFilled ? Colors.cyan : Colors.grey.shade400,
                      size: 28,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.cyan.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_glassesConsumed / ${widget.targetGlasses} glasses',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: _glassesConsumed > 0 ? _removeGlass : null,
                      visualDensity: VisualDensity.compact,
                      color: Colors.cyan,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 20),
                      onPressed: _glassesConsumed < widget.targetGlasses ? _addGlass : null,
                      visualDensity: VisualDensity.compact,
                      color: Colors.cyan,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _resetGlasses,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Reset',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
