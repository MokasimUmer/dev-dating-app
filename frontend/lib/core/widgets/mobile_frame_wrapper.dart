import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/terminal_theme.dart';

/// Wraps the app in a mobile phone frame when running on web or wide screens.
/// On actual mobile devices, the child renders full-screen as normal.
class MobileFrameWrapper extends StatelessWidget {
  const MobileFrameWrapper({super.key, required this.child});

  final Widget child;

  /// Max width for the "phone" content area.
  static const double _phoneWidth = 400;

  /// Border radius of the phone frame.
  static const double _frameRadius = 44;

  /// Whether we should show the phone frame.
  bool _shouldShowFrame(BoxConstraints constraints) {
    // Show frame on web or when the viewport is wide enough
    return kIsWeb && constraints.maxWidth > _phoneWidth + 80;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_shouldShowFrame(constraints)) {
          // On mobile / narrow viewport — render normally
          return child;
        }

        // Calculate phone height dynamically based on available space.
        // Reserve space for: title row (40) + bottom hint (28) + padding (32)
        final availableHeight = constraints.maxHeight - 100;
        // Clamp between a reasonable min and the ideal max
        final phoneHeight = availableHeight.clamp(400.0, 860.0);

        // On web / wide screen — wrap in a phone frame
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            // Warm romantic gradient background behind the phone
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0E060A),
                Color(0xFF1A0A12),
                Color(0xFF0E060A),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── App Title above phone ───────────────────
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: TerminalColors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'DevDate',
                              style: TextStyle(
                                fontFamily: 'Fira Code',
                                color: TerminalColors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '— Valentine\'s Edition',
                              style: TextStyle(
                                fontFamily: 'Fira Code',
                                color: TerminalColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Phone Frame ─────────────────────────────
                      Container(
                        width: _phoneWidth + 16, // +16 for frame padding
                        height: phoneHeight,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(_frameRadius + 4),
                          // Outer glow
                          boxShadow: [
                            BoxShadow(
                              color: TerminalColors.green
                                  .withValues(alpha: 0.08),
                              blurRadius: 40,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                          // Frame border
                          border: Border.all(
                            color: TerminalColors.dimGreen
                                .withValues(alpha: 0.3),
                            width: 2,
                          ),
                          color: const Color(0xFF1A0A12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            children: [
                              // ── Status Bar (notch area) ──────────
                              Container(
                                width: double.infinity,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: TerminalColors.background,
                                  borderRadius: BorderRadius.only(
                                    topLeft:
                                        Radius.circular(_frameRadius - 6),
                                    topRight:
                                        Radius.circular(_frameRadius - 6),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 120,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A0A12),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: TerminalColors.surface,
                                            border: Border.all(
                                              color: TerminalColors.dimGreen
                                                  .withValues(alpha: 0.5),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // ── App Content ──────────────────────
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.zero,
                                  child: SizedBox(
                                    width: _phoneWidth,
                                    child: MediaQuery(
                                      // Override the media query so inner
                                      // widgets see the phone-sized viewport
                                      data:
                                          MediaQuery.of(context).copyWith(
                                        size: Size(
                                          _phoneWidth,
                                          phoneHeight - 68,
                                        ),
                                      ),
                                      child: child,
                                    ),
                                  ),
                                ),
                              ),

                              // ── Bottom Bar (home indicator) ──────
                              Container(
                                width: double.infinity,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: TerminalColors.background,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft:
                                        Radius.circular(_frameRadius - 6),
                                    bottomRight:
                                        Radius.circular(_frameRadius - 6),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 100,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: TerminalColors.grey
                                          .withValues(alpha: 0.5),
                                      borderRadius:
                                          BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Hint text below phone ───────────────────
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Happy Valentine\'s Day!',
                          style: TextStyle(
                            fontFamily: 'Fira Code',
                            color: TerminalColors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
