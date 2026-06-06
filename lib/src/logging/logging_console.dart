import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tts_mod_vault/src/models/log_entry.dart' show LogLevel;
import 'package:tts_mod_vault/src/state/provider.dart'
    show logProvider, loggingProvider, logPanelHeightProvider, appThemeDataProvider;

/// Panel shown at the bottom of the mods column.
/// Visibility is toggled via [loggingProvider]; log data comes from [logProvider].
class LoggingConsole extends HookConsumerWidget {
  const LoggingConsole({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(loggingProvider.select((s) => s.isVisible));
    final entries = ref.watch(logProvider);
    final loggingNotifier = ref.read(loggingProvider.notifier);
    final scrollController = useScrollController();
    final filterText = useState('');
    final filterController = useTextEditingController();
    // Debug hidden by default — user can enable via the chip
    final visibleLevels = useState(
        LogLevel.values.where((l) => l != LogLevel.debug).toSet());
    final logHeight = ref.watch(logPanelHeightProvider);
    final t = ref.watch(appThemeDataProvider);

    // Auto-scroll to bottom on new entries
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
      return null;
    }, [entries.length]);

    if (!isVisible) return const SizedBox.shrink();

    final filtered = entries.where((e) {
      if (!visibleLevels.value.contains(e.level)) return false;
      if (filterText.value.isEmpty) return true;
      return e.message.toLowerCase().contains(filterText.value.toLowerCase());
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogDragHandle(currentHeight: logHeight),
        Container(
          height: logHeight,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.9),
            border: Border.all(color: t.border),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.terminal, color: t.textPrimary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Activity Log',
                      style: TextStyle(
                          color: t.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    const Spacer(),
                    // Severity filter chips
                    Wrap(
                      spacing: 4,
                      children: LogLevel.values.map((level) {
                        final active = visibleLevels.value.contains(level);
                        return Tooltip(
                          message: '${active ? "Hide" : "Show"} ${level.name} messages',
                          waitDuration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                          onTap: () {
                            final next =
                                Set<LogLevel>.from(visibleLevels.value);
                            active ? next.remove(level) : next.add(level);
                            visibleLevels.value = next;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: active
                                  ? _levelColor(level)
                                  : Colors.transparent,
                              border: Border.all(
                                  color: _levelColor(level), width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _levelText(level),
                              style: TextStyle(
                                color: active ? t.surface : t.textPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ));
                      }).toList(),
                    ),
                    const SizedBox(width: 8),
                    ...[120.0, 280.0, 450.0].asMap().entries.map((entry) {
                      final label = ['S', 'M', 'L'][entry.key];
                      final preset = entry.value;
                      final isActive = (logHeight - preset).abs() < 30;
                      final heights = [120, 280, 450];
                      return Tooltip(
                        message: '${label == 'S' ? 'Small' : label == 'M' ? 'Medium' : 'Large'} (${heights[entry.key]}px)',
                        waitDuration: const Duration(milliseconds: 300),
                        child: GestureDetector(
                        onTap: () =>
                            ref.read(logPanelHeightProvider.notifier).set(preset),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(left: 3),
                          decoration: BoxDecoration(
                            color: isActive ? t.accent : t.surfaceElevated,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isActive ? t.accentText : t.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ));
                    }),
                    IconButton(
                      icon:
                          Icon(Icons.copy, color: t.textPrimary, size: 16),
                      onPressed: () {
                        final text =
                            entries.map((e) => e.fullLogLine).join('\n');
                        Clipboard.setData(ClipboardData(text: text));
                      },
                      tooltip: 'Copy to clipboard',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete_sweep,
                          color: t.textPrimary, size: 16),
                      onPressed: () => ref.read(logProvider.notifier).clear(),
                      tooltip: 'Clear log',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: t.textPrimary, size: 16),
                      onPressed: loggingNotifier.toggleVisibility,
                      tooltip: 'Close',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Filter
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: t.surface,
                child: TextField(
                  controller: filterController,
                  style:
                      TextStyle(color: t.textPrimary, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Filter logs…',
                    hintStyle: TextStyle(color: t.textMuted),
                    prefixIcon:
                        Icon(Icons.search, color: t.textMuted, size: 16),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  onChanged: (v) => filterText.value = v,
                ),
              ),
              // Entries
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.formattedTimestamp,
                            style: TextStyle(
                                color: t.textMuted,
                                fontSize: 10,
                                fontFamily: 'monospace'),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: _levelColor(entry.level),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              _levelText(entry.level),
                              style: TextStyle(
                                  color: t.surface,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.message,
                              style: TextStyle(
                                  color: entry.color,
                                  fontSize: 11,
                                  fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Status bar
              Container(
                padding: const EdgeInsets.all(4),
                color: t.surface,
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} / ${entries.length} entries',
                      style: TextStyle(
                          color: t.textMuted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.success:
        return Colors.green;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.info:
        return Colors.blueGrey;
      case LogLevel.debug:
        return Colors.grey;
    }
  }

  String _levelText(LogLevel level) {
    switch (level) {
      case LogLevel.success:
        return 'OK';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERR';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.debug:
        return 'DBG';
    }
  }
}

class _LogDragHandle extends ConsumerStatefulWidget {
  final double currentHeight;
  const _LogDragHandle({required this.currentHeight});

  @override
  ConsumerState<_LogDragHandle> createState() => _LogDragHandleState();
}

class _LogDragHandleState extends ConsumerState<_LogDragHandle> {
  static const _min = 80.0;
  static const _max = 600.0;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appThemeDataProvider);
    return GestureDetector(
      onVerticalDragUpdate: (d) {
        // Free resize — no snapping during drag; S/M/L buttons handle presets
        final newH = (widget.currentHeight - d.delta.dy).clamp(_min, _max);
        ref.read(logPanelHeightProvider.notifier).set(newH);
      },
      onDoubleTap: () => ref.read(logPanelHeightProvider.notifier).set(280),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: Container(
          height: 8,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: t.accent.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
