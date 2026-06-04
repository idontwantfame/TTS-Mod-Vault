import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tts_mod_vault/src/models/log_entry.dart' show LogLevel;
import 'package:tts_mod_vault/src/state/provider.dart' show logProvider, loggingProvider;

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
    final visibleLevels = useState(LogLevel.values.toSet());

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

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        border: Border.all(color: Colors.grey.shade600),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Activity Log',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const Spacer(),
                // Severity filter chips
                Wrap(
                  spacing: 4,
                  children: LogLevel.values.map((level) {
                    final active = visibleLevels.value.contains(level);
                    return GestureDetector(
                      onTap: () {
                        final next = Set<LogLevel>.from(visibleLevels.value);
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
                            color: active ? Colors.black : Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white, size: 16),
                  onPressed: () {
                    final text = entries.map((e) => e.fullLogLine).join('\n');
                    Clipboard.setData(ClipboardData(text: text));
                  },
                  tooltip: 'Copy to clipboard',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white, size: 16),
                  onPressed: () => ref.read(logProvider.notifier).clear(),
                  tooltip: 'Clear',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey.shade900,
            child: TextField(
              controller: filterController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Filter logs…',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 16),
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
                        style: const TextStyle(
                            color: Colors.grey,
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
                          style: const TextStyle(
                              color: Colors.black,
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
            color: Colors.grey.shade800,
            child: Row(
              children: [
                Text(
                  '${filtered.length} / ${entries.length} entries',
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
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
    }
  }
}
