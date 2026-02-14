import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/terminal_theme.dart';
import '../domain/terminal_bloc.dart';
import '../domain/terminal_event.dart';
import '../domain/terminal_state.dart';
import 'widgets/terminal_output_line.dart';

/// The main terminal screen — scrollable output + input bar at the bottom.
class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitCommand() {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;

    context.read<TerminalBloc>().add(TerminalCommandSubmittedEvent(text));
    _inputController.clear();

    // Scroll to bottom after the frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: TerminalColors.surface,
                border: Border(
                  bottom: BorderSide(color: TerminalColors.dimGreen, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'devdate',
                    style: TextStyle(
                      fontFamily: 'Fira Code',
                      color: TerminalColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<TerminalBloc, TerminalState>(
                    builder: (context, state) {
                      return state.isProcessing
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: TerminalColors.cyan,
                              ),
                            )
                          : const Icon(
                              Icons.terminal,
                              color: TerminalColors.dimGreen,
                              size: 18,
                            );
                    },
                  ),
                ],
              ),
            ),

            // ── Output area ─────────────────────────────────────
            Expanded(
              child: BlocConsumer<TerminalBloc, TerminalState>(
                listener: (context, state) {
                  // Auto-scroll to bottom on new output
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });
                },
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () => _focusNode.requestFocus(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: state.lines.length,
                      itemBuilder: (context, index) {
                        return TerminalOutputLineWidget(
                          line: state.lines[index],
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // ── Input bar ───────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: TerminalColors.inputBar,
                border: Border(
                  top: BorderSide(color: TerminalColors.dimGreen, width: 0.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    '\$ ',
                    style: TextStyle(
                      fontFamily: 'Fira Code',
                      color: TerminalColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _focusNode,
                      autofocus: true,
                      style: const TextStyle(
                        fontFamily: 'Fira Code',
                        color: TerminalColors.white,
                        fontSize: 14,
                      ),
                      cursorColor: TerminalColors.cursor,
                      cursorWidth: 8,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'type a command...',
                        hintStyle: TextStyle(
                          fontFamily: 'Fira Code',
                          color: TerminalColors.grey,
                          fontSize: 14,
                        ),
                      ),
                      onSubmitted: (_) => _submitCommand(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  GestureDetector(
                    onTap: _submitCommand,
                    child: const Icon(
                      Icons.keyboard_return,
                      color: TerminalColors.dimGreen,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
