import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        Color backgroundColor;
        Color textColor;

        // Special colors for Flow Mode
        if (timer.state == TimerState.flow) {
          backgroundColor = Colors.purple.withOpacity(0.15);
          textColor = Colors.purple;
        } else {
          switch (timer.currentType) {
            case AppConstants.stateWork:
              backgroundColor = AppConstants.primaryRed.withOpacity(0.1);
              textColor = AppConstants.primaryRed;
              break;
            case AppConstants.stateShortBreak:
              backgroundColor = AppConstants.primaryGreen.withOpacity(0.1);
              textColor = AppConstants.primaryGreen;
              break;
            case AppConstants.stateLongBreak:
              backgroundColor = AppConstants.primaryBlue.withOpacity(0.1);
              textColor = AppConstants.primaryBlue;
              break;
            default:
              backgroundColor = Colors.grey.withOpacity(0.1);
              textColor = Colors.grey;
          }
        }

        return Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 280,
                height: 280,
                child: CircularProgressIndicator(
                  value: timer.progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      timer.timeDisplay,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      timer.state == TimerState.running
                          ? AppLocalizations.of(context).running
                          : timer.state == TimerState.paused
                              ? AppLocalizations.of(context).paused
                              : timer.state == TimerState.flow
                                  ? '✨ Flow Mode'
                                  : AppLocalizations.of(context).ready,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: timer.state == TimerState.flow
                            ? Colors.purple
                            : textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
